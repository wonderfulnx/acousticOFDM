
cfg = ofdm_config();

%% ====================== Read audio recording ====================
[rx_signal, cfg.fs_wave] = audioread('data/receive.wav');
rx_signal = rx_signal';

%% ========================= IQ demodulation ======================
rx_bbsignal = cfg.rx_gain * IQdemod(rx_signal, cfg.fc, cfg.fs_baseband, cfg.fs_wave);

%% ========================== Frame Sync ==========================
[rx_bbstf, rx_bbltf, rx_bbdata] = Sync_xcorr(cfg, rx_bbsignal);
if isempty(rx_bbltf)
    fprintf('No Packet Found.\n');
    return
end


%% ========================== Demodulation =========================
[rx_bits, rx_complex_mat, channel] = OFDMdemod(cfg, rx_bbltf, rx_bbdata);
str = Bin2String(rx_bits);
fprintf('String: %s\n', char(str));

%% =========================== Draw Graph ==========================
% -------------------- Baseband -------------------
figure();
if exist('bb_signal')
    plot(abs(bb_signal)); hold on;
end
plot(abs([rx_bbstf, rx_bbltf, rx_bbdata])); title('Tx baseband signal and Rx baseband signal');

% -------------------- IQ graph -------------------
% only QPSK for now
figure();
plot(rx_complex_mat,'*r');
title('Constellation Points');
fig_len = 4 * cfg.d;
axis([-fig_len, fig_len, -fig_len, fig_len]);
grid on

% -------------------- Channel --------------------
figure();
subplot(2, 1, 1);
plot([-26:-1, 1:26], abs([channel(27:52), channel(1:26)]));
title('Channel State Magnitude'); xlabel('Channel'); ylabel('Mag');
subplot(2, 1, 2);
plot([-26:-1, 1:26], rad2deg(angle([channel(27:52), channel(1:26)])));
title('Channel State Phase'); xlabel('Channel'); ylabel('Phase');

%% ======================= Calculate BER ========================
bits = textread('data/data.txt');
fprintf('Origin: %s\n', char(Bin2String(bits)));
error_bits = 0;
for i = 1:length(bits)
    if bits(i) ~= rx_bits(i)
        error_bits = error_bits + 1;
    end
end

fprintf('BER: %f\n', error_bits / length(bits));

