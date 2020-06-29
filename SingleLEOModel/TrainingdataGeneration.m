%% Training Data Generation 
%
% This script is created to generate training and validation data for the deep
% learning model in a single-user OFDM system. 

% The training data and the validation data is collected for a single
% subcarrier selected based on a pre-defined metric. The transmitter sends
% OFDM packets to the receiver, where each OFDM packet contains one OFDM
% pilot symbol and one OFDM data symbol. Data symbols can be interleaved in
% the pilot sequence. 

% Each training sample contains all symbols in a received OFDM packet and 
% is represented by a feature vector that follows the similar data struture
% in the MATLAB example of seqeunce classification using LSTM network.
% Please run the command and check it out.  
% >> openExample('nnet/ClassifySequenceDataUsingLSTMNetworksExample')

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

% One can replace the 3GPP channel with the narrowband Rayleigh fading channel:  
% h = 1/sqrt(2)*complex(randn(NumPath,1),randn(NumPath,1)); 

H = fft(h,NumSC,1); 

%% SNR and Noise calculation 

Es_N0_dB = 200; % (STK SNR parameter)
Es_N0 = 10.^(Es_N0_dB./10);
N0 = 1./Es_N0;
NoiseVar = N0./2;

%% Low-Noise Amplifier Gain

LNAGain_dB = 35;
LNAGain = 10^(LNAGain_dB/10);

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
NumPacket = 10000; % Number of packets per iteration

% Training time step length
TrainingTimeStep = 150;

% Prediction time step length
PredictTimeStep = 1;

% Training data shift length
TrainingDataInterval = 1;

%% Simulation
% Pilot symbols - Fixed during the whole transmission
FixedPilot = 1/sqrt(2)*complex(sign(rand(1,NumPilot)-0.5),sign(rand(1,NumPilot)-0.5)); 
% FixedPilot = sqrt(LNAGain)/sqrt(2)*complex(sign(rand(1,NumPilot)-0.5),sign(rand(1,NumPilot)-0.5)); 
% Same pilot sequences used in all packets
FixedPilotAll = repmat(FixedPilot,1,1,NumPacket); 

% Pilot symbol (can be interleaved with random data symbols)
PilotSym = 1/sqrt(2)*complex(sign(rand(NumPilotSym,NumSC,NumPacket)-0.5),sign(rand(NumPilotSym,NumSC,NumPacket)-0.5)); 
% PilotSym = sqrt(LNAGain)/sqrt(2)*complex(sign(rand(NumPilotSym,NumSC,NumPacket)-0.5),sign(rand(NumPilotSym,NumSC,NumPacket)-0.5)); 
PilotSym(1:PilotSpacing:end) = FixedPilotAll;

% Data symbol
DataSym = 1/sqrt(2)*complex(sign(rand(NumDataSym,NumSC,NumPacket)-0.5),sign(rand(NumDataSym,NumSC,NumPacket)-0.5)); 
% DataSym = sqrt(LNAGain)/sqrt(2)*complex(sign(rand(NumDataSym,NumSC,NumPacket)-0.5),sign(rand(NumDataSym,NumSC,NumPacket)-0.5)); 

% Transmitted frame data
TransmittedPacket = [PilotSym;DataSym];

% Received OFDM frame
ReceivedPacket = getOFDMChannel(TransmittedPacket,LengthCP,h,NoiseVar);

% LS Channel Estimation
wrapper = @(x,y) lsChanEstimation(x,y,NumPilot,NumSC,idxSC);
ReceivedPilot = mat2cell(ReceivedPacket(1,:,:),1,NumSC,ones(1,NumPacket));
PilotSeq = mat2cell(FixedPilotAll,1,NumPilot,ones(1,NumPacket));
EstChanLSCell = cellfun(wrapper,ReceivedPilot,PilotSeq,'UniformOutput',false);
EstChanLS = cell2mat(squeeze(EstChanLSCell));

%% Training Data Collection
% Get training feature 
% Mode = S, only CSI signal
% Mode = SN, CSI signal followed by noise
Mode = 'S';
NormCSI = true;
[feature,result,DimFeature] = getTrainingFeature(Mode,NormCSI,real(EstChanLS),imag(EstChanLS),TrainingTimeStep,PredictTimeStep,TrainingDataInterval,idxSC);
featureVec = mat2cell(feature,size(feature,1),ones(1,size(feature,2)));
resultVec = mat2cell(result,size(result,1),ones(1,size(result,2)));

% Re-organize the dataset
X = featureVec.';
Y = resultVec.';

% Split the dataset into training set, validation set and testing set
TrainSize = 4/5;
ValidSize = 1/5;

NumSample = size(X,1);

% Training data
XTrain = X(1:NumSample*TrainSize);
YTrain = Y(1:NumSample*TrainSize);

XValid = X(NumSample*TrainSize+1:end);
YValid = Y(NumSample*TrainSize+1:end);

%% Save the training data for training the neural network

save('TrainingData.mat','XTrain','YTrain','TrainingTimeStep','DimFeature');
save('ValidationData.mat','XValid','YValid');
%save('SimParameters.mat','NumPilotSym','NumDataSym','NumSC','idxSC','h','LengthCP','FixedPilot','Mod_Constellation','Label','TimeStep'); 