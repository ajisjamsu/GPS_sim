function [baseband, mod] = generate_chips(data_vec, bit_count, offset)
%% gen_chips: create chips at baseband
%{
Inputs: delay in chips/quarter-chips
Outputs: mod = modulated BPSK samples, baseband = baseband chip samples

    1) Create data bits (50 bps)
    2) Call on CA code generator to make 1ms spreading code
    3) Spread data with spreading code (1023 chips/bit)
%}

%% 1) Create data bits
load loadconst.mat

%% 2) Make spreading code and apply data
prn = 2;

% Create 1 ms of spreading code upsampled to the proper rate
goldcode_1ms = cacode(prn, SAMPS_PER_CHIP);

% Account for code phase offset

%% 3) Assemble data vector ms-by-ms, inverting for 0 data bit
ca_vec = [];

for bit_idx = 1:bit_count
   % Append 1ms of C/A code to the vector, inverted if data bit = 0
   bit_start = (bit_idx-1)*CHIPS_PER_BIT*SAMPS_PER_CHIP + 1;
   bit_end   = bit_start + CHIPS_PER_BIT*SAMPS_PER_CHIP - 1;
   ca_vec(bit_start:bit_end) = goldcode_1ms * data_vec(bit_idx);
end

% Shift to +/- 1's
ca_vec = ca_vec.*2 - 1; 

%% 4) Modulate with L1 carrier
% Time-domain vector for sine wave
t_vec   = 0:T_SAMP:bit_count/BITS_PER_SEC-T_SAMP;
% Sine wave - potentially apply CFO
carrier = sin(2*pi*F_C*t_vec);

%figure; subplot(211); plot(ca_vec(1:MAX_PLOT), 'x'); title('CA chips')
%subplot(212); plot(carrier(1:MAX_PLOT)); title('Carrier')

%% Outputs
mod = ca_vec .* carrier;
baseband = ca_vec;