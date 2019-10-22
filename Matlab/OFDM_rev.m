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
carriers = (1:carrier_count) + (floor(IFFT_length / 4) - floor(carrier_count / 2));

[Rx_sound, Fs] = audioread('receive.wav');
% Rx_data = Rx_sound.*cos(-2*pi*Fc/44100*(0:length(Rx_sound)-1)).';
Rx_data = Rx_sound;


Rx_cidata_mat = reshape(Rx_data, IFFT_length + GI, symbol_per_carrier)';
Rx_data_mat = Rx_cidata_mat(:, GI + 1:IFFT_length + GI);

Y = fft(Rx_data_mat, IFFT_length, 2);
Rx_carriers = Y(:,carriers);
Rx_phase = angle(Rx_carriers); %接收信号的相位
Rx_mag = abs(Rx_carriers); %接收信号的幅度

[M, N] = pol2cart(Rx_phase, Rx_mag); %将极坐标转化为直角坐标
Rx_complex_mat = complex(M, N); %创建复数
Rx_serial_complex_symbols = reshape(Rx_complex_mat', 1, size(Rx_complex_mat, 1) * size(Rx_complex_mat, 2))';
Rx_bits = DmodQAM16(Rx_serial_complex_symbols)

bits = textread('data.txt');

error_bits = 0
for i = 1:length(bits)
    if bits(i) ~= Rx_bits(i)
        error_bits = error_bits + 1
    end
end
fprintf('BER: %f\n.', error_bits / length(bits))
