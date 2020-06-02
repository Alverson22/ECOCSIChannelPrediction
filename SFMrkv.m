function [ShadowFading] = SFMrkv(EAngle, isLOS)
% This function is to
%  1. simulate shadow fading as Markov chain process
%  2. return shadow fading as fB
%
%  The differentirated received signal amplitude level is related to the
%  underlying signal propagation condition, divided into good, moderate, and
%  bad state.

% State = ["good", "moderate", "bad"]
persistent currentState;
if isempty(currentState)
    currentState = State.good;
end

% State probability transition matrix (SPTM)
transProb = [0.996402 0.003375 0.000233;
             0.027765 0.970755 0.00148;
             0.002668 0.013607 0.983725];
         
% LOS Shadow Fading in Ka-band (dB)
SFLOS = [1.9 1.6 1.9 2.3 2.7 3.1 3.0 3.6 0.4; % good state in suburban and rural
         4 4 4 4 4 4 4 4 4;                   % moderate state in urban scenario
         2.9 2.4 2.7 2.4 2.4 2.7 2.6 2.8 0.6];% bad state in dense urban scenario

% NLOS Shadow Fading in Ka-band (dB)
SFNLOS = [10.7 10.0 11.2 11.6 11.8 10.8 10.8 10.8 10.8; % good state in suburban and rural
          6 6 6 6 6 6 6 6 6;                            % moderate state in urban scenario
          17.1 17.1 15.6 14.6 14.2 12.6 12.1 12.3 12.3];% bad state in dense urban scenario
         
% Elevation Angle offset
EAngleOffset = fix(EAngle/10) + 1;

% Visualize Markov Chain
% mc = dtmc(transProb, 'StateNames', State);
% figure;
% graphplot(mc, 'ColorEdges', true);

%% Markov Chain Procedure
currentDistribution = transProb(currentState+1,:);
cumDistribution = cumsum(currentDistribution);

r = rand();

switch find(cumDistribution>r,1)
    case 1
        currentState = State.good;
        disp("good");
    case 2
        currentState = State.moderate;
        disp('moderate');
    case 3
        currentState = State.bad;
        disp("bad");
end

if isLOS
    ShadowFading = SFLOS(currentState+1, EAngleOffset);
else
    ShadowFading = SFNLOS(currentState+1, EAngleOffset);
end