function [Rx_data, Rx_sound, BERs] = OFDM_rev(filename)
%
% Syntax: Rx_data = OFDMrev(filename)
%
    config = ofdm_config();
% ========================== 读取声音文件 ==========================
    [Rx_sound, Fs] = audioread(filename);
    Rx_sound = Rx_sound';

% ========================== 找到信号位置 ==========================
    desire_len = (config.IFFT_length + config.GI) * config.symbol_per_carrier;
    % Rx_sum = [];
    tmp = sum(abs(Rx_sound(1:desire_len)));
    max_sum = 0;
    target = 1;
    for i = 1:(length(Rx_sound) - desire_len)
        % Rx_sum = [Rx_sum, tmp];
        if tmp > max_sum
            target = i;
            max_sum = tmp;
        end
        tmp = tmp - abs(Rx_sound(i));
        tmp = tmp + abs(Rx_sound(desire_len + i));
    end

% ========================== 解码 ==========================
    BERs = [];
    % for targ = (target - desire_len / 2):(target + desire_len / 2)
    for targ = target:target
        Rx_data = Rx_sound(targ:(targ + desire_len - 1));
        Rx_cidata_mat = reshape(Rx_data, config.IFFT_length + config.GI, config.symbol_per_carrier)';
        Rx_data_mat = Rx_cidata_mat(:, config.GI + 1:(config.IFFT_length + config.GI));

        Y = fft(Rx_data_mat, config.IFFT_length, 2);
        Rx_carriers = Y(:,config.carriers);
        Rx_phase = angle(Rx_carriers); %接收信号的相位
        Rx_mag = abs(Rx_carriers); %接收信号的幅度

        [M, N] = pol2cart(Rx_phase, Rx_mag); %将极坐标转化为直角坐标
        Rx_complex_mat = complex(M, N); %创建复数
        Rx_serial_complex_symbols = reshape(Rx_complex_mat', 1, size(Rx_complex_mat, 1) * size(Rx_complex_mat, 2))';

        if config.modulate == 1
            Rx_bits = DmodQAM16(Rx_serial_complex_symbols);
        elseif config.modulate == 2
            Rx_bits = DmodQPSK(Rx_serial_complex_symbols);
        else
            Rx_bits = DmodBPSK(Rx_serial_complex_symbols);
        end
        
    % ========================== BER计算 ==========================
        bits = textread('data/data.txt');
        error_bits = 0;
        for i = 1:length(bits)
            if bits(i) ~= Rx_bits(i)
                error_bits = error_bits + 1;
            end
        end
        BER = error_bits / length(bits);
        % fprintf('BER: %f\n', error_bits / length(bits));
        BERs = [BERs, BER];
    end
end



% ============================= 信号变换 ===============================
% Rx_sound_up = 2 * Rx_sound.*cos(2*pi*Fc/Fs*(0:length(Rx_sound)-1));

% rp = 1; % 通带最大衰减
% rs = 60; % 阻带最小衰减
% fp = 12000; % 通带截止频率
% fs = 18000; % 阻带截止频率
% wp = 2 * pi * fp / Fs;
% ws = 2 * pi * fs / Fs;   %求出待设计的模拟滤波器的边界频率
% [N,wn]=buttord(wp,ws,rp,rs,'s');    %低通滤波器的阶数和截止频率
% [b,a]=butter(N,wn,'s');             %S域频率响应的参数即：滤波器的传输函数
% [bz,az]=bilinear(b,a,0.5);          %利用双线性变换实现频率响应S域到Z域的变换
% Rx_data = filter(bz,az,Rx_sound_up);
% Rx_data = BPassFilter(Rx_sound_up, 1500, 500, Fs);
% =================================================================


% plot(Rx_complex_mat,'*r');%16QAM调制后星座图
% axis([-4, 4, -4, 4]);
% grid on
