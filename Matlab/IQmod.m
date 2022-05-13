function signal = IQmod(complex_IQ, Fc, Fs_IQ, Fs_wave)
% IQ modulation, implements (or simulates) upconversion in digital form. Such a procedure exists
%   in RF transceiver as an analog component. complex IQ signal is usually converted to analog 
%   using DAC in a transmitter.
% 
% Usage:
%   tx_signal = IQmod(complex_iq, fc, fs_iq, fs_wave);
%   input:
%           complex_iq -> IQ baseband signal in complex form
%           fc         -> desired carrier frequency
%           fs_iq      -> sampling frequency of baseband signal, usually the bandwidth of baseband signal,
%                         eg.: for 20MHz WiFi, the default fs is 20Msps.
%           fs_wave    -> sampling frequency of output waveform. Since the output waveform is a digital real
%                         real signal, it must be higher that (2 * fc + BW)
%   output: tx_signal  -> tx_signal in sampling frequency fs_wave
%
%

    % resample the input baseband in fs_iq to baseband in fs_wave
    upsample_baseband = resample(complex_IQ, Fs_wave, Fs_IQ);

    % perform digital IQ modulation
    baseband_len = length(upsample_baseband);
    t = 0: 1/Fs_wave: (baseband_len-1)/Fs_wave;
    signal = sqrt(2) * real(upsample_baseband .* exp(1j * 2 * pi * Fc * t));
end