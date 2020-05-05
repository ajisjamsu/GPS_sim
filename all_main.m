clear
close all

load loadconst.mat

%% Generate test signal 
data_vec = ones(1, NUM_BITS);
[bb_in, mod_in] = generate_chips(data_vec, NUM_BITS);

% Apply frequency and phase offset
freqoff     = 0.001; %
phaseoff    = 0; %pi/4;%
rotatorvec  = exp(1.0i*2*pi*cumsum(ones(1,length(mod_in))*freqoff)+1.0i*phaseoff);

% Input signal with frequency/phase offset, NO noise
%bb_in=bb_in.*rotatorvec; 
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
%figure; plot(real(post_acq(1:MAX_PLOT))); title('Demodulated signal')


%% Carrier Tracking: recover carrier frequency
carriertrack_in = mod_in .* bb_in;
figure; plot(real(carriertrack_in(1:1000))); title('Modulated signal x PRN code')

[recovered_carrier, DDS_out] = carrier_tracking(carriertrack_in);

%post_carrier = mod_in .* recovered_carrier;
%figure; plot(real(post_carrier(1:MAX_PLOT))); title('Demodulated signal')

%% Code Tracking: 
