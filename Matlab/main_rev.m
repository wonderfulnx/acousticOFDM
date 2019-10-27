
con = ofdm_config();
con_pre = ofdm_config(true);

% ========================== 读取声音文件 ==========================
[Rx_sound, Fs] = audioread('data/receive.wav');
Rx_sound = Rx_sound';

% ========================== 帧同步 ==========================
Rx_data = Sync(con_pre, con, Rx_sound);
if isempty(Rx_data)
    return
end


% ========================== 解码 ==========================
[Rx_bits, Rx_complex_mat] = OFDM_dmod(con, Rx_data);

figure();
plot(Tx_data);hold on;
plot(Rx_data);

figure();
plot(Rx_complex_mat,'*r');%XY坐标接收信号的星座图
fig_len = 4 * con.d;
axis([-fig_len, fig_len, -fig_len, fig_len]);
grid on

% % ========================== BER计算 ==========================
bits = textread('data/data.txt');
str = Bin2String(bits);
error_bits = 0;
for i = 1:length(bits)
    if bits(i) ~= Rx_bits(i)
        error_bits = error_bits + 1;
    end
end
fprintf('String: %s\n', char(str));
fprintf('BER: %f\n', error_bits / length(bits));

