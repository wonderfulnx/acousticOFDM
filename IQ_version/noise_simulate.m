clear all;
close all;

con = ofdm_config();
BERs = [];
SNRs = (-10 : 15);

for SNR = SNRs
    bits = round(rand(1, con.baseband_length));
    Tx_data = OFDM(con, bits);
    Rx_data = awgn(Tx_data, SNR, 'measured');

    % Tx_signal_power = var(Tx_data);%发送信号功率
    % linear_SNR = 10 ^ (SNR / 10);%线性信噪比 
    % noise_sigma=Tx_signal_power/linear_SNR;
    % noise_scale_factor = sqrt(noise_sigma);%标准差sigma
    % noise=randn(1,((con.symbol_per_carrier)*(con.IFFT_length+con.GI))+con.GIP)*noise_scale_factor;%产生正态分布噪声序列

    % noise = wgn(1,length(Tx_data),noise_sigma,'complex');%产生复GAUSS白噪声信号 

    % Rx_data = Tx_data + noise;%接收到的信号加噪声

    [Rx_bits, Rx_complex_mat] = OFDM_dmod(con, Rx_data);

    % figure();
    % plot(Rx_complex_mat,'*r');%XY坐标接收信号的星座图
    % fig_len = 4 * con.d;
    % axis([-fig_len, fig_len, -fig_len, fig_len]);
    % grid on

    error_bits = 0;
    for i = 1:length(bits)
        if bits(i) ~= Rx_bits(i)
            error_bits = error_bits + 1;
        end
    end
    % fprintf('BER: %f\n', error_bits / length(bits));
    BERs = [BERs, error_bits / length(bits)];
end

figure();
plot(SNRs, BERs, '-b*');
xlabel('SNR');
ylabel('BER');
