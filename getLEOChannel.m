function ReceivedPacket = getLEOChannel(Scenario,TransmittedFrame,LengthCP,h,NoiseVar,NumCSV)
% This function is to model the transmission and reception process in OFDM systems. 

% Extract parameters
[NumSym,NumSC,NumPacket] = size(TransmittedFrame);
load('SatChannelParam.mat');
%% Extract data

PL = cell2mat(PL(NumCSV));
AAngle = cell2mat(AAngle(NumCSV));
EAngle = cell2mat(EAngle(NumCSV));

%% Transmitter

% Channel model h(t) = h1(FPSL) x h2(Markov) x h3(small-scale fading)

% Phase shift effect with frequency Doppler shift
PhaseShift = exp(-1j*(AAngle(1:NumPacket))*2*pi); % Phase Shift (including Doppler effect, fd=1/2pi*phi/deltat, phi denotes the phase shift)
% plotPhase(PhaseShift);
isLOS = false; % Line Of Sight will be random in the realistic environment

for p = 1:NumPacket
                                  
    % 1. IFFT
    x1 = ifft(TransmittedFrame(:,:,p),NumSC,2); 
    
    % 2. Inserting CP
    x1_CP = [x1(:,NumSC-LengthCP+1:end) x1]; % CP is the last 16 symbol of x1
        
    % 3. Parallel to serial transformation
    x2 = x1_CP.';
    x = x2(:);
    
    % 4. Adding Free Space Path loss and Shadow Fading
    % pathloss = PL(p) - AGain;
    pathloss = PL(p) + SF(Scenario, EAngle(p)) - AGain;
    variance = 10^(-pathloss/10);
    h_PL = sqrt(variance/2) * h;
    
    % 5. Channel filtering (Channel Condition)
    y_conv = conv(h_PL*PhaseShift(p), x);
    y(:,p) = y_conv(1:length(x));
end 
                        
%% Adding noise 

SeqLength = size(y,1);

NoiseF = sqrt(NoiseVar/2).*(randn(NumPacket,NumSC)+1j*randn(NumPacket,NumSC)); % Frequency-domain noise
NoiseT = sqrt(SeqLength)*sqrt(SeqLength/NumSC)*ifft(NoiseF,SeqLength,2); % Time-domain noise
NoiseT = NoiseT.';
% Adding noise
y = y+NoiseT; 


%% Receiver

ReceivedPacket = zeros(NumPacket,NumSym,NumSC); 
    
for p = 1:NumPacket
     
    % 1. Serial to parallem transformation
    y1 = reshape(y(:,p),NumSC+LengthCP,NumSym).'; 

    % 2. Removing CP
    y2 = y1(:,LengthCP+1:LengthCP+NumSC);

    % 3. FFT, # x NymSym x 64
    Received = fft(y2,NumSC,2);
    ReceivedPacket(p,:,:) = Received; % NumSym x 64  
end 

ReceivedPacket = permute(ReceivedPacket,[2,3,1]); 




