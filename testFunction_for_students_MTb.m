%% Continuous Position Estimator Test Script
% This function first calls the function "positionEstimatorTraining" to get
% the relevant modelParameters, and then calls the function
% "positionEstimator" to decode the trajectory.

% function RMSE = testFunction_for_students_MTb(teamName)

tic

load('monkeydata_training.mat');

% Set random number generator
s = rng(1333);  % 2013
ix = randperm(length(trial));

% Select training and testing data (you can choose to split your data in a different way if you wish)
trainingData = trial(ix(1:80),:);
testData = trial(ix(81:end),:);

disp('Testing the continuous position estimator...')

meanSqError = 0;
n_predictions = 0;

accuracy = 0;
error = cell(size(testData,1),8);

figure
hold on
axis square
grid

% Train Model
modelParameters = positionEstimatorTraining11(trainingData);

for tr=1:size(testData,1)
    display(['Decoding block ',num2str(tr),' out of ',num2str(size(testData,1))]);
    pause(0.001)
    for direc=randperm(8)
        decodedHandPos = [];

        times=320:20:(size(testData(tr,direc).spikes,2));

        for t=times
            past_current_trial.trialId = testData(tr,direc).trialId;
            past_current_trial.spikes = testData(tr,direc).spikes(:,1:t);
            past_current_trial.decodedHandPos = decodedHandPos;

            past_current_trial.startHandPos = testData(tr,direc).handPos(1:2,1);

%             if nargout('positionEstimator') == 3
%                 [decodedPosX, decodedPosY, newParameters] = positionEstimator(past_current_trial, modelParameters);
%                 modelParameters = newParameters;
%             elseif nargout('positionEstimator') == 2
%                 [decodedPosX, decodedPosY] = positionEstimator(past_current_trial, modelParameters);
%             end

            [decodedPosX, decodedPosY, angle] = positionEstimator(past_current_trial, modelParameters);

            if angle ~= direc
                error{tr,direc} = [error{tr,direc} t];
            end

            decodedPos = [decodedPosX; decodedPosY];
            decodedHandPos = [decodedHandPos decodedPos];

            meanSqError = meanSqError + norm(testData(tr,direc).handPos(1:2,t) - decodedPos)^2;

            accuracy = accuracy + isequal(angle,direc);

        end
        n_predictions = n_predictions+length(times);
        hold on
        z = tr * 5 * ones(1,length(decodedHandPos(1,:)));
        plot3(decodedHandPos(1,:),decodedHandPos(2,:), z, 'r');
%         plot(testData(tr,direc).handPos(1,times),testData(tr,direc).handPos(2,times),'b')
    end
end

% legend('Decoded Position', 'Actual Position')

RMSE = sqrt(meanSqError/n_predictions)
accuracy = accuracy/n_predictions

time = toc
% end
