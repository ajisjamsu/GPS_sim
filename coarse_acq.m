%% coarse_acq: execute parallel frequency search
function [cf_estimate, cp_estimate] = coarse_acq(mod_in)
%{
Inputs: BPSK modulated time-domain signal
Outputs: estimated carrier frequency and code phase estimate in samples 

    - Determine carrier frequency with FFT

For (code_phase_offset)
    - Generate C/A code with phase offset
    - Search for correlation spike
(Loop to produce results for all code phase offsets)

%}
load loadconst.mat

%% Find carrier frequency via squaring, FFT
fft_square = fft(mod_in.^2);
L = length(mod_in);

% 2 sided spectrum P2 -> one sided spectrum P1
P2 = abs(fft_square/L);
P1 = P2(1:L/2+1);
P1(1:500) = 0; % eliminate DC component
P1(2:end-1) = 2*P1(2:end-1);

freqs = F_SAMP*(0:L/2)/L;

figure; plot(freqs, P1); 
xlabel('Frequency (Hz)'); title('Modulated signal squared FFT')

% Estimate carrier frequency
[~, max_idx] = max(P1);
cf_estimate = freqs(round(max_idx/2));

%% Use carrier estimate to attempt carrier wipeoff
[ref_bits, ~] = generate_chips(1, 1);

% Time-domain vector for sine wave
num_bits    = length(mod_in)/CHIPS_PER_BIT/SAMPS_PER_CHIP;
num_seconds = 1/BITS_PER_SEC;
t_vec       = 0:T_SAMP:num_seconds-T_SAMP;
% Sine wave
carrier = sin(2*pi*cf_estimate*t_vec);
demod_in = mod_in .* carrier;

%% Cross-correlate to reveal code phase
[corr, lags] = xcorr(demod_in, ref_bits);

%figure; plot(lags, corr); title('Demodulated code cross-correlation')
%xlabel('Lag in samples'); ylabel('Code correlation');

% Estimate code phase
[~, cp_idx] = max(abs(corr));
cp_estimate = lags(cp_idx);
