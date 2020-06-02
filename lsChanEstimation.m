%% Least Square Estimation
function [EstChanLS] = lsChanEstimation(ReceivedData,PilotSeq,NumPilot,NumSC,idxSC)
% This function is to perform LS and MMSE channel estimations using pilot
% symbols, second-order statistics of the channel and noise variance [1].

% [1] O. Edfors, M. Sandell, J. -. van de Beek, S. K. Wilson and 
% P. Ola Borjesson, "OFDM channel estimation by singular value 
% decomposition," VTC, Atlanta, GA, USA, 1996, pp. 923-927 vol.2.


PilotSpacing = NumSC/NumPilot;

%%%%%%%%%%%%%%% LS estimation with interpolation %%%%%%%%%%%%%%%%%%%%%%%%%

H_LS = ReceivedData(1:PilotSpacing:NumSC)./PilotSeq;
H_LS_interp = interp1(1:PilotSpacing:NumSC,H_LS,1:NumSC,'linear','extrap');
H_LS_interp = H_LS_interp.';

%%%%%%%%%%%%%%% Channel coefficient on the selected subcarrier %%%%%%%%%%%

EstChanLS = H_LS_interp(idxSC);

end