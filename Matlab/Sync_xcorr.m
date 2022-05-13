function [rx_stf, rx_ltf, rx_data] = Sync_xcorr(cfg, rx_signal)

% Sync using cross correlation. The function finds the begining of the Data packet
%   and outputs the rx_data including rx_stf and rx_ltf.
% 
% Usage:
%   [rx_stf, rx_ltf, rx_data] = Sync_xcorr(cfg, rx_signal)
%   input:
%           cfg        -> OFDM config struct
%           rx_signal  -> baseband rx signal
%   output: bbsignal   -> complex baseband IQ signal
%
%
% Syntax: 
%
    % find the signal start position with xcorr with short training symbol
    stf_ = ifft(cfg.match_fft(cfg.stf));
    bb_stf = [stf_(1:cfg.GI), stf_];
    [xcor_val, lag] = xcorr(rx_signal, bb_stf);
    [m_val, m_ind] = max(xcor_val);
    stf_start = lag(m_ind) + 1;
    ltf_start = stf_start + cfg.stf_len;
    data_start = ltf_start + cfg.ltf_len;

    % output the rx_stf, rx_ltf and rx_data result
    len = length(rx_signal);
    if (ltf_start + cfg.ltf_len + cfg.data_len - 1 > len)
        % failed to find a complete packet, return
        rx_stf = []; rx_ltf = []; rx_data = [];
        return
    end
    rx_stf = rx_signal(stf_start:stf_start + cfg.stf_len - 1);
    rx_ltf = rx_signal(ltf_start:ltf_start + cfg.ltf_len - 1);
    rx_data = rx_signal(data_start:data_start + cfg.data_len - 1);

    % draw graph
    figure(); plot(abs(xcor_val)); title('XCorr result.');
    figure(); plot(abs(rx_signal)); hold on;
    plot(stf_start:stf_start + cfg.stf_len + cfg.ltf_len + cfg.data_len - 1, abs([rx_stf, rx_ltf, rx_data]));
    title('Extracted Signal in Rx\_sound(including stf)');
end
