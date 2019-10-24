function [config] = ofdm_config()
%myFun - Description
%
% Syntax: [config], ofdm_config()
%
% Return the ofdm config info
    % 子载波数
    config.carrier_count = 16;
    % 每个子载波符号数
    config.symbol_per_carrier = 8;
    % 每个符号比特数
    config.bits_per_symbol = 2;
    % FFT点数
    config.IFFT_length = 512;
    % 保护间隔与OFDM数据的比例 1/6~1/4
    config.PrefixRatio = 1/4;
    % 每一个OFDM符号添加的循环前缀长度为1/4*IFFT_length
    config.GI = config.PrefixRatio * config.IFFT_length;
    % 窗函数滚降系数
    config.beta = 1 / 32;
    % 循环后缀的长度
    config.GIP = config.beta * (config.IFFT_length + config.GI);
    % 信噪比15dB
    config.SNR = 15;
    % 声音信号频率
    config.Fc = 17000;
    % 声音信号采样率
    config.Fs = 44100;
    % 基带信息长度
    config.baseband_length = config.carrier_count * config.symbol_per_carrier * config.bits_per_symbol;
    % 载波频率（通过频谱的位置确定
    config.carriers = (1:config.carrier_count) + (floor(config.IFFT_length / 3) - floor(config.carrier_count / 2));
    config.conjugate_carriers = config.IFFT_length - config.carriers + 2;
    % 调制方式, 1 -> qam16, 2 -> qpsk, 3 -> bpsk
    config.modulate = 2;
end