function [modelParameters] = positionEstimatorTraining11(training_data)
% Arguments:

% - training_data:
%     training_data(n,k)              (n = trial id,  k = reaching angle)
%     training_data(n,k).trialId      unique number of the trial
%     training_data(n,k).spikes(i,t)  (i = neuron id, t = time)
%     training_data(n,k).handPos(d,t) (d = dimension [1-3], t = time)

% ... train your model

% Return Value:

% - modelParameters:
%     single structure containing all the learned parameters of your
%     model and which can be used by the "positionEstimator" function.
  

%% Average trajectory
trj_nbr = length(training_data(1,:));
treshold = [25 5 -35 -50 -50 -50 25 25];

% % plot all trajectories
% for i=1:length(training_data(:,1))
%     for j=1:trj_nbr
%         x = training_data(i,j).handPos(1,:);
%         y = training_data(i,j).handPos(2,:);
% 
%         plot(x, y, 'y')
%         grid on
%         hold on
%     end
% end
% 
% xlabel('X')
% ylabel('Y')

% calculate the longest trial
m = 0;
for j=1:trj_nbr
    for i=1:length(training_data(:,1))    
        l = length(training_data(i,j).spikes(1,:));
        if l>m
            m = l;
        end
    end
end
% make all trajectories the same length
for j=1:trj_nbr
    for i=1:length(training_data(:,1))
        for k=length(training_data(i,j).spikes(1,:))+1:m
        training_data(i,j).handPos = [training_data(i,j).handPos training_data(i,j).handPos(:, end)];
        end
    end
end

% calculate average trajectory
avg_trj(trj_nbr).handPos = [];
for j=1:trj_nbr 
    trj = zeros(2,m);
    for i=1:length(training_data(:,1))
        for k=1:length(training_data(i,j).handPos(1,:))
            trj(:,k) = trj(:,k) + training_data(i,j).handPos(1:2,k);
        end
    end
    avg_trj(j).handPos=trj(:,:)/length(training_data(:,1));
end

% % plot avaerage trajctory
% for i=1:trj_nbr
%         x = avg_trj(i).handPos(1,:);
%         y = avg_trj(i).handPos(2,:);
% 
%         plot(x, y, '--k')
%         grid on
%         hold on
% end

% create k_class trajectories
k_class = 3;
modelParameters{10} = k_class;
avg_cluster(trj_nbr,k_class).handPos = [];
for j=1:trj_nbr 
    temp = zeros(length(training_data(:,1)),2);
    for i=1:length(training_data(:,1))
        if treshold(j) > 0
            index = find(training_data(i,j).handPos(1,:)>treshold(j),1);
        else
            index = find(training_data(i,j).handPos(1,:)<treshold(j),1);
        end
        temp(i,1) = training_data(i,j).handPos(2,index);
        temp(i,2) = i;
    end
    
    idx = sortrows(temp);
    
    for i=1:length(training_data(:,1))
%         training_data(i,j).label = floor(find(idx(:,2)==i)/length(training_data(:,1))*k_class)+1;
        index = find(idx(:,2)==i);
        if index < 0.3*length(training_data(:,1))
            training_data(i,j).label = 1;
        elseif index > 0.7*length(training_data(:,1))
            training_data(i,j).label = 3;
        else
            training_data(i,j).label = 2;
        end
    end
    
    for k=1:k_class 
        clusters{k} = zeros(2, m);
    end
    num = zeros(k_class, 1);
    for k=1:k_class        
        for i=1:length(training_data(:,1))
            if k == training_data(i,j).label
                num(k) = num(k)+1;
                clusters{k}(1,:) = clusters{k}(1,:) + training_data(i,j).handPos(1,:);
                clusters{k}(2,:) = clusters{k}(2,:) + training_data(i,j).handPos(2,:);
            end
        end
        clusters{k} = clusters{k}/num(k);
    end
    
    for k=1:k_class 
        avg_cluster(j, k).handPos = clusters{k};
    end    
    
%     for k=1:k_class  
%             x = clusters{k}(1,:);
%             y = clusters{k}(2,:);
% 
%             plot(x, y, 'k')
%             grid on
%             hold on
%     end
end  



