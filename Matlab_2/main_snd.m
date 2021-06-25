clear all;
close all;

con = ofdm_config();

% =========== 生成要传输的数据 ==========
rand('twister',0);
bits = round(rand(1, con.load_bits));
bit_file = fopen('data/data.txt', 'w');
fprintf(bit_file, "%d\n", bits);
fclose(bit_file);
Tx_data = OFDM(con, bits);

% =========== 生成Preamble ==========
con_pre = ofdm_config(true);
Preamble = OFDM(con_pre, con.preamble);
message_data = [zeros(1, con.Fs), Preamble, Tx_data, zeros(1, con.Fs)];
message_data = message_data / max(abs(message_data));

audiowrite('data/message.wav', message_data, con.Fs);
