function [config] = ofdm_config(preamble)
%
% Syntax: [config], ofdm_config()
%
% Return the default ofdm config info
    if (nargin < 1) preamble = false;
    end
    if (preamble)
        % 子载波数
        config.carrier_count = 4;
        % 每个子载波符号数
        config.symbol_per_carrier = 2;
        % 每个符号比特数
        config.bits_per_symbol = 2;
        % FFT点数
        config.IFFT_length = 256;
    else
        % 子载波数
        config.carrier_count = 16;
        % 每个子载波符号数
        config.symbol_per_carrier = 16;
        % 每个符号比特数
        config.bits_per_symbol = 2;
        % FFT点数
        config.IFFT_length = 512;
    end
    % 每个符号距离
    config.d = 5;
    % 保护间隔与OFDM数据的比例 1/6~1/4
    config.PrefixRatio = 1/4;
    % 窗函数滚降系数
    config.beta = 1 / 32;
    % 声音信号频率
    config.Fc = 17000;
    % 声音信号采样率
    config.Fs = 10000;
    % 每一个OFDM符号添加的循环前缀长度为1/4*IFFT_length
    config.GI = config.PrefixRatio * config.IFFT_length;
    % 循环后缀的长度
    config.GIP = config.beta * (config.IFFT_length + config.GI);
    % 载波频率（通过频谱的位置确定
    config.carriers = (1:config.carrier_count) + (floor(config.IFFT_length * / 5) - floor(config.carrier_count / 2));
    config.conjugate_carriers = config.IFFT_length - config.carriers + 2;
    % 基带信息长度
    config.baseband_length = config.carrier_count * config.symbol_per_carrier * config.bits_per_symbol;
    % 调制方式, 1 -> qam16, 2 -> qpsk, 3 -> bpsk
    config.modulate = 2;
    % 信号Preamble
    config.preamble = [...
        0, 0, 0, 0, 1, 0, 1, 1,...
        0, 1, 1, 1, 0, 1, 1, 1];
end