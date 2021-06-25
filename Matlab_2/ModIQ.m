function signal = ModIQ(complex_IQ, Fc, Fs, sim_rate)
    %
    % Syntax: Tx_data = OFDM(bits)
    %
    len = length(complex_IQ);
    t = 0:1/Fs:(len-1)/Fs;
    I = cos(2 * pi * Fc * t);
    Q = cos(2 * pi * Fc * t - pi / 2);
    signal = real(complex_IQ).*I + imag(complex_IQ).*Q;
end