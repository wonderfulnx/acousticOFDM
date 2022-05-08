function frequencies = CalFeq(data, Fs)
%
% Syntax: frequencies = CalFeq(data, Fs)
%
    N = length(data);
    n = 0:N-1;
    y = fft(data);
    mag = abs(y);
    frequencies = n * Fs/N;
    plot(frequencies,mag);    %绘出随频率变化的振幅
    xlabel('Feq/Hz');
    ylabel('Am');
    grid on;
end
