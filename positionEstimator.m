function [x, y, angle] = positionEstimator(test_data, modelParameters)
% **********************************************************
%
% function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)
%                 ^^^^^^^^^^^^^^^^^^
% *********************************************************

% - test_data:
%     test_data(m).trialID
%         unique trial ID
%     test_data(m).startHandPos
%         2x1 vector giving the [x y] position of the hand at the start
%         of the trial
%     test_data(m).decodedHandPos
%         [2xN] vector giving the hand position estimated by your
%         algorithm during the previous iterations. In this case, N is 
%         the number of times your function has been called previously on
%         the same data sequence.
%     test_data(m).spikes(i,t) (m = trial id, i = neuron id, t = time)
%     in this case, t goes from 1 to the current time in steps of 20
%     Example:
%         Iteration 1 (t = 320):
%             test_data.trialID = 1;
%             test_data.startHandPos = [0; 0]
%             test_data.decodedHandPos = []
%             test_data.spikes = 98x320 matrix of spiking activity
%         Iteration 2 (t = 340):
%             test_data.trialID = 1;
%             test_data.startHandPos = [0; 0]
%             test_data.decodedHandPos = [2.3; 1.5]
%             test_data.spikes = 98x340 matrix of spiking activity



% ... compute position at the given timestep.

% Return Value:

% - [x, y]:
%     current position of the hand

%% Data preparation
net_tab = modelParameters{1};
avg_trj = modelParameters{2};

m = modelParameters{3}; % ms analysed
z = modelParameters{4};
u = modelParameters{5}; % # of neurons in the sum
norm = modelParameters{6};

rep = modelParameters{7}; % number of neural nets in committee machine

HandPos = test_data.decodedHandPos;
if length(HandPos) > 1
    class = zeros(1,length(HandPos(1,:)));
    for i=1:length(HandPos(1,:))
        x = abs(HandPos(1,i));
        x = x*10^4;
        x1 = floor(x);
        x = round((x-x1)*10);
        class(i) = round(x);
    end
end

s = length(test_data.spikes(1,:));
xt = zeros(98*m/u,1);
k = 0;
for i=m:-u:(z+1)
    % average over 50ms
    sum_s = sum(test_data.spikes(:,s-i:s-i+u-1),2);
    if norm == 1
        xt(k*98+1:(k+1)*98) = sum_s/u*14;
    else
        xt(k*98+1:(k+1)*98) = sum_s;
    end
    k = k+1;
end


%% Test the Network
yt_avg = zeros(8,1);
for n=1:rep
%     [net_tab{n}, yt] = adapt(net_tab{n},xt);
    yt = net_tab{n}(xt);
    yt_avg = yt_avg + yt/rep;
end
[~, angle] = max(yt_avg);

if s >= 400
    class = [class angle];
else
    class = angle;
end

angle = mode(class);

if s < length(avg_trj(angle).handPos(1,:))
    x = avg_trj(angle).handPos(1,s);
    y = avg_trj(angle).handPos(2,s);
else
    x = avg_trj(angle).handPos(1,end);
    y = avg_trj(angle).handPos(2,end);
end

x = round(x, 4);
c = angle*10^-5;
if x< 0
    x = x-c;
else
    x = x+c;
end

end
