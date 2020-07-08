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
NumSym = NumPilotSym+NumDataSym;

Mod_Constellation = [1+1j;1-1j;-1+1j;-1-1j]; % QPSK Modulation
NumClass = numel(Mod_Constellation);
Label = 1:NumClass;

NumPath = length(h);

%% SNR caculation

Eb_N0_dB_MAX = max(cell2mat(Eb_N0_dB));
RcvrPower_dB_MAX = max(cell2mat(RcvrPower_dB));
 
Eb_N0_dB = Eb_N0_dB_MAX-40:2:Eb_N0_dB_MAX-20; % Es/N0 in dB
Eb_N0 = 10.^(Eb_N0_dB./10);
RcvrPower = 10.^(RcvrPower_dB_MAX./10);
NoiseVar = RcvrPower./Eb_N0;

%% Testing data size

NumPacket = 45000; % Number of packets simulated per iteration

%% Simulation

% Same pilot sequences used in training and testing stages
FixedPilotAll = repmat(FixedPilot,1,1,NumPacket); 

% Predict Time Step
% predictTimeStep = [1 2 3 4 5 6 7 8 9 10];

% Number of Monte-Carlo iterations
NumIter = 1;

% Initialize error rate vectors
SER_GRU = zeros(length(NoiseVar),NumIter);
% SER_GRU = zeros(length(predictTimeStep),NumIter);

% Testing LEO Track CSV number
NumCSV = 1;

% f = waitbar(1/NumIter,sprintf('Operating iteration %d/%d',i,length(Eb_N0_dB)),'Name','Processing Channel Prediction...');

for i = 1:NumIter
    % for PredictTimeStep = 1:length(predictTimeStep)
    for snr = 1:length(NoiseVar)
%        waitbar(snr/length(NoiseVar),f,sprintf('Operating iteration %d/%d',snr,length(NoiseVar)));
        %% 1. Testing data generation
        noiseVar = NoiseVar(snr);
                
        % Pilot symbol (can be interleaved with random data symbols)
        PilotSym = sqrt(PowerVar/2)*complex(sign(rand(NumPilotSym,NumSC,NumPacket)-0.5),sign(rand(NumPilotSym,NumSC,NumPacket)-0.5)); 
        PilotSym(1:PilotSpacing:end) = FixedPilotAll;
    
        % Data symbol
        DataSym = sqrt(PowerVar/2)*complex(sign(rand(NumDataSym,NumSC,NumPacket)-0.5),sign(rand(NumDataSym,NumSC,NumPacket)-0.5)); 
    
        % Transmitted frame
        TransmittedPacket = [PilotSym;DataSym];
        
        % Received frame
        ReceivedPacket = getLEOChannel(Scenario,TransmittedPacket,LengthCP,h,noiseVar,NumCSV);
        
        % Channel Estimation
        wrapper = @(x,y) lsChanEstimation(x,y,NumPilot,NumSC,idxSC);
        ReceivedPilot = mat2cell(ReceivedPacket(1,:,:),1,NumSC,ones(1,NumPacket));
        PilotSeq = mat2cell(FixedPilotAll,1,NumPilot,ones(1,NumPacket));
        EstChanLSCell = cellfun(wrapper,ReceivedPilot,PilotSeq,'UniformOutput',false);
        EstChanLS = cell2mat(squeeze(EstChanLSCell));
        
        plotCSI(EstChanLS(TrainingTimeStep+1:end),'CSI Ground Truth',NumCSV,['m','c'],Eb_N0_dB(snr));
        
        [feature,result,DimFeature,NumTestingSample] = ...
            getTrainingFeatureAndLabel(Mode,real(EstChanLS),imag(EstChanLS),TrainingTimeStep,PredictTimeStep,TrainingDataInterval,idxSC,NumCSV);
    
        featureVec = mat2cell(feature,size(feature,1),ones(1,size(feature,2)));
        resultVec = mat2cell(result,size(result,1),ones(1,size(result,2)));
        
        XTest = featureVec.';
        
        % Collect the data labels for the selected subcarrier
        DataLabel = zeros(size(DataSym(:,idxSC,TrainingTimeStep+PredictTimeStep:end)));
        for c = 1:NumClass
            DataLabel(logical(DataSym(:,idxSC,TrainingTimeStep+PredictTimeStep:end) == sqrt(PowerVar/2)*Mod_Constellation(c))) = Label(c);
        end
        DataLabel = squeeze(DataLabel); 

        % Data symbol collection
        ReceivedDataSymbol = ReceivedPacket(2,idxSC,TrainingTimeStep+PredictTimeStep:end);
        
        %% 2. RNN CSI Prediction
        YPred = predict(Net,XTest,'MiniBatchSize',MiniBatchSize);
        % plotPredAndValidCSI(YPred,resultVec',NumCSV,Eb_N0_dB(snr));
        EstChanGRU = CSIConverter(YPred,NumTestingSample);
        plotCSI(EstChanGRU,'CSI Channel Prediction',NumCSV,['r','b'],Eb_N0_dB(snr));
        SER_GRU(snr,i) = getSymbolDetection(ReceivedDataSymbol,EstChanGRU,Mod_Constellation,Label,DataLabel);
        RMSE = getRMSE(EstChanGRU,EstChanLS(PredictTimeStep+TrainingTimeStep:end));
        % SER_GRU(PredictTimeStep,i) = getSymbolDetection(ReceivedDataSymbol,EstChanGRU,Mod_Constellation,Label,DataLabel);
    end
end

% close(f);

SER_GRU = mean(SER_GRU,2).';

figure();
semilogy(Eb_N0_dB,SER_GRU,'r-o','LineWidth',2,'MarkerSize',10);hold off;
% plot(Eb_N0_dB,SER_GRU,'r-o','LineWidth',2,'MarkerSize',10);
title('Data Detection');
legend('Gate Reccurnet Units (GRU)');
xlabel('Es/N0 (dB)');
ylabel('Symbol error rate (SER)');
ax = gca;
ax.YRuler.Exponent = 0;

% figure();
% % semilogy(Eb_N0_dB,SER_GRU,'r-o','LineWidth',2,'MarkerSize',10);hold off;
% plot(predictTimeStep,SER_GRU,'r-o','LineWidth',2,'MarkerSize',10);
% title('Data Detection');
% legend('Gate Reccurnet Units (GRU)');
% xlabel('Predict Index');
% ylabel('Symbol error rate (SER)');
% ax = gca;
% ax.YRuler.Exponent = 0;

%% Detection Functions

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

function EstChanGRU = CSIConverter(PredictedCSI,NumTestingSample)
% This function is to reconstruct and denormalized the CSI from GRU prediction to complex-valued

    load('Normalized.mat');
    EstChanGRU = zeros(NumTestingSample,1);
    CSI = cell2mat(PredictedCSI);
    
    for n = 1:NumTestingSample
        CSI_Real = CSI(n*2-1) * RealData_STD + RealData_MEAN;
        CSI_Imag = CSI(n*2) * ImagData_STD + ImagData_MEAN;
       EstChanGRU(n) = complex(CSI_Real,CSI_Imag);
    end

end
 
function RMSE = getRMSE(YPred, YValid)

    Real = real(YPred) - real(YValid);
    Imag = imag(YPred) - imag(YValid);
    MSE = mean(Real.^2+Imag.^2);
    RMSE = sqrt(MSE);

end






