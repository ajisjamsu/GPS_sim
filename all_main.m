clear
close all

load loadconst.mat

%% Generate test signal 
%data_vec = ones(1, NUM_BITS); data_vec(1:2:end) = 0;
data_vec = [1 0 1 1 1 1 0 0 1 0];
[bb_in, mod_in] = generate_chips(data_vec, NUM_BITS, CODE_OFFSET_SAMP);

% Apply frequency and phase offset
freqoff     = 5e-5; % radians
phaseoff    = 0; %pi/4;%
rotatorvec  = exp(1.0i*2*pi*cumsum(ones(1,length(mod_in))*freqoff)+1.0i*phaseoff);

% Input signal with frequency/phase offset, NO noise
mod_in=mod_in.*rotatorvec; 

figure; subplot(211);
plot(real(bb_in(1:MAX_PLOT)), 'x'); title('Baseband samples')
subplot(212);
plot(real(mod_in(1:MAX_PLOT))); title('Modulated signal')

%% Coarse Acquisition: Get estimate of carrier frequency and code phase
% Run acquisition on first ms of data
[fc_est, cp_est] = coarse_acq(mod_in(1:CHIPS_PER_BIT*SAMPS_PER_CHIP));

% Use this to attempt to bring data to baseband
t_vec       = 0:T_SAMP:NUM_SEC-T_SAMP;
carrier     = sin(2*pi*fc_est*t_vec);
post_acq    = mod_in .* carrier;
figure; plot(real(post_acq(1:MAX_PLOT))); 
title('Demodulated signal - first try after acq')

%% Carrier Tracking: recover carrier
% Multiply modulated input with reference code
% TODO: Change post_acq baseband code to code tracking loop baseband code
carriertrack_in = mod_in .* post_acq;
figure; plot(real(carriertrack_in(1:1000))); title('Modulated signal x PRN code')

[recovered_carrier, DDS_out] = carrier_tracking(carriertrack_in);

post_carrier = mod_in .* recovered_carrier;
figure; plot(real(post_carrier(1:MAX_PLOT))); 
title('Demodulated signal - using tracked carrier')

%% Code Tracking: track code phase error
[IQ_vec, cp_updated] = code_tracking(post_carrier, cp_est, data_vec);