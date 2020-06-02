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
MaxEpochs = 50;
NumFeature = 4;
InputSize = NumFeature*TrainingTimeStep;
NumHiddenUnits = 128;
NumResponses = 2;

%% Form RNN layers

Layers = [ ...
    sequenceInputLayer(InputSize)
    gruLayer(NumHiddenUnits,'Name','hidden1','OutputMode','sequence')
    %dropoutLayer(0.1)

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

%% Save the RNN

save('TrainedNet','Net','MiniBatchSize');



