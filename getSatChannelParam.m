%% SatChannelParam
%
% This script is to set up parameters for LEO satellite channel condition

%% Clear workspace

clear all;
close all;

%% Number of dataset

csv = dir('data\LEO_500\*.csv');
% csv = dir('data\LEO_500_V\*.csv');
% csv = dir('data\LEO_500_H\*.csv');
% csv = dir('data\LEO_600\*.csv');
% csv = dir('data\LEO_700\*.csv');
% csv = dir('data\LEO_800\*.csv');
% csv = dir('data\LEO_1000\*.csv');
% csv = dir('data\LEO_1500\*.csv');
% csv = dir('data\LEO_2000\*.csv');
% csv = dir('dataCloudAndFog\LEO_500\*.csv');
% csv = dir('dataRain\LEO_500\*.csv');
% csv = dir('dataExtra\LEO_500\*.csv');
% csv = dir('dataExtra\DTrack\H\*.csv');
% csv = dir('dataExtra\revolution\LinkInformation_LEO_4.csv');
NumCSV = length(csv);

%% Load STK Link Information

Fc = 28;        % Ghz, Carrier Frequency
EIRP = 105.6;   % dBm (STK defines EIRP = Power + Antenna Gain)
AGain = 45.6;   % dBi Antenna Gain

for n = 1:NumCSV
    LinkInformation = readtable(strcat(csv(n).folder,'\',csv(n).name));
    Eb_N0_dB{n} =  mean(LinkInformation.Eb_No_dB_);                         % dB, SNR
    RcvrPower_dB{n} = mean(LinkInformation.CarrierPowerAtRcvrInput_dBm_);   % dB, Receiver Carrier Power
    DShift = LinkInformation.Freq_DopplerShift_Hz_' / 1e9;                  % GHz, Doppler Shift
    RainLoss = LinkInformation.RainLoss_dB_';                               % dB, Rain Loss
    CloudLoss = LinkInformation.CloudsFogLoss_dB_';                         % dB, Cloud Loss
    Range = LinkInformation.Range_km_' * 1e3;                               % m, Slant Range
    PL{n} = 32.45 + 20*log10(Fc+DShift) + 20*log10(Range) + RainLoss;       % dB, Propagation Loss, fc Ghz, d meter
    AAngleInfo = LinkInformation.RcvrAzimuth_deg_';                         % deg Azimuth Angle (Excluding Doppler Shift)
    AAngle{n} = mod((AAngleInfo + 360), 360) / 360;                         % Format in 2pi
    EAngleInfo = LinkInformation.RcvrElevation_deg_';                       % deg Elevation Angle
    EAngle{n} = mod(abs(EAngleInfo-90), 90);
end

%% Save Satellite Parameters

save('SatChannelParam.mat','EIRP','AGain','Fc','PL','AAngle','EAngle');
save('NoiseParam.mat','Eb_N0_dB', 'RcvrPower_dB');
save('EAngle.mat','EAngle');
