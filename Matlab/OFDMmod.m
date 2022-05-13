function bbsignal = OFDMmod(cfg, bits)
% OFDM modulation, outputs baseband complex information.
% 
% Usage:
%   bbsignal = OFDMmod(cfg, bits);
%   input:
%           cfg        -> OFDM config struct
%           bits       -> bit data vector (row)
%   output: bbsignal   -> complex baseband IQ signal
%

% ========================== Coding ===========================
    if cfg.mcs == 0
        complex_data = BPSKmod(bits, cfg.d);
    elseif cfg.mcs == 1
        complex_data = QPSKmod(bits, cfg.d);
    elseif cfg.mcs == 2
        complex_data = QAM16mod(bits, cfg.d);
    end
    complex_mat = reshape(complex_data.', cfg.subcarrier_count, cfg.symbol_num).';

%% =========================== IFFT ============================
% ---------------- Include long training symbol ----------------
    IFFT_mod = zeros(cfg.symbol_num + 1, cfg.fft_length);
    IFFT_mod(1, :) = cfg.match_fft(cfg.ltf);
    IFFT_mod(2:cfg.symbol_num + 1, cfg.subcarriers) = complex_mat;

    IFFT_res = ifft(IFFT_mod, cfg.fft_length, 2);

% ======================== Cyclic Prefix ======================
    time_mat_cp = zeros(cfg.symbol_num + 1, cfg.GI + cfg.fft_length);
    for k = 1:cfg.symbol_num + 1
        for i = 1:cfg.GI
            time_mat_cp(k, i) = IFFT_res(k, i + cfg.fft_length - cfg.GI);
        end
        for i = 1:cfg.fft_length
            time_mat_cp(k, i + cfg.GI) = IFFT_res(k, i);
        end
    end

% ========================= Windowing =========================
    windowed_time_mat_cp = zeros(cfg.symbol_num + 1, cfg.fft_length + cfg.GI);
    rcoswin = rcoswindow(cfg.beta, cfg.fft_length + 2 * cfg.GI).';
    rcoswin = rcoswin(1:cfg.GI + cfg.fft_length);
    for i = 1:cfg.symbol_num + 1
        % add raised cosine window
        windowed_time_mat_cp(i,:) = time_mat_cp(i,:).*rcoswin;
    end

% ======================== Serialize ==============================
    bbsignal = reshape(windowed_time_mat_cp.', (cfg.symbol_num + 1) * (cfg.fft_length + cfg.GI), 1).';
end
