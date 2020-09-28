function [ShadowFading] = SF(Scenario,EAngle)
% This function is to
%  1. simulate shadow fading as Markov chain process
%  2. return shadow fading as dB
%
%  The differentirated received signal amplitude level is related to the
%  underlying signal propagation condition, divided into three scenario.

persistent currentLOSState;
if isempty(currentLOSState)
    currentLOSState = LOSState.LOS;
end

% State probability transition matrix (SPTM)
LOSProb = [0.782 0.869 0.919 0.929 0.935 0.940 0.949 0.952 0.998;   % suburban and rural scenario
           0.246 0.386 0.493 0.613 0.726 0.805 0.919 0.968 0.992;   % urban scenario
           0.282 0.331 0.398 0.468 0.537 0.612 0.738 0.820 0.981;]; % dense urban scenario
         
% LOS Shadow Fading in Ka-band (dB)
SFLOS = [1.9 1.6 1.9 2.3 2.7 3.1 3.0 3.6 0.4;               % suburban and rural scenario
         4 4 4 4 4 4 4 4 4;                                 % urban scenario
         2.9 2.4 2.7 2.4 2.4 2.7 2.6 2.8 0.6;];             % dense urban scenario

% NLOS Shadow Fading in Ka-band (dB)
SFNLOS = [10.7 10.0 11.2 11.6 11.8 10.8 10.8 10.8 10.8;     % suburban and rural scenario
          12 12 12 12 12 12 12 12 12;                                % urban scenario
          17.1 17.1 15.6 14.6 14.2 12.6 12.1 12.3 12.3;];   % dense urban scenario

% NLOS Clutter Loss in Ka-band (dB)
CL = [29.5 24.6 21.9 20.0 18.7 17.8 17.2 16.9 16.8;         % suburban and rural scenario
      44.3 39.9 37.5 35.8 34.6 33.8 33.3 33.0 32.9;         % urban scenario
      44.3 39.9 37.5 35.8 34.6 33.8 33.3 33.0 32.9;];       % dense urban scenario
         
% Elevation Angle offset
EAngleOffset = fix(EAngle/10) + 1;

%% Rand Probability Procedure
r = rand();

if r < LOSProb(Scenario, EAngleOffset)
        currentLOSState = LOSState.LOS;
        fprintf("LOS %d\n",EAngleOffset-1)
else
        currentLOSState = LOSState.NLOS;
        fprintf("NLOS %d\n",EAngleOffset-1)
end

% currentLOSState = LOSState.LOS;

if currentLOSState == LOSState.LOS
    ShadowFading = SFLOS(Scenario,EAngleOffset);
elseif currentLOSState == LOSState.NLOS
    ShadowFading = SFNLOS(Scenario, EAngleOffset);
end