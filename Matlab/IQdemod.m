function rx_iq = IQdemod(signal, Fc, Fs_IQ, Fs_wave)
% IQ demodulation, implements (or simulates) downconversion in digital form. Such a procedure exists in
%   RF transceiver as an analog component. analog RF signal is usually downconverted using
%   mixers and sampled using ADCs in a receiver.
% 
% Usage:
%   rx_iq = IQdemod(signal, fc, fs_iq, fs_wave);
%   input:
%           signal -> received signal
%           fc     -> carrier frequency
%           fs_iq      -> sampling frequency of baseband signal, usually the bandwidth of baseband signal,
%                         eg.: for 20MHz WiFi, the default fs is 20Msps.
%           fs_wave    -> sampling frequency of output waveform. Since the output waveform is a digital real
%                         real signal, it must be higher that (2 * fc + BW)
%   output: rx_iq  -> received IQ complex signal
%
%

    % perform digital IQ demodulation
    len = length(signal);
    t = 0: 1/Fs_wave: (len-1)/Fs_wave;
    baseband_wave = signal .* (sqrt(2) * exp(-1j * 2 * pi * Fc * t));

    % perform low pass filter
    lowpass_baseband = lowpass(baseband_wave, Fs_IQ, Fs_wave);
    % resample the input baseband in fs_wave to baseband in fs_iq
    rx_iq = resample(lowpass_baseband, Fs_IQ, Fs_wave);
end