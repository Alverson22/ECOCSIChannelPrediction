%% SatChannelParam
%
% This script is to set up parameters for channel condition

%% Clear workspace

clear variables;
clear all;

%% Load STK Link Information
LinkInformation = readtable('data\LinkInformation_LEO_1.csv');
% NumPacket = size(LinkInformation, 1);
Fc = 28e9;
% EIRP = LinkInformation.EIRP_dBm_(1); % dBm
EIRP = 59.5; % dBm 
AGain = 45.6; % dBi Antenna Gain (STK) [19]
FSPL = LinkInformation.FreeSpaceLoss_dB_'; % dB fc Ghz, d meter
DShift = LinkInformation.Freq_DopplerShift_Hz_' / 1e9; % Ghz Frequency Doppler Shift
% Doppler shift need to be considered in Phase Shift
AAngle = LinkInformation.RcvrAzimuth_deg_'; % deg Azimuth Angle (Excluding Doppler Shift)
AAngle = mod((AAngle + 360), 360) / 360; % Format in 2pi
EAngle = LinkInformation.RcvrElevation_deg_'; % deg Elevation Angle
EAngle = mod(EAngle, 90);

%% Save Satellite Parameters

save('SatChannelParam.mat', 'EIRP', 'AGain', 'Fc', 'FSPL', 'DShift', 'AAngle', 'EAngle');
