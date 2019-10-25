
con = ofdm_config();
con_pre = ofdm_config(true);

% ========================== 读取声音文件 ==========================
[Rx_sound, Fs] = audioread('data/receive.wav');
Rx_sound = Rx_sound';

% ========================== 帧同步 ==========================
Rx_data = Sync(con_pre, con, Rx_sound);
if isempty(Rx_data)
    quit
end

% ========================== 解码 ==========================
Rx_bits = OFDM_dmod(con, Rx_data);

% % ========================== BER计算 ==========================
bits = textread('data/data.txt');
error_bits = 0;
for i = 1:length(bits)
    if bits(i) ~= Rx_bits(i)
        error_bits = error_bits + 1;
    end
end
fprintf('BER: %f\n', error_bits / length(bits));

figure();
plot(Tx_data);hold on;
plot(Rx_data);
