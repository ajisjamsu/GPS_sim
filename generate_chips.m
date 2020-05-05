function [baseband, mod] = generate_chips(data_vec, bit_count, offset)
%% gen_chips: create chips at baseband
%{
Inputs: data vector, number of data bits, correlation peak offset in samps
Outputs: mod = modulated BPSK samples, baseband = baseband chip samples

    1) Create data bits (50 bps)
    2) Call on CA code generator to make 1ms spreading code
    3) Spread data with spreading code (1023 chips/bit)
%}
if nargin<3
  offset = 0;
end

%% 1) Create data bits
load loadconst.mat

%% 2) Make spreading code and apply data

% Create 1 ms of spreading code upsampled to the proper rate
goldcode_1ms = cacode(PRN, SAMPS_PER_CHIP);

%% 2A) Account for code phase offset
% Generate code phase offset with xcorr(input_sig, reference_cacode)
% Resulting correlation offset:
% If offset = POSITIVE, shift gold code RIGHT by [offset] samples
% If offset = NEGATIVE, shift gold code LEFT
goldcode_1ms = circshift(goldcode_1ms, offset);
goldcode_1ms = goldcode_1ms.*2 - 1;

%% 3) Assemble data vector ms-by-ms, inverting for 0 data bit
ca_vec = [];
data_vec = data_vec.*2 - 1;

for bit_idx = 1:bit_count
   % Append 1ms of C/A code to the vector, inverted if data bit = 0
   bit_start = (bit_idx-1)*CHIPS_PER_BIT*SAMPS_PER_CHIP + 1;
   bit_end   = bit_start + CHIPS_PER_BIT*SAMPS_PER_CHIP - 1;
   ca_vec(bit_start:bit_end) = goldcode_1ms * data_vec(bit_idx);
end



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