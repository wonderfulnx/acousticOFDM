function [config] = ofdm_config()
% Generate OFDM config structure.
%
% Syntax: [config] = ofdm_config()
%
    % Used subcarriers, counting from 0 to 63: 1->26 is for 1->26, 38->63 is for (-26)->(-1)
    %   the same configuration for Std 802.11-2007 (Figure 17-3).
    config.subcarriers = [1:26, 38:63] + 1;
    % data symbol number (in time)
    config.symbol_num = 16;
    % defines modulation and coding scheme, 0 -> BPSK, 1 -> QPSK, 2 -> QAM16;
    % also defines bits contained in each subcarrier for each symbol
    % BPSK -> 1bit, QPSK -> 2bit, QAM16-> 4bit;
    config.mcs = 1;
    % numbers of used subcarrier
    config.subcarrier_count = length(config.subcarriers);
    % FFT number, also the overall subcarriers(1 -> fft_length)
    config.fft_length = 64;
    % distance for modulation and coding scheme (`d` represents the maximum distance between IQ point and the origin)
    config.d = 5;
    % Rx gain of the receiver end
    config.rx_gain = 2;
    % the ratio for ((GI/CP) / OFDM data), usually 1/4
    config.pefixratio = 1/4;
    % roll-off factor for raised-cosine window
    config.beta = 1/8;
    % carrier frequency for acoustic signal
    config.fc = 17000;
    % sampling frequency for baseband signal, also the bandwidth(BW) for baseband in our implementation
    config.fs_baseband = 4000;
    % sampling frequency for acoustic signal, must be at least 2*fc+BW
    config.fs_wave = 48000;
    % length for guard interval (GI) or cyclic prefix (CP)
    config.GI = config.pefixratio * config.fft_length;
    % possible payload bits
    config.load_bits = config.subcarrier_count * config.symbol_num * (2^config.mcs);

    % short training symbol from subcarrier -26 to 26 (S_-26,26)
    config.stf = sqrt(13/6) * config.d * [0,0,1+1j,0,0,0,-1-1j,0,0,0,1+1j,0,0,0,-1-1j,0,0,0,-1-1j,0,0,0,1+1j,0,0,0,0,...
        0,0,0,-1-1j,0,0,0,-1-1j,0,0,0,1+1j,0,0,0,1+1j,0,0,0,1+1j,0,0,0,1+1j,0,0];
    % long training symbol from subcarrier -26 to 26 (L_-26,26)
    config.ltf = config.d * [1,1,-1,-1,1,1,-1,1,-1,1,1,1,1,1,1,-1,-1,1,1,-1,1,-1,1,1,1,1,0,...
        1,-1,-1,1,1,-1,1,-1,1,-1,-1,-1,-1,-1,1,1,-1,-1,1,-1,1,-1,1,1,1,1];

    % Packet structure
    % |---STF---|---LTF---|---Sym---|---Sym---|...
    % |<  20ms >|<  20ms >|<  20ms >|<  20ms >|...
    config.stf_len = config.fft_length + config.GI;
    config.ltf_len = config.fft_length + config.GI;
    config.sym_len = config.fft_length + config.GI;
    config.data_len = config.symbol_num * config.sym_len;

    % Input/Output of IFFT (reverse for FFT)
    %          ---------------
    % NULL ---| 0          0  | --- 
    %  #1  ---| 1          1  | --- 
    %  #2  ---| 2          2  | --- 
    %   .  ---| .          .  | --- 
    %   .  ---| .          .  | --- 
    %  #26 ---| 26    I    26 | --- 
    % NULL ---| 27    F    27 | ---   Time Domain Outputs
    % NULL ---| 28    F    28 | --- 
    %   .  ---| .     T    .  | --- 
    % NULL ---| 37         37 | --- 
    % #-26 ---| 38         38 | --- 
    %   .  ---| .          .  | --- 
    %   .  ---| .          .  | --- 
    %  #-1 ---| 63         63 | --- 
    %          ---------------
    
    % matching between X_-26,26 to 64 number ifft input (freq domain)
    config.match_fft = @(x) [0, x(28:53), zeros(1, 11), x(1:26)];
end
