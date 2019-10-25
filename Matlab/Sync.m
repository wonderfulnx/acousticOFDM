function index = Sync(Rx_signal, desire_len)
%
% Syntax: desire_data = Sync(Rx_signal)
%
    config = ofdm_config();
    feqs = [];
    for i = 1:1:length(Rx_signal) - config.preamble_length
        pre_ind = floor(config.preamble_length / 3);
        Y = fft(Rx_signal(i:i+config.preamble_length));
        feqs = [feqs, Y(pre_ind)];
    end
    [~, pre_start] = max(feqs);
    index = pre_start + config.preamble_length;
end