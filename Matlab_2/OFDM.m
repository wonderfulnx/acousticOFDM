function Tx_data = OFDM(config, bits)
%
% Syntax: Tx_data = OFDM(bits)
%

% ======================== 编码映射 ============================
    if config.modulate == 1
        complex_data = QAM16(bits, config.d);
    elseif config.modulate == 2
        complex_data = QPSK(bits, config.d);
    else
        complex_data = BPSK(bits, config.d);
    end
    complex_mat = reshape(complex_data', config.carrier_count, config.symbol_per_carrier)';

% ======================== IFFT ============================
    IFFT_mod = zeros(config.symbol_per_carrier, config.IFFT_length);
    IFFT_mod(:, config.carriers) = complex_mat;
    % IFFT_mod(:, config.conjugate_carriers) = conj(complex_mat);

    IFFT_res = ifft(IFFT_mod, config.IFFT_length, 2);

% ======================== 循环前后缀 ============================
    time_mat_cp = zeros(config.symbol_per_carrier, config.IFFT_length + config.GI + config.GIP);
    for k = 1:config.symbol_per_carrier
        for i = 1:config.GI
            time_mat_cp(k, i) = IFFT_res(k, i + config.IFFT_length - config.GI);
        end
        for i = 1:config.IFFT_length
            time_mat_cp(k, i + config.GI) = IFFT_res(k, i);
        end
        for i = 1:config.GIP
            time_mat_cp(k, config.IFFT_length + config.GI + i) = IFFT_res(k, i);
        end
    end

% ======================== 信号加窗 ==============================
    windowed_time_mat_cp = zeros(config.symbol_per_carrier, config.IFFT_length + config.GI + config.GIP);
    for i = 1:config.symbol_per_carrier
        %加窗 升余弦窗
        windowed_time_mat_cp(i,:) = time_mat_cp(i,:).*rcoswindow(...
            config.beta, config.IFFT_length + config.GI + config.GIP)';
        % Or
        % windowed_time_mat_cp(i,:) = time_mat_cp(i,:).*hann(config.IFFT_length + config.GI + config.GIP)';
    end

% ======================== 并转串 ==============================
    % Tx_data = reshape(time_mat_cp', (config.symbol_per_carrier) * (config.IFFT_length + config.GI),1)';
    windowed_Tx_data = zeros(1,config.symbol_per_carrier*(config.IFFT_length + config.GI)+config.GIP);
    windowed_Tx_data(1:config.IFFT_length + config.GI + config.GIP) = windowed_time_mat_cp(1,:);
    for i = 1:config.symbol_per_carrier - 1;
        windowed_Tx_data((config.IFFT_length + config.GI)*i+1:(...
            config.IFFT_length + config.GI)*(i+1)+config.GIP)=...
            windowed_time_mat_cp(i+1,:);%并串转换，循环后缀与循环前缀相叠加
    end

    Tx_data = windowed_Tx_data;
end
