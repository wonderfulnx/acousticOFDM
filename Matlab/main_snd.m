clear all;
close all;

con = ofdm_config();

% =========== 生成要传输的数据 ==========
rand('twister',0);
bits = round(rand(1, con.baseband_length));
bit_file = fopen('data/data.txt', 'w');
fprintf(bit_file, "%d\n", bits);
fclose(bit_file);
Tx_data = OFDM(con, bits);

% =========== 生成Preamble ==========
con_pre = ofdm_config(true);
Preamble = OFDM(con_pre, con.preamble);

audiowrite('data/message.wav', [Preamble, zeros(1, length(Preamble)), Tx_data], con.Fs);
