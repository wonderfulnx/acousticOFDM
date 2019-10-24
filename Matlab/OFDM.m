function Tx_data = OFDM(bits)
%
% Syntax: Tx_data = OFDM(bits)
%
    config = ofdm_config();
% ======================== 信号产生 ========================
    bit_file = fopen('data/data.txt', 'w');
    fprintf(bit_file, "%d\n", bits);
    fclose(bit_file);
% =========================================================

% ======================== 编码映射 ============================
    if config.modulate == 1
        complex_data = QAM16(bits);
    elseif config.modulate == 2
        complex_data = QPSK(bits);
    else
        complex_data = BPSK(bits);
    end
    complex_mat = reshape(complex_data', config.carrier_count, config.symbol_per_carrier)';

% ======================== IFFT ============================
    IFFT_mod = zeros(config.symbol_per_carrier, config.IFFT_length);
    IFFT_mod(:, config.carriers) = complex_mat;
    IFFT_mod(:, config.conjugate_carriers) = conj(complex_mat);

    IFFT_res = ifft(IFFT_mod, config.IFFT_length, 2);

% ======================== 循环前缀 ============================
    time_mat_cp = zeros(config.symbol_per_carrier, config.IFFT_length + config.GI);
    for k = 1:config.symbol_per_carrier
        for i = 1:config.GI
            time_mat_cp(k, i) = IFFT_res(k, i + config.IFFT_length - config.GI);
        end
        for i = 1:config.IFFT_length
            time_mat_cp(k, i + config.GI) = IFFT_res(k, i);
        end
    end

% ======================== 并转串 ==============================
    Tx_data = reshape(time_mat_cp', (config.symbol_per_carrier) * (config.IFFT_length + config.GI),1)';

% ====================== 写入声音文件 =========================
    % sound_wav = Tx_data .* cos(2 * pi * Fc/Fs*(0:length(Tx_data) - 1));
    sound_wav = Tx_data;
    audiowrite('data/message.wav', sound_wav, config.Fs);
end



% figure(1);
% plot(complex_mat, '*r');
% title('16QAM Constellation');
% axis([-4, 4, -4, 4]);
% grid on;


% ======================== 噪声 ========================
% Tx_signal_power = var(Tx_data);
% linear_SNR = 10 ^ (SNR / 10);
% n_sigma = Tx_signal_power / linear_SNR;
% 正态分布噪声
% noise = randn(1, symbol_per_carrier*(IFFT_length + GI)) * sqrt(n_sigma);

% 高斯白噪
% noise = wgn(1,length(Tx_data),n_sigma,'complex');
% =====================================================


% === pic ===
% tran_time = (symbol_per_carrier) * (IFFT_length+GI);
% tran_time = 1000;
% figure(1)
% subplot(2, 1, 1);
% plot(0:tran_time - 1, Tx_data(1: tran_time));
% grid on
% ylabel('Amplitude (volts)')
% xlabel('Time (samples)')
% title('OFDM Time Signal')
% subplot(2,1,2);
% plot(0:tran_time - 1, sound_wav(1: tran_time));
% grid on
% ylabel('Amplitude (volts)')
% xlabel('Time (samples)')
% title('OFDM Time Signal After Upconversion')

% ======================== 接收端 ==============================
% Rx_data = Tx_data;

% % 去除循环前缀
% Rx_cidata_mat = reshape(Rx_data, IFFT_length + GI, symbol_per_carrier)';
% Rx_data_mat = Rx_cidata_mat(:, GI + 1:IFFT_length + GI);

% Y = fft(Rx_data_mat, IFFT_length, 2);
% Rx_carriers = Y(:,carriers);
% Rx_phase = angle(Rx_carriers); %接收信号的相位
% Rx_mag = abs(Rx_carriers); %接收信号的幅度

% [M, N] = pol2cart(Rx_phase, Rx_mag); %将极坐标转化为直角坐标
% Rx_complex_mat = complex(M, N); %创建复数
% Rx_serial_complex_symbols = reshape(Rx_complex_mat', 1, size(Rx_complex_mat, 1) * size(Rx_complex_mat, 2))';
% Rx_bits = DmodQAM16(Rx_serial_complex_symbols)

% bits == Rx_bits

% [Rx_sound, Fs] = audioread('message.wav');
% Rx_data = Rx_sound.*cos(-2*pi*Fc/Fs*(0:length(Rx_sound)-1)).';
