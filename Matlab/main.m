clear all;
close all;

con = ofdm_config();

% ======= 生成要传输的数据
rand('twister',0);
bits = round(rand(1, con.baseband_length));
bit_file = fopen('data/data.txt', 'w');
fprintf(bit_file, "%d\n", bits);
fclose(bit_file);

config = ofdm_config();

preamble = [0,0,0,0,1,0,1,1,0,1,1,1,0,1,1,1]
Tx_data = OFDM(bits);
% [Rx_data, Rx_sound, BER, min_pos] = OFDM_rev('data/message.wav');
plot(Tx_data)
