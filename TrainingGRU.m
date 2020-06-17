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

MiniBatchSize = 300;
MaxEpochs = 50;
NumFeature = DimFeature;
InputSize = NumFeature*TrainingTimeStep;
NumHiddenUnits = 64;
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
figure('Name','CSI Diagram');
set(gcf, 'Position', [300, 300, 1000, 400]);
subplot(1,2,1);
plot(1:size(y,1)/2,y(1:2:end),'r','LineWidth',1); hold on;
plot(1:size(y,1)/2,y(2:2:end),'b','LineWidth',1); hold off;
title('CSI Prediction');
xlabel('Time');
ylabel('CSI Value');
legend({'Real (CSI)','Imag (CSI)'},'Location','southwest');
legend('boxoff');

y = cell2mat(YValid);
subplot(1,2,2);
plot(1:size(y,1)/2,y(1:2:end),'m','LineWidth',1); hold on;
plot(1:size(y,1)/2,y(2:2:end),'c','LineWidth',1); hold off;
title('Ground Truth');
xlabel('Time');
ylabel('CSI Value');
legend({'Real (CSI)','Imag (CSI)'},'Location','southwest');
legend('boxoff');

%% Save the RNN

save('TrainedNet','Net','MiniBatchSize');



