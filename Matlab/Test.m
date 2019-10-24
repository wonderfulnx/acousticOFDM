clear;

fm = 1000;     %信号频率
Fc = 18000;
Fs = 44100;

t=(0:1/Fs:(1000-1)/Fs); 
Tx_data=cos(2*pi*fm*t); %一个symbol

sound_wav = Tx_data .* cos(2 * pi * Fc * t);
Rx_sound_up = sound_wav.*cos(2*pi*Fc*t);

% plot(Tx_data(1:100), 'r');
% hold on;
% plot(sound_wav(1:100), 'b');
% hold on;
Rx_data = BPassFilter(Rx_sound_up, 1e3, 2e2, Fs);

% rp = 0.01; % 通带最大衰减
% rs = 60; % 阻带最小衰减
% fp = 12000; % 通带截止频率
% fs = 18000; % 阻带截止频率
% wp = fp / (Fs/2);
% ws = fs / (Fs/2);   %求出待设计的模拟滤波器的边界频率
% [N,wn]=buttord(wp,ws,rp,rs);    %低通滤波器的阶数和截止频率
% [b,a]=butter(N,wn);             %S域频率响应的参数即：滤波器的传输函数
% [bz,az]=bilinear(b,a,0.5);          %利用双线性变换实现频率响应S域到Z域的变换
% freqz(b,a,512,Fs);%做出H(z)的幅频、相频图
% Rx_data = filter(b,a,Rx_sound_up);
% plot(Rx_data(1:100), 'g');
