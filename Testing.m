%% Testing
% 
% This script
%   1. generates testing data for each SNR point;
%   2. calculates the symbol error rate (SER) based on Gate Recurrent Units Network (GRU).

%% Clear workspace

clear variables;
close all;

%% Load common parameters and the trained NN

load('SimParameters.mat');
load('TrainedNet.mat');
load('NoiseParam.mat');

%% Other simulation parameters

NumPilot = length(FixedPilot);
PilotSpacing = NumSC/NumPilot;
NumOFDMsym = NumPilotSym+NumDataSym;

Mod_Constellation = [1+1j 1-1j -1+1j -1-1j];
c = numel(Mod_Constellation);
Label = length(c);

NumClass = length(Label);
NumPath = length(h);

%% SNR range

Eb_N0_dB_MAX = max(cell2mat(Eb_N0_dB));
RcvrPower_dB_MAX = max(cell2mat(RcvrPower_dB));

Eb_N0_dB = 30;% Eb_N0_dB_MAX-20:2:Eb_N0_dB_MAX; % Es/N0 in dB
Eb_N0 = 10.^(Eb_N0_dB./10);
RcvrPower = 10.^(RcvrPower_dB_MAX./10);
NoiseVar = RcvrPower./Eb_N0;

%% Testing data size

NumPacket = 10000; % Number of packets simulated per iteration

%% Simulation

% Same pilot sequences used in training and testing stages
FixedPilotAll = repmat(FixedPilot,1,1,NumPacket); 

% Number of Monte-Carlo iterations
NumIter = 1;

% Initialize error rate vectors
SER_GRU = zeros(length(NoiseVar),NumIter);

for i = 1:NumIter
    
    for snr = 1:length(NoiseVar)
        
        %% 1. Testing data generation
        
        noiseVar = NoiseVar(snr);
                
        % Pilot symbol (can be interleaved with random data symbols)
        PilotSym = sqrt(PowerVar/2)*complex(sign(rand(NumPilotSym,NumSC,NumPacket)-0.5),sign(rand(NumPilotSym,NumSC,NumPacket)-0.5)); 
        PilotSym(1:PilotSpacing:end) = FixedPilotAll;
    
        % Data symbol
        DataSym = sqrt(PowerVar/2)/sqrt(2)*complex(sign(rand(NumDataSym,NumSC,NumPacket)-0.5),sign(rand(NumDataSym,NumSC,NumPacket)-0.5)); 
    
        % Transmitted frame
        TransmittedPacket = [PilotSym;DataSym];
        
        % Received frame
        ReceivedPacket = getMultiLEOChannel(TransmittedPacket,LengthCP,h,noiseVar,2);
        
        % Channel Estimation
        wrapper = @(x,y) lsChanEstimation(x,y,NumPilot,NumSC,idxSC);
        ReceivedPilot = mat2cell(ReceivedPacket(1,:,:),1,NumSC,ones(1,NumPacket));
        PilotSeq = mat2cell(FixedPilotAll,1,1,NumPacket);
        EstChanLSCell = cellfun(wrapper,ReceivedPilot,PilotSeqm,'UniformOutput',false);
        EstChanLS = cell2mat(squeeze(EstChanLSCell));
        
        [feature,result,DimFeature,~] = ...
        getTrainingFeatureAndLabel(Mode,NormCSI,real(EstChanLS),imag(EstChanLS),TrainingTimeStep,PredictTimeStep,TrainingDataInterval,idxSC);
    
        featureVec = mat2cell(feature,size(feature,1),ones(1,size(feature,2)));
        resultVec = mat2cell(result,size(result,1),ones(1,size(result,2)));
        
        % Collect the data labels for the selected subcarrier
        DataLabel = zeros(size(DataSym(:,idxSC,:)));
        for c = 1:NumClass
            DataLabel(logical(DataSym(:,idxSC,:) == 1/sqrt(2)*Mod_Constellation(c))) = Label(c);
        end
        DataLabel = squeeze(DataLabel); 

        % Testing data collection
        XTest = cell(NumPacket,1);
        YTest = zeros(NumPacket,1);       
        for c = 1:NumClass
            [feature,label,idx] = getFeatureAndLabel(real(ReceivedPacket),imag(ReceivedPacket),DataLabel,Label(c));
            featureVec = mat2cell(feature,size(feature,1),ones(1,size(feature,2))); 
            XTest(idx) = featureVec;
            YTest(idx) = label;
        end
        YTest = categorical(YTest);
        
        %% 2. DL detection
        
        YPred = classify(Net,XTest,'MiniBatchSize',MiniBatchSize);
        SER_GRU(snr,i) = 1-sum(YPred == YTest)/NumPacket;
    end
    
end

SER_GRU = mean(SER_GRU,2).';


figure();
semilogy(Es_N0_dB,SER_DL,'r-o','LineWidth',2,'MarkerSize',10);hold on;
semilogy(Es_N0_dB,SER_LS,'b-o','LineWidth',2,'MarkerSize',10);hold off;
% semilogy(Es_N0_dB,SER_MMSE,'k-o','LineWidth',2,'MarkerSize',10);hold off;
% legend('Deep learning (DL)','Least square (LS)','Minimum mean square error (MMSE)');
legend('Deep learning (DL)','Least square (LS)');
xlabel('Es/N0 (dB)');
ylabel('Symbol error rate (SER)');

%% 

function SER = getSymbolDetection(ReceivedData,EstChan,Mod_Constellation,Label,DataLabel)
% This function is to calculate the symbol error rate from the equalized
% symbols based on hard desicion. 

EstSym = squeeze(ReceivedData)./EstChan;

% Hard decision
DecSym = sign(real(EstSym))+1j*sign(imag(EstSym));
DecLabel = zeros(size(DecSym));
for c = 1:length(Mod_Constellation)
    DecLabel(logical(DecSym == Mod_Constellation(c))) = Label(c);
end

SER = 1-sum(DecLabel == DataLabel)/length(EstSym);

end






