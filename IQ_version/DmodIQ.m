function complex_IQ = DmodIQ(signal, Fc, Fs, sim_rate)
    %
    % Syntax: Tx_data = OFDM(bits)
    %
    len = length(signal);
    t = 0:1/Fs:(len-1)/Fs;
    I = cos(2 * pi * Fc * t);
    Q = cos(2 * pi * Fc * t - pi / 2);
    complex_IQ = signal .* I + i * signal .* Q;
end
    