%% SatChannelParam
%
% This script is to set up parameters for channel condition

%% Clear workspace

clear variables;
clear all;

%% Number of dataset
% csv = dir('data\LEO_2000\*.csv');
csv = dir('data\LEO_2000\*.csv');
NumCSV = length(csv);

%% Load STK Link Information

Fc = 28e9;
EIRP = 105.6; % dBm (STK defines EIRP = Power + Gain)
AGain = 45.6; % dBi Antenna Gain

for n = 1:NumCSV
    LinkInformation = readtable(strcat(csv(n).folder,'\',csv(n).name));
    Eb_N0_dB{n} =  mean(LinkInformation.Eb_No_dB_);
    RcvrPower_dB{n} = mean(LinkInformation.CarrierPowerAtRcvrInput_dBm_);
    PL{n} = LinkInformation.PropLoss_dB_'; % dB, fc Ghz, d meter
    DShift{n} = LinkInformation.Freq_DopplerShift_Hz_' / 1e9; % Ghz Frequency Doppler Shift
    AAngleInfo = LinkInformation.RcvrAzimuth_deg_'; % deg Azimuth Angle (Excluding Doppler Shift)
    AAngle{n} = mod((AAngleInfo + 360), 360) / 360; % Format in 2pi
    EAngleInfo = LinkInformation.RcvrElevation_deg_'; % deg Elevation Angle
    EAngle{n} = mod(EAngleInfo, 90);
end

%% Save Satellite Parameters

save('SatChannelParam.mat', 'EIRP', 'AGain', 'Fc', 'PL', 'DShift', 'AAngle', 'EAngle');
save('NoiseParam.mat','Eb_N0_dB', 'RcvrPower_dB');
save('DataIteration.mat', 'NumCSV');
