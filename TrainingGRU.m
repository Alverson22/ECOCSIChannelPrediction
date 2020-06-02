%% TrainRNN
%
% This script is to set up parameters for training the recurrent neural network
% (RNN).

% The RNN is trained for the selected subcarrier based on the training
% data.

%% Clear workspace

clear variables;
close all;

%% Load training and validation data

load('TrainingData.mat');
load('ValidationData.mat');

%% Define training parameters

MiniBatchSize = 500;
MaxEpochs = 30;
NumFeature = DimFeature;
InputSize = NumFeature*TrainingTimeStep;
NumHiddenUnits = 128;
NumResponses = 2;

%% Form RNN layers

Layers = [ ...
    sequenceInputLayer(InputSize)
    gruLayer(NumHiddenUnits,'OutputMode','sequence')
    dropoutLayer(0.2)
    fullyConnectedLayer(NumResponses)
    regressionLayer];


%% Define trainig options

Options = trainingOptions('adam',...
    'InitialLearnRate',0.01,...
    'ValidationData',{XValid,YValid}, ...
    'ExecutionEnvironment','gpu', ...
    'GradientThreshold',1, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor',0.1,...
    'LearnRateDropPeriod',10,...
    'L2Regularization',1.000e-4,...
    'MaxEpochs',MaxEpochs, ...
    'MiniBatchSize',MiniBatchSize, ...
    'Shuffle','every-epoch', ...
    'Verbose',1,...
    'Plots','training-progress');

%% Train RNN

Net = trainNetwork(XTrain,YTrain,Layers,Options);

%% Plot CSI Result
YPred = predict(Net,XValid,'MiniBatchSize',MiniBatchSize);
y = cell2mat(YPred);
figure('Name','Predict Diagram');
plot(1:size(y,1)/2,y(1:2:end),'r','LineWidth',1); hold on;
plot(1:size(y,1)/2,y(2:2:end),'b','LineWidth',1); hold off;
legend('Real(PredH)','Imag(PredH)');

y = cell2mat(YValid);
figure('Name','Valid Diagram');
plot(1:size(y,1)/2,y(1:2:end),'m','LineWidth',1); hold on;
plot(1:size(y,1)/2,y(2:2:end),'c','LineWidth',1); hold off;
legend('Real(ValidH)','Imag(ValidH)');

%% Save the RNN

save('TrainedNet','Net','MiniBatchSize');