%% Data preparation  
m = 300; % ms analysed
z = 0;
u = 50; % # of neurons in the sum
norm = 1;
modelParameters{5} = m;
modelParameters{6} = z;
modelParameters{7} = u;
modelParameters{8} = norm;

l = 0; % max # of datapoints possible to create
l_a = zeros(8,1);
 
% calculate max # of datapoints possible to create
for n=1: length(training_data(:,1)) % training data: 80% of all trials
    for k=1:8 % reaching angles
        s = 320;
        while(1)
            l = l + 1;
            l_a(k) = l_a(k) + 1;
            s = s + 20; % step 20ms
            if s-20==length(training_data(n,k).spikes(1,:))-120
                break;
            elseif s>length(training_data(n,k).spikes(1,:))-120
                s = length(training_data(n,k).spikes(1,:))-120;
            end
        end
    end
end
 
x = zeros(98*(m-z)/u, l); % training data
t = zeros(8, l); % training labels

x_tr = cell(8,1);
t_tr = cell(8,1);
for k=1:8
    x_tr{k} = zeros(98*(m-z)/u, l_a(k));
    t_tr{k} = zeros(k_class, l_a(k));
end

x_temp = [];

q = 1; 
q_a = ones(1,8);
for n=1:length(training_data(:,1))
    for k=1:8
        s = 320;
        while(1)
            % crate one datapoint 98x6
            for i=m:-u:(z+1) 
                sum = zeros(98,1);
                % average over 50ms
                for j=0:(u-1)
                    sum = sum + training_data(n,k).spikes(:,s-i+j);
                end
                if norm == 1
                    x_temp = [x_temp; sum/u*14];
                else
                    x_temp = [x_temp; sum];
                end
            end
            x(:,q) = x_temp;
            x_tr{k}(:,q_a(k)) = x_temp;
            x_temp = [];
 
            % create training labels
            t_temp = zeros(8, 1);
            t_temp(k) = 1; % for one angle
            t(:,q) = t_temp;
            t_tr{k}(training_data(n,k).label,q_a(k)) = 1;
 
            q = q + 1;
            q_a(k) = q_a(k) + 1;
            s = s + 20; % step 20ms
            if s-20==length(training_data(n,k).spikes(1,:))-120
                break;
            elseif s>length(training_data(n,k).spikes(1,:))-120
                s = length(training_data(n,k).spikes(1,:))-120;
            end
        end
    end
end


%% Neural Network
rep = 3; % number of neural nets in committee machine
modelParameters{9} = rep;
net_tab = cell(1,rep);

% Train the Network
for n=1:rep
    n
    % Choose a Training Function
    trainFcn = 'trainscg';  % Scaled conjugate gradient backpropagation.

    % Create a Pattern Recognition Network
    hiddenLayerSize = [100];
    net = patternnet(hiddenLayerSize, trainFcn);
    
    if mod(n,2)
        net.layers{1}.transferFcn = 'tansig';
    else
        net.layers{1}.transferFcn = 'radbas';
    end

    % Setup Division of Data for Training, Validation, Testing
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;
    
    % Train the Network
    [net,~] = train(net,x,t);
    net_tab{n} = net;
    clear net
end
  

tr_net_tab = cell(1,8);

% Train the Network
for k=1:8
    k
    % Choose a Training Function
    trainFcn = 'trainscg';  % Scaled conjugate gradient backpropagation.

    % Create a Pattern Recognition Network
    hiddenLayerSize = [200];
    net = patternnet(hiddenLayerSize, trainFcn);
    
    net.layers{1}.transferFcn = 'tansig';

    % Setup Division of Data for Training, Validation, Testing
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;
    
    % Train the Network
    [net,~] = train(net,x_tr{k},t_tr{k});
    tr_net_tab{k} = net;
    clear net
end


% save parameters
modelParameters{1} = net_tab;
modelParameters{2} = tr_net_tab;
modelParameters{3} = avg_trj;
modelParameters{4} = avg_cluster;
end