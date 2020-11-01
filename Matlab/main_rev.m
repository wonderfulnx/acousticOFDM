
con = ofdm_config();
con_pre = ofdm_config(true);

% ========================== 读取声音文件 ==========================
[Rx_sound, Fs] = audioread('data/receive.wav');
Rx_sound = Rx_sound';

% ========================== 帧同步 ==========================
Rx_data = Sync_xcorr(con_pre, con, Rx_sound);
if isempty(Rx_data)
    return
end


% ========================== 解码 ==========================
[Rx_bits, Rx_complex_mat] = OFDM_dmod(con, Rx_data);
str = Bin2String(Rx_bits);
fprintf('String: %s\n', char(str));

figure();
if exist('Tx_data')
    plot(Tx_data); hold on;
end
plot(Rx_data); title('Tx\_data Signal and Rx\_data Signal');

figure();
plot(Rx_complex_mat,'*r'); %XY坐标接收信号的星座图
title('Constellation Points');
fig_len = 4 * con.d;
axis([-fig_len, fig_len, -fig_len, fig_len]);
grid on

% % ========================== BER计算 =============================
bits = textread('data/data.txt');
fprintf('Origin: %s\n', char(Bin2String(bits)));
error_bits = 0;
for i = 1:length(bits)
    if bits(i) ~= Rx_bits(i)
        error_bits = error_bits + 1;
    end
end

fprintf('BER: %f\n', error_bits / length(bits));


%% ========================== Debug Code ==========================
% BERS = [];
% len = length(Rx_sound);
% data_len = con.symbol_per_carrier * (con.IFFT_length + con.GI) + con.GIP;
% for sta = 1:len - data_len + 1
%     [Rx_bits, Rx_complex_mat] = OFDM_dmod(con, Rx_sound(sta:sta + data_len - 1));
%     error_bits = 0;
%     for i = 1:length(bits)
%         if bits(i) ~= Rx_bits(i)
%             error_bits = error_bits + 1;
%         end
%     end
%     BERS = [BERS, error_bits / length(bits)];
% end
% plot(BERS)