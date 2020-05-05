%% carrier_tracking: a single pass of the 2nd order carrier PLL
function [mixsampvec, DDSvec] = carrier_tracking(RxdSignal)
%{
Inputs: signal input
Outputs: corrected carrier

    1) Use prompt I/Q in atan discriminator to produce phase
    
    2) Use discriminator output to feed loop filter

    3) Control oscillator with loop filter adjustment
%}
load loadconst.mat

%RxdSignal = RxdSignal(1:4:end);
NumSymbols = length(RxdSignal);

%% LOOP FILTER PARAMETERS
SampRate	= 1;
Cutoff		= 0.004;
damp		= 0.707;
w_n			= (2*pi*Cutoff)/sqrt(1+2*damp^2+sqrt(2+4*damp^2+4*damp^4));
Ki			= (w_n/SampRate)^2;
Kp			= (2*damp*w_n/SampRate);

mixsampvec	= zeros(1,NumSymbols); % mixed samples 
errsigvec	= mixsampvec; % vector to save output of discriminator
DDSvec      = mixsampvec; % PLL synthesis output

KiFilt			= 0;
DDSaccum		= 0;
localDDS		= 1;

% LOOP: loop through symbols
for idx=1:NumSymbols

    % Mix received sample with local digital synthesis (conj)
    mixsamp=RxdSignal(idx)*conj(localDDS);
    mixsampvec(idx)=mixsamp;

    % Split I/Q of mixed sample
    real_arm=real(mixsamp);
    imag_arm=imag(mixsamp);

    % Calculate error signal
    % TODO: Change to atan2 discriminator? D = atan2(Q_in, I_in);
    errsig=sign(real_arm)*imag_arm;
    errsigvec(idx)=errsig;

    % Add error signal to Kifilt
    KiFilt=KiFilt+errsig;

    % Filter error sig based off Ki, Kifilt and Kp
    errsig_filt=Ki*KiFilt+Kp*errsig;

    DDSaccum=DDSaccum+errsig_filt;
    localDDS=exp(1.0i*DDSaccum);
    DDSvec(idx) = localDDS;

end

figure; subplot(211); plot(errsigvec(1:1200)); title('Carrier error signal'); 
subplot(212); plot(real(mixsampvec(1:1200))); title('Tracked carrier');