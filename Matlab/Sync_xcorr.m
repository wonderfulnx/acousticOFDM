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
    preamble_start = lag(m_ind) + 1;
    data_start = preamble_start + preamble_len;

    % output the Rx_data result
    len = length(Rx_sound);
    if (data_start + data_len - 1 > len)
        % add zero for the rest data
        Rx_data = zeros(1, data_len);
        Rx_data(1:len - data_start + 1) = Rx_sound(data_start:len);
    else
        Rx_data = Rx_sound(data_start:data_start + data_len - 1);
    end

    % draw graph
    Rx_preamble = Rx_sound(preamble_start:data_start - 1);
    figure(); plot(xcor_val); title('XCorr result.');
    figure(); plot(Rx_sound); hold on;
    plot(preamble_start:preamble_start + preamble_len + data_len - 1, [Rx_preamble, Rx_data]);
    title('Extracted Signal in Rx\_sound(including Preamble)');
end
