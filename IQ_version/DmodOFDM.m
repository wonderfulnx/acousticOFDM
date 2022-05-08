function [Rx_bits, Rx_complex_mat] = OFDM_dmod(config, Rx_data)
%
% Syntax: [Rx_bits] = OFDM_dmod(config, Rx_data)
%

% ========================== 串并变换 ==========================
    Rx_cidata_mat = zeros(config.symbol_per_carrier, config.IFFT_length + config.GI + config.GIP);
    for i = 1:config.symbol_per_carrier
        Rx_cidata_mat(i,:)=Rx_data(1,(i-1)*(config.IFFT_length+config.GI)+1:i*(config.IFFT_length+config.GI)+config.GIP);
    end
% ========================== 去除循环前后缀 ==========================
    Rx_data_mat = Rx_cidata_mat(:,config.GI+1:config.IFFT_length+config.GI);
    
    % Rx_cidata_mat = reshape(Rx_data, config.IFFT_length + config.GI, config.symbol_per_carrier)';
    % Rx_data_mat = Rx_cidata_mat(:, config.GI + 1:(config.IFFT_length + config.GI));

    Y = fft(Rx_data_mat, config.IFFT_length, 2);
    Rx_carriers = Y(:,config.carriers);
    Rx_phase = angle(Rx_carriers); %接收信号的相位
    Rx_mag = abs(Rx_carriers); %接收信号的幅度

    [M, N] = pol2cart(Rx_phase, Rx_mag); %将极坐标转化为直角坐标
    Rx_complex_mat = complex(M, N); %创建复数
    Rx_serial_complex_symbols = reshape(Rx_complex_mat', 1, size(Rx_complex_mat, 1) * size(Rx_complex_mat, 2))';

    if config.modulate == 1
        Rx_bits = DmodQAM16(Rx_serial_complex_symbols, config.d);
    elseif config.modulate == 2
        Rx_bits = DmodQPSK(Rx_serial_complex_symbols, config.d);
    else
        Rx_bits = DmodBPSK(Rx_serial_complex_symbols, config.d);
    end
end
