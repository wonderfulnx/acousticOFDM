clear all;
close all;

carrier_count = 200; %子载波数
symbol_per_carrier = 12; % 每个子载波符号数
bits_per_symbol = 4; %每个符号比特数
IFFT_length = 512; %FFT点数
PrefixRatio = 1/4; %保护间隔与OFDM数据的比例 1/6~1/4
GI = PrefixRatio * IFFT_length; % 每一个OFDM符号添加的循环前缀长度为1/4*IFFT_length
SNR = 15; %信噪比15dB

Fc = 18000; %声音信号频率
Fs = 44100; %声音信号采样率


% ======================== 信号产生 ========================
baseband_length = carrier_count * symbol_per_carrier * bits_per_symbol;
carriers = (1:carrier_count) + (floor(IFFT_length / 4) - floor(carrier_count / 2));
conjugate_carriers = IFFT_length - carriers + 2;
bits = round(rand(1, baseband_length))
bit_file = fopen('data.txt', 'w');
fprintf(bit_file, "%d\n", bits);
fclose(bit_file);
% =========================================================

complex_data = QAM16(bits);
complex_mat = reshape(complex_data', carrier_count, symbol_per_carrier)';
% figure(1);
% plot(complex_mat, '*r');
% title('16QAM Constellation');
% axis([-4, 4, -4, 4]);
% grid on;

% ======================== IFFT ============================
IFFT_mod = zeros(symbol_per_carrier, IFFT_length);
IFFT_mod(:, carriers) = complex_mat;
IFFT_mod(:, conjugate_carriers) = conj(complex_mat);

IFFT_res = ifft(IFFT_mod, IFFT_length, 2);

% 添加循环前缀
time_mat_cp = zeros(symbol_per_carrier, IFFT_length + GI);
for k = 1:symbol_per_carrier
    for i = 1:GI
        time_mat_cp(k, i) = IFFT_res(k, i + IFFT_length - GI);
    end
    for i = 1:IFFT_length
        time_mat_cp(k, i + GI) = IFFT_res(k, i);
    end
end

% ======================== 并转串 ==============================
Tx_data = reshape(time_mat_cp', (symbol_per_carrier) * (IFFT_length+GI),1)';

% ======================== 噪声 ========================
% Tx_signal_power = var(Tx_data);
% linear_SNR = 10 ^ (SNR / 10);
% n_sigma = Tx_signal_power / linear_SNR;
% 正态分布噪声
% noise = randn(1, symbol_per_carrier*(IFFT_length + GI)) * sqrt(n_sigma);

% 高斯白噪
% noise = wgn(1,length(Tx_data),n_sigma,'complex');
% =====================================================


% ====================== 写入声音文件 =========================
% sound_wav = Tx_data .* cos(-2 * pi * Fc/Fs*(0:length(Tx_data) - 1));
sound_wav = Tx_data;
audiowrite('message.wav', sound_wav, Fs);

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

[Rx_sound, Fs] = audioread('message.wav');
Rx_data = Rx_sound.*cos(-2*pi*Fc/Fs*(0:length(Rx_sound)-1)).';
