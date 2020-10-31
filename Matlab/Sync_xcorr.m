function Rx_data = Sync(con_pre, con, Rx_sound)
%
% Syntax: desire_data = Sync(Rx_signal, config)
%
    preamble_len = con_pre.symbol_per_carrier * (con_pre.IFFT_length + con_pre.GI) + con_pre.GIP;
    data_len = con.symbol_per_carrier * (con.IFFT_length + con.GI) + con.GIP;

    % find the signal start position with xcorr with Preamble
    Preamble = OFDM(con_pre, con.preamble);
    [xcor_val, lag] = xcorr(Rx_sound, Preamble);
    [m_val, m_ind] = max(xcor_val);
    sam_start = lag(m_ind) + preamble_len + 1;

    plot(xcor_val);
    len = length(Rx_sound);
    if (sam_start + data_len - 1 > len)
        % add zero for the rest data
        Rx_data = zeros(1, data_len);
        Rx_data(1:len - sam_start + 1) = Rx_sound(sam_start:len);
    else
        Rx_data = Rx_sound(sam_start:sam_start + data_len - 1);
    end
end
