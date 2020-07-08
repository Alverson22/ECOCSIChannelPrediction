function [feature,result,DimFeature,NumTrainingSample] = getTrainingFeatureAndLabel(Mode,RealData,ImagData,TrainingTimeStep,PredictTimeStep,TrainingDataInterval,idxSC,n)
% This function is to
%   1. transform the received OFDM packets to feature vectors for training
%      data collection;
%   2. collect the corresponding labels.

% Determine the feature size
NumTrainingSample = floor((size(RealData,1) - (TrainingTimeStep+PredictTimeStep-1)) / TrainingDataInterval);

% Data Collection
% The LEO CSI need to be normalized to allow GRU learning model to learn
RealData_MEAN = mean(RealData);
RealData_STD = std(RealData);
RealPart = (RealData-RealData_MEAN) / RealData_STD;
ImagData_MEAN = mean(ImagData);
ImagData_STD = std(ImagData);
ImagPart = (ImagData-ImagData_MEAN) / ImagData_STD;

% Generating training sequence only CSI signal
if Mode == 'S'
    % Feature vector
    DimFeature = 2;
    DimFeatureVec = TrainingTimeStep * DimFeature; % real + imag
    feature = zeros(DimFeatureVec,NumTrainingSample);
    result = zeros(2,NumTrainingSample);

    for n = 1:TrainingDataInterval:NumTrainingSample
        feature(1:2:end,n) = RealPart(n:n+TrainingTimeStep-1);
        feature(2:2:end,n) = ImagPart(n:n+TrainingTimeStep-1);
        result(1,n) = RealPart(n+TrainingTimeStep+PredictTimeStep-1);
        result(2,n) = ImagPart(n+TrainingTimeStep+PredictTimeStep-1);
    end
    
% Generating training sequence with CSI signal and Elevation Angle
elseif Mode == 'SE'
    
    % Load pre-defined Gaussian noise
    load("EAngle.mat");
    EAngle = cell2mat(EAngle(n)) ./ 90 ;
    
    % Feature vector
    DimFeature = 3;
    DimFeatureVec = TrainingTimeStep * DimFeature; % real + imag (CSI + Noise)
    feature = zeros(DimFeatureVec,NumTrainingSample);
    result = zeros(2,NumTrainingSample);

    for n = 1:TrainingDataInterval:NumTrainingSample
        feature(1:3:end,n) = RealPart(n:n+TrainingTimeStep-1);
        feature(2:3:end,n) = ImagPart(n:n+TrainingTimeStep-1);
        feature(3:3:end,n) = EAngle(n:n+TrainingTimeStep-1);
        result(1,n) = RealPart(n+TrainingTimeStep+PredictTimeStep-1);
        result(2,n) = ImagPart(n+TrainingTimeStep+PredictTimeStep-1);
    end

% Generating training sequence with CSI signal and noise
elseif Mode == 'SN'
    % Load pre-defined Gaussian noise
    load("ChannelNoise");

    % Feature vector
    DimFeature = 4;
    DimFeatureVec = TrainingTimeStep * DimFeature; % real + imag (CSI + Noise)
    feature = zeros(DimFeatureVec,NumTrainingSample);
    result = zeros(2,NumTrainingSample);

    % Noise feature preprocessing
    NoiseCP = permute(reshape(NoiseT, NumSC+LengthCP,NumSym,NumPacket),[2,1,3]);
    % Removing CP
    NoiseNCP = squeeze(NoiseCP(1,LengthCP+1:LengthCP+NumSC,:));
    NoisePart = NoiseNCP(idxSC,:).';
    NoiseRealPart = real(NoisePart);
    NoiseImagPart = imag(NoisePart);

    for n = 1:TrainingDataInterval:NumTrainingSample
        feature(1:4:end,n) = RealPart(n:n+TrainingTimeStep-1);
        feature(2:4:end,n) = ImagPart(n:n+TrainingTimeStep-1);
        feature(3:4:end,n) = NoiseRealPart(n:n+TrainingTimeStep-1);
        feature(4:4:end,n) = NoiseImagPart(n:n+TrainingTimeStep-1);
        result(1,n) = RealPart(n+TrainingTimeStep+PredictTimeStep-1);
        result(2,n) = ImagPart(n+TrainingTimeStep+PredictTimeStep-1);
    end
    


end



save('Normalized.mat','RealData_MEAN','RealData_STD','ImagData_MEAN','ImagData_STD');

end

