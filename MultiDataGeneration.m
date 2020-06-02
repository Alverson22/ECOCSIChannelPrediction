%% Training Data Generation 
%
% This script is created to generate training and validation data for the deep
% learning model in a single-user system. 

% The training data and the validation data is collected for a single
% subcarrier selected based on a pre-defined metric. The transmitter sends
% packets to the receiver, where each packet contains one pilot symbol and 
% one data symbol. Data symbols can be interleaved in
% the pilot sequence. 

%% Clear workspace

clear all;
close all;


%% OFDM system parameters

NumSC = 64; % Number of subcarriers
NumPilot = 64; % Number of pilot subcarriers
PilotSpacing = NumSC/NumPilot;
NumPilotSym = 1;
NumDataSym = 1;
NumOFDMsym = NumPilotSym + NumDataSym;

%% Channel generation

NumPath = 20;
LengthCP = 16; % The length of the cyclic prefix
% The channel matrix generated using the 3GPP TR38.901 channel model of the
% writer's own implementation, which is saved and loaded:
load('SavedChan.mat'); 
load('DataIteration.mat');

% One can replace the 3GPP channel with the narrowband Rayleigh fading channel:  
% h = 1/sqrt(2)*complex(randn(NumPath,1),randn(NumPath,1)); 

H = fft(h,NumSC,1); 

%% Transmitter Model Spec

TransmitterPower_dB = 60; % dBm
LNAGain_dB = 35; % dBm
PowerVar = 10^((TransmitterPower_dB+LNAGain_dB)/10);

%% Subcarrier selection

% This is the subcarrier selected for the saved channel h, which can be
% replaced by the following process.
idxSC = 26;

% Select the subcarrier randomly whose gain is above the median value
% MedianGain = median(abs(H).^2);
% [PossibleSC,~] = find(logical(abs(H).^2 >= MedianGain) == 1);
% idxSC = PossibleSC(randi(length(PossibleSC)));

%% Training data generation

% Size of dataset to be defined
NumPacket = 10000; % Number of packets per LEO track

% Training time step length
TrainingTimeStep = 100;

% Prediction time step length
PredictTimeStep = 1;

% Training data shift length
TrainingDataInterval = 1;

X = []; % Data
Y = []; % Data with time shift

%% Simulation
% Pilot symbols - Fixed during the whole transmission
FixedPilot = sqrt(PowerVar/2)*complex(sign(rand(1,NumPilot)-0.5),sign(rand(1,NumPilot)-0.5)); 
% Same pilot sequences used in all packets
FixedPilotAll = repmat(FixedPilot,1,1,NumPacket); 

% Pilot symbol (can be interleaved with random data symbols)
PilotSym = sqrt(PowerVar/2)*complex(sign(rand(NumPilotSym,NumSC,NumPacket)-0.5),sign(rand(NumPilotSym,NumSC,NumPacket)-0.5)); 
PilotSym(1:PilotSpacing:end) = FixedPilotAll;

% Data symbol
DataSym = sqrt(PowerVar/2)*complex(sign(rand(NumDataSym,NumSC,NumPacket)-0.5),sign(rand(NumDataSym,NumSC,NumPacket)-0.5)); 

% The data symbol of the current class on the selected subcarrier
% CurrentSym = 1/sqrt(2)*Mod_Constellation(c)*ones(NumDataSym,1,NumPacketPerClass); 
% DataSym(:,idxSC,:) = CurrentSym;

% Transmitted frame
TransmittedPacket = [PilotSym;DataSym];

%% Get training feature 
% Mode = S, only CSI signal
% Mode = SN, CSI signal followed by noise
% NormCSI is to determined wheather CSI should be Nomalized
Mode = 'S';
NormCSI = true;

for n = 1:NumCSV
    % Received frame
    ReceivedPacket = getMultiLEOChannel(TransmittedPacket,LengthCP,h,n);

    % LS Channel Estimation
    wrapper = @(x,y) lsChanEstimation(x,y,NumPilot,NumSC,idxSC);
    ReceivedPilot = mat2cell(ReceivedPacket(1,:,:),1,NumSC,ones(1,NumPacket));
    PilotSeq = mat2cell(FixedPilotAll,1,NumPilot,ones(1,NumPacket));
    EstChanLSCell = cellfun(wrapper,ReceivedPilot,PilotSeq,'UniformOutput',false);
    EstChanLS = cell2mat(squeeze(EstChanLSCell));

    [feature,result,DimFeature,NumTrainingSample] = ...
        getTrainingFeatureAndLabel(Mode,NormCSI,real(EstChanLS),imag(EstChanLS),TrainingTimeStep,PredictTimeStep,TrainingDataInterval,idxSC);
    
    featureVec = mat2cell(feature,size(feature,1),ones(1,size(feature,2)));
    resultVec = mat2cell(result,size(result,1),ones(1,size(result,2)));
    X = [X featureVec];
    Y = [Y resultVec];
end

%% Training Data Collection
% Re-organize the dataset
X = X.';
Y = Y.';

% Split the dataset into training set, validation set and testing set
TrainSize = 4/5;
ValidSize = 1/5;

NumSample = NumTrainingSample * NumCSV;

% Training data
XTrain = X(1:NumSample*TrainSize);
YTrain = Y(1:NumSample*TrainSize);

XValid = X(NumSample*TrainSize+1:end);
YValid = Y(NumSample*TrainSize+1:end);

%% Save the training data for training the neural network

save('TrainingData.mat','XTrain','YTrain','TrainingTimeStep','DimFeature');
save('ValidationData.mat','XValid','YValid');
save('SimParameters.mat','NumPilotSym','NumDataSym','NumSC','TrainingTimeStep','PredictTimeStep','TrainingDataInterval','NumCSV','idxSC','h','LengthCP','FixedPilot','PowerVar'); 