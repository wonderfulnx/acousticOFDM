clear all;
close all;

cfg = ofdm_config();

%% =========== Generate bit info ==========
rand('twister',0);
bits = round(rand(1, cfg.load_bits));
bit_file = fopen('data/data.txt', 'w');
fprintf(bit_file, "%d\n", bits);
fclose(bit_file);

%% ========== OFDM modulation =============
bb_data = OFDMmod(cfg, bits);

%% =========== Generate Preamble ==========
% ------ Short training symbol -------
stf_ = ifft(cfg.match_fft(cfg.stf));
bb_stf = [stf_(1:cfg.GI), stf_];
bb_signal = [bb_stf, bb_data];

%% =========== IQ modulation ==============
tx_signal = IQmod(bb_signal, cfg.fc, cfg.fs_baseband, cfg.fs_wave);
tx_signal = tx_signal / max(abs(tx_signal));

%% =========== Write to file ==============
audiowrite('data/message.wav', tx_signal, cfg.fs_wave);
