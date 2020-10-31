function Rx_data = Sync(con_pre, con, Rx_sound)
%
% Syntax: desire_data = Sync(Rx_signal, config)
%
    preamble_len = con_pre.symbol_per_carrier * (con_pre.IFFT_length + con_pre.GI) + con_pre.GIP;
    data_len = con.symbol_per_carrier * (con.IFFT_length + con.GI) + con.GIP;   
    Preamble = OFDM(con_pre, con.preamble);
    [xcor_val, lag] = xcorr(Rx_sound, Preamble);
    [m_val, m_ind] = max(xcor_val);
    sam_start = lag(m_ind) + preamble_len * 2 + 1;
    % fprintf("No Preamble Found...\n");
    Rx_data = Rx_sound(sam_start:sam_start + data_len - 1);
end
