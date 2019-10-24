clear all;
close all;

config = ofdm_config();
rand('twister',0);
bits = round(rand(1, config.baseband_length));
Tx_data = OFDM(bits);
[Rx_data, Rx_sound, BER] = OFDM_rev('data/message.wav');
