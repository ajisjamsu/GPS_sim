% constants.m 
clear
close all

% Testing constants
NUM_BITS = 10;
MAX_PLOT = 200;

% GPS Constants
PRN             = 2;
BITS_PER_SEC    = 50;
CHIPS_PER_BIT   = 1023;
SAMPS_PER_CHIP  = 4;

% Frequency synthesis constants
F_C     = 20000; % carrier frequency
F_SAMP  = BITS_PER_SEC * CHIPS_PER_BIT * SAMPS_PER_CHIP;
T_SAMP  = 1 / F_SAMP;
NUM_SEC = NUM_BITS / BITS_PER_SEC;

save loadconst.mat