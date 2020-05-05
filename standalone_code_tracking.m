%% EPL: A single pass of the EPL code tracking loop
% function [IQ_vec, cp_est] = code_tracking(mod_in)
%{
Inputs: carrier signal, previous code loop phase
Outputs: prompt tap I/Q vector, code phase

    1) Demodulate input signal on I, Q channels

    2)  - Create reference code, delayed by 1, 2 samples
        - For each of I/Q channels, multiply by E/P/L
        - MATLAB Integrate and dump, send results to discriminator

    3) Discriminator: produce code phase 

            (I_e^2 + Q_e^2) - (I_l^2 + Q_l^2)
        D = ----------------------------------
            (I_e^2 + Q_e^2) + (I_l^2 + Q_l^2)

%}
clear
close all

load loadconst.mat

% Generate test signal 
data_vec = ones(1, NUM_BITS);
data_vec(1:2:end) = 0;
[~, mod_in] = generate_chips(data_vec, NUM_BITS, 8);

% Apply frequency and phase offset
freqoff     = 0.001; %
phaseoff    = pi/8; %pi/4;
rotatorvec  = exp(1.0i*2*pi*cumsum(ones(1,length(mod_in))*freqoff)+1.0i*phaseoff);

% Input signal with frequency/phase offset, NO noise
mod_in=mod_in.*rotatorvec; 

%input: code loop phase
[fc_est, cp_est] = coarse_acq(mod_in(1:CHIPS_PER_BIT*SAMPS_PER_CHIP));

%% 1) Demodulate input on I/Q channels

% Demodulate signal to isolate code
% TODO: Change to carrier tracking loop output
% For now, this is a baseband version of the input data.
demod_sig_full = generate_chips(data_vec, NUM_BITS, cp_est);
demoe_sig_full = demod_sig_full.*rotatorvec; 

nsamp       = CHIPS_PER_BIT*SAMPS_PER_CHIP;
num_dumps   = length(demod_sig_full)/nsamp;

IQ_vec = [];

for dump_idx = 1:num_dumps
    start_dump  = (dump_idx-1)*nsamp + 1;
    end_dump    = dump_idx*nsamp;
    demod_sig   = demod_sig_full(start_dump:end_dump);
    demod_I = real(demod_sig);
    demod_Q = imag(demod_sig);

    % 2) Run EPL
    % Generate reference codes
    ref_code_E  = generate_chips(1, 1, round(cp_est)-1);
    ref_code_P  = generate_chips(1, 1, round(cp_est));
    ref_code_L  = generate_chips(1, 1, round(cp_est)+1);

    % Multiply by demodulated signal
    signal_I_E = demod_I .* ref_code_E;
    signal_I_P = demod_I .* ref_code_P;
    signal_I_L = demod_I .* ref_code_L;

    signal_Q_E = demod_Q .* ref_code_E;
    signal_Q_P = demod_Q .* ref_code_P;
    signal_Q_L = demod_Q .* ref_code_L;

    % Integrate and dump
    I_e = intdump(signal_I_E, nsamp);
    I_p = intdump(signal_I_P, nsamp);
    I_l = intdump(signal_I_L, nsamp);

    Q_e = intdump(signal_Q_E, nsamp);
    Q_p = intdump(signal_Q_P, nsamp);
    Q_l = intdump(signal_Q_L, nsamp);

    % 3) Discriminator: produce code phase 
    D = (I_e.^2+Q_e.^2)-(I_l.^2+Q_l.^2) / (I_e.^2+Q_e.^2)+(I_l.^2+Q_l.^2);    
    cp_est = round(cp_est) + D;
    
    % Log the prompt I/Q
    IQ_prompt = I_p + 1.0i*Q_p;
    IQ_vec(dump_idx) = IQ_prompt;
end
cp_est = round(cp_est);

% Plot data vector and prompt I tap
figure; subplot(211); stem(data_vec); title('Expected bits');
subplot(212); stem(real(IQ_vec)); title('Prompt tap I value');





