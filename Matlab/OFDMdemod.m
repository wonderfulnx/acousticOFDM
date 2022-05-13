function [rx_bits, rx_subcarriers, channel] = OFDMdemod(cfg, rx_bbltf, rx_bbdata)
% OFDM demodulation, outputs bit information and corresponding complex matrix 
%   in frequency domain.
% 
% Usage:
%   [rx_bits, rx_subcarriers] = OFDMdemod(cfg, rx_bbltf, rx_bbdata);
%   input:
%           cfg            -> OFDM config struct
%           rx_bbltf       -> long training field baseband signal
%           rx_bbdata      -> data field baseband signal
%   output: rx_bits        -> decoded bits information
%           rx_subcarriers -> received complex matrix in frequency domain
%

% ======================== Deserialization =========================
    rx_bbdata_mat_cp = reshape(rx_bbdata, cfg.fft_length + cfg.GI, cfg.symbol_num).';

% ========================== Remove CP ==========================
    rx_bbdata_mat = rx_bbdata_mat_cp(:, cfg.GI + 1:cfg.GI + cfg.fft_length);

% ============================ FFT ==============================
    Y = fft(rx_bbdata_mat, cfg.fft_length, 2);
    rx_ltf = fft(rx_bbltf(cfg.GI + 1:cfg.GI + cfg.fft_length), cfg.fft_length);
    rx_subcarriers = Y(:, cfg.subcarriers);

% ======================= Channel Estimation ====================
    tx_ltf = cfg.match_fft(cfg.ltf);
    channel = rx_ltf(cfg.subcarriers) ./ tx_ltf(cfg.subcarriers);

% ====================== Channel Compensation ===================
    for i = 1:cfg.symbol_num
        rx_subcarriers(i, :) = rx_subcarriers(i, :) ./ channel;
    end

% ======================== Demodulation ========================
    rx_serial_symbols = reshape(rx_subcarriers.', 1, cfg.symbol_num * cfg.subcarrier_count).';

    if cfg.mcs == 0
        rx_bits = BPSKdemod(rx_serial_symbols, cfg.d);
    elseif cfg.mcs == 1
        rx_bits = QPSKdemod(rx_serial_symbols, cfg.d);
    elseif cfg.mcs == 2
        rx_bits = QAM16demod(rx_serial_symbols, cfg.d);
    end
end
