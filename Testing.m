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
% load('net\sunny\NPNet.mat');
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

% Testing LEO Track CSV number
NumCSV = 2;

Eb_N0_dB_MAX = cell2mat(Eb_N0_dB(NumCSV));
RcvrPower_dB_MAX = cell2mat(RcvrPower_dB(NumCSV));
 
% Eb_N0_dB = Eb_N0_dB_MAX;
Eb_N0_dB = Eb_N0_dB_MAX-20:2:Eb_N0_dB_MAX; % Es/N0 in dB
Eb_N0 = 10.^(Eb_N0_dB./10);
RcvrPower = 10.^(RcvrPower_dB_MAX./10);
NoiseVar = RcvrPower./Eb_N0;

%% Testing data size

NumPacket = 45000; % Number of packets simulated per iteration

%% Simulation

% Same pilot sequences used in training and testing stages
FixedPilotAll = repmat(FixedPilot,1,1,NumPacket); 

% Number of Monte-Carlo iterations
NumIter = 1;

% Initialize error rate vectors
SER_GRU = zeros(length(NoiseVar),NumIter);
NMSE_GRU = zeros(length(NoiseVar),NumIter);

% f = waitbar(1/NumIter,sprintf('Operating iteration %d/%d',i,length(Eb_N0_dB)),'Name','Processing Channel Prediction...');

for i = 1:NumIter
%    for PredictTimeStep = predictTimeStep
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
        
        % plotCSI(EstChanLS(TrainingTimeStep+1:end),'CSI Ground Truth',NumCSV,['m','c'],Eb_N0_dB(snr));
        
        % load("GroundTruth.mat");
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
        % plotCSI(EstChanGRU,'CSI Channel Prediction',NumCSV,['r','b'],Eb_N0_dB(snr));
        SER_GRU(snr,i) = getSymbolDetection(ReceivedDataSymbol,EstChanGRU,Mod_Constellation,Label,DataLabel);
        % RMSE = getRMSE(EstChanGRU,EstChanLS(PredictTimeStep+TrainingTimeStep:end));
        % plotCompare(EstChanLS,EstChanGRU,'CSI Comparison',[[0,0,0];[0.5,0.5,0.5];[0 0 1];[0.5 0.5 1]],Eb_N0_dB(snr),NumCSV)
        NMSE_GRU(snr,i) = getNMSE(EstChanGRU,EstChanLS(PredictTimeStep+TrainingTimeStep:end));
    end
end
% SER_GRU = mean(SER_GRU,2).';
NMSE_GRU = mean(NMSE_GRU,2).';
% load("SERLSTM.mat");
load("NMSELSTM.mat");


% figure();
% % semilogy(Eb_N0_dB,SER_LSTM,'r-o','LineWidth',1,'MarkerSize',8);hold on;
% semilogy(Eb_N0_dB,SER_GRU,'b-o','LineWidth',1,'MarkerSize',8);hold on;
% title('Rural Scenario','Interpreter','latex');
% % legend('Self-Training','Interpreter','latex');
% % legend('wrong prediction model');
% % legend('Self-Training','Reusable','Interpreter','latex');
% % legend('GRU with Elevation Angle','Interpreter','latex');
% % legend('APF-RNS','Gate Recurrent Units (GRU)','GRU with Elevation Angle','Interpreter','latex');
% legend('Training on Track 1 Predict on Track 2','Interpreter','latex');
% xlabel('Eb/N0 (dB)');
% ylabel('Symbol Error Rate (SER)');
% % ax = gca;
% % ax.YRuler.Exponent = 0;

figure();
% semilogy(Eb_N0_dB,NMSE_LSTM,'r-o','LineWidth',1,'MarkerSize',8);hold on;
semilogy(Eb_N0_dB,NMSE_LSTM,'r-*','LineWidth',1,'MarkerSize',8);hold on;
% semilogy(Eb_N0_dB,NMSE_GRU,'b-o','LineWidth',1,'MarkerSize',8);hold on;
% semilogy(Eb_N0_dB,NMSE_GRU,'g-o','LineWidth',1,'MarkerSize',8);hold on;
semilogy(Eb_N0_dB,NMSE_GRU,'g-*','LineWidth',1,'MarkerSize',8);hold on;
% title('NMSE of Reusability on Different Sign of CSI','Interpreter','latex');
title('Dense Urban Rainy Condition','Interpreter','latex');
% legend('APF-RNS','Gate Recurrent Units (GRU)','Interpreter','latex');
% legend('APF-RNS','Gate Recurrent Units (GRU)','GRU with Elevation Angle','Interpreter','latex');
% legend('APF-RNS-Sunny','ECOCSI-Sunny','ECOCSI-Rainy','ECOCSI-Sunny-Rainy','APF-RNS-Sunny-Rainy','Interpreter','latex');
legend('APF-RNS-Sunny-Rainy','ECOCSI-Sunny-Rainy','Interpreter','latex');
% xlabel('Eb/N0 (dB)');
% ylabel('Normalized Mean Square Error (NMSE)');

% figure();
% semilogy(NMSE(:,1),NMSE(:,2),'b-o','LineWidth',1,'MarkerSize',8);hold on;
% title('NMSE of Reusable Model on Different Altitude','Interpreter','latex');
% % legend('GRU LEO 500km','Interpreter','latex','Location','Northwest');
% xlabel('Altitude (km)');
% ylabel('Normalize Mean Square Error (NMSE)');


% figure();
% semilogy(Eb_N0_dB,SER_GRU,'r-o','LineWidth',2,'MarkerSize',10);
% title('Data Detection');
% legend('Gate Reccurnet Units (GRU)');
% xlabel('Predict Index');
% ylabel('Symbol error rate (SER)');
% ax = gca;
% ax.YRuler.Exponent = 0;

% legend('Self-Training','Offline','Interpreter','latex');

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

    orgSig = zeros(size(YValid,1)*2,1);
    recSig = zeros(size(YPred,1)*2,1);
    
    orgSig(1:2:end) = real(YValid);
    orgSig(2:2:end) = imag(YValid);
    recSig(1:2:end) = real(YPred);
    recSig(2:2:end) = imag(YPred);
    
    RMSE = sqrt(mean((orgSig - recSig).^2));

end

function NMSE = getNMSE(YPred,YValid,varargin)
    
    orgSig = zeros(size(YValid,1)*2,1);
    recSig = zeros(size(YPred,1)*2,1);
    
    orgSig(1:2:end) = real(YValid);
    orgSig(2:2:end) = imag(YValid);
    recSig(1:2:end) = real(YPred);
    recSig(2:2:end) = imag(YPred);
    
    if isempty(varargin)
        boun = 0;
    else boun = varargin{1};
    end
    if size(orgSig,2)==1       % if signal is 1-D
        orgSig = orgSig(boun+1:end-boun,:);
        recSig = recSig(boun+1:end-boun,:);
    else                       % if signal is 2-D or 3-D
        orgSig = orgSig(boun+1:end-boun,boun+1:end-boun,:);
        recSig = recSig(boun+1:end-boun,boun+1:end-boun,:);
    end
    MSE=norm(orgSig(:)-recSig(:))^2/length(orgSig(:));
    sigEner=norm(orgSig(:))^2;
    NMSE=(MSE/sigEner);
end






