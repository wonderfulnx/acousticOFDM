
clear all;
close all;
carrier_count=200;%子载波数
symbols_per_carrier=12;%每子载波含符号数
bits_per_symbol=4;%每符号含比特数,16QAM调制
IFFT_bin_length=512;%FFT点数
PrefixRatio=1/4;%保护间隔与OFDM数据的比例 1/6~1/4
GI=PrefixRatio*IFFT_bin_length ;%每一个OFDM符号添加的循环前缀长度为1/4*IFFT_bin_length  即保护间隔长度为128
beta=1/32;%窗函数滚降系数
GIP=beta*(IFFT_bin_length+GI);%循环后缀的长度20
SNR=15; %信噪比dB
%==================================================
%================信号产生===================================
baseband_out_length = carrier_count * symbols_per_carrier * bits_per_symbol;%所输入的比特数目  200*12*4
carriers = (1:carrier_count) + (floor(IFFT_bin_length/4) - floor(carrier_count/2));%共轭对称子载波映射  复数数据对应的IFFT点坐标
conjugate_carriers = IFFT_bin_length - carriers + 2;%共轭对称子载波映射  共轭复数对应的IFFT点坐标
rand('twister',0);
baseband_out=round(rand(1,baseband_out_length));%输出待调制的二进制比特流
%==============16QAM调制====================================
 
complex_carrier_matrix=qam16(baseband_out);%列向量
 
complex_carrier_matrix=reshape(complex_carrier_matrix',carrier_count,symbols_per_carrier)';%symbols_per_carrier*carrier_count 矩阵
 
figure(1);
plot(complex_carrier_matrix,'*r');%16QAM调制后星座图
axis([-4, 4, -4, 4]);
grid on
%=================IFFT===========================
IFFT_modulation=zeros(symbols_per_carrier,IFFT_bin_length);%添0组成IFFT_bin_length IFFT 运算 
IFFT_modulation(:,carriers ) = complex_carrier_matrix ;%未添加导频信号 ，子载波映射在此处
IFFT_modulation(:,conjugate_carriers ) = conj(complex_carrier_matrix);%共轭复数映射
%========================================================
figure(2);
stem(0:IFFT_bin_length-1, abs(IFFT_modulation(2,1:IFFT_bin_length)),'b*-')%第一个OFDM符号的频谱
grid on
axis ([0 IFFT_bin_length -0.5 4.5]);
ylabel('Magnitude');
xlabel('IFFT Bin');
title('OFDM Carrier Frequency Magnitude');
 
figure(3);
plot(0:IFFT_bin_length-1, (180/pi)*angle(IFFT_modulation(2,1:IFFT_bin_length)), 'go')
hold on
stem(0:carriers-1, (180/pi)*angle(IFFT_modulation(2,1:carriers)),'b*-');%第一个OFDM符号的相位
stem(0:conjugate_carriers-1, (180/pi)*angle(IFFT_modulation(2,1:conjugate_carriers)),'b*-');
axis ([0 IFFT_bin_length -200 +200])
grid on
ylabel('Phase (degrees)')
xlabel('IFFT Bin')
title('OFDM Carrier Phase')
%=================================================================
 
signal_after_IFFT=ifft(IFFT_modulation,IFFT_bin_length,2);%OFDM调制 即IFFT变换
time_wave_matrix =signal_after_IFFT;%时域波形矩阵，行为每载波所含符号数，列ITTF点数，N个子载波映射在其内，每一行即为一个OFDM符号
figure(4);
subplot(3,1,1);
plot(0:IFFT_bin_length-1,time_wave_matrix(2,:));%第一个符号的波形
axis([0, 700, -0.2, 0.2]);
grid on;
ylabel('Amplitude');
xlabel('Time');
title('OFDM Time Signal, One Symbol Period');
 
%===========================================================
%=====================添加循环前缀与后缀====================================
XX=zeros(symbols_per_carrier,IFFT_bin_length+GI+GIP);%GI=128,GIP=20
for k=1:symbols_per_carrier;%12
    for i=1:IFFT_bin_length;%512
        XX(k,i+GI)=signal_after_IFFT(k,i);%129--640
    end
    for i=1:GI;%1--128
        XX(k,i)=signal_after_IFFT(k,i+IFFT_bin_length-GI);%添加循环前缀  %后128个数据放到前面
    end
    for j=1:GIP;
        XX(k,IFFT_bin_length+GI+j)=signal_after_IFFT(k,j);%添加循环后缀  前20个数据放到后面
    end
end
 
time_wave_matrix_cp=XX;%添加了循环前缀与后缀的时域信号矩阵,此时一个OFDM符号长度为IFFT_bin_length+GI+GIP=660
subplot(3,1,2);
plot(0:length(time_wave_matrix_cp)-1,time_wave_matrix_cp(2,:));%第一个符号添加循环前缀后的波形
axis([0, 700, -0.2, 0.2]);
grid on;
ylabel('Amplitude');
xlabel('Time');
title('OFDM Time Signal with CP, One Symbol Period');
 
 
 
%==============OFDM符号加窗==========================================
windowed_time_wave_matrix_cp=zeros(1,IFFT_bin_length+GI+GIP);
for i = 1:symbols_per_carrier %12
windowed_time_wave_matrix_cp(i,:) = real(time_wave_matrix_cp(i,:)).*rcoswindow(beta,IFFT_bin_length+GI)';%加窗  升余弦窗
end  
subplot(3,1,3);
plot(0:IFFT_bin_length-1+GI+GIP,windowed_time_wave_matrix_cp(2,:));%第一个符号的波形
axis([0, 700, -0.2, 0.2]);
grid on;
ylabel('Amplitude');
xlabel('Time');
title('OFDM Time Signal Apply a Window , One Symbol Period');
 
 
%========================生成发送信号，并串变换==================================================
windowed_Tx_data=zeros(1,symbols_per_carrier*(IFFT_bin_length+GI)+GIP);
windowed_Tx_data(1:IFFT_bin_length+GI+GIP)=windowed_time_wave_matrix_cp(1,:);
for i = 1:symbols_per_carrier-1 ;
    windowed_Tx_data((IFFT_bin_length+GI)*i+1:(IFFT_bin_length+GI)*(i+1)+GIP)=windowed_time_wave_matrix_cp(i+1,:);%并串转换，循环后缀与循环前缀相叠加
end
 
%=======================================================
Tx_data_withoutwindow =reshape(time_wave_matrix_cp',(symbols_per_carrier)*(IFFT_bin_length+GI+GIP),1)';%没有加窗，只添加循环前缀与后缀的串行信号
Tx_data =reshape(windowed_time_wave_matrix_cp',(symbols_per_carrier)*(IFFT_bin_length+GI+GIP),1)';%加窗后 循环前缀与后缀不叠加 的串行信号
%=================================================================
temp_time1 = (symbols_per_carrier)*(IFFT_bin_length+GI+GIP);%加窗后 循环前缀与后缀不叠加 发送总位数
figure (5)
subplot(2,1,1);
plot(0:temp_time1-1,Tx_data );%循环前缀与后缀不叠加 发送的信号波形
grid on
ylabel('Amplitude (volts)')
xlabel('Time (samples)')
title('OFDM Time Signal')
temp_time2 =symbols_per_carrier*(IFFT_bin_length+GI)+GIP;
subplot(2,1,2);
plot(0:temp_time2-1,windowed_Tx_data);%循环后缀与循环前缀相叠加 发送信号波形
grid on
ylabel('Amplitude (volts)')
xlabel('Time (samples)')
title('OFDM Time Signal')
 
%=================未加窗发送信号频谱==================================
symbols_per_average = ceil(symbols_per_carrier/5);%符号数的1/5，10行
avg_temp_time = (IFFT_bin_length+GI+GIP)*symbols_per_average;%点数，10行数据，10个符号
averages = floor(temp_time1/avg_temp_time);
average_fft(1:avg_temp_time) = 0;%分成5段
for a = 0:(averages-1)
 subset_ofdm = Tx_data_withoutwindow (((a*avg_temp_time)+1):((a+1)*avg_temp_time));%
 subset_ofdm_f = abs(fft(subset_ofdm));%将发送信号分段求频谱
 average_fft = average_fft + (subset_ofdm_f/averages);%总共的数据分为5段，分段进行FFT，平均相加
end
average_fft_log = 20*log10(average_fft);
figure (6)
subplot(2,1,1);
plot((0:(avg_temp_time-1))/avg_temp_time, average_fft_log)%归一化  0/avg_temp_time  :  (avg_temp_time-1)/avg_temp_time
hold on
plot(0:1/IFFT_bin_length:1, -35, 'rd')
grid on
axis([0 0.5 -40 max(average_fft_log)])
ylabel('Magnitude (dB)')
xlabel('Normalized Frequency (0.5 = fs/2)')
title('OFDM Signal Spectrum without windowing')
%===============加窗的发送信号频谱=================================
symbols_per_average = ceil(symbols_per_carrier/5);%符号数的1/5，10行
avg_temp_time = (IFFT_bin_length+GI+GIP)*symbols_per_average;%点数，10行数据，10个符号
averages = floor(temp_time1/avg_temp_time);
average_fft(1:avg_temp_time) = 0;%分成5段
for a = 0:(averages-1)
 subset_ofdm = Tx_data(((a*avg_temp_time)+1):((a+1)*avg_temp_time));%利用循环前缀后缀未叠加的串行加窗信号计算频谱
 subset_ofdm_f = abs(fft(subset_ofdm));%分段求频谱
 average_fft = average_fft + (subset_ofdm_f/averages);%总共的数据分为5段，分段进行FFT，平均相加
end
average_fft_log = 20*log10(average_fft);
subplot(2,1,2)
plot((0:(avg_temp_time-1))/avg_temp_time, average_fft_log)%归一化  0/avg_temp_time  :  (avg_temp_time-1)/avg_temp_time
hold on
plot(0:1/IFFT_bin_length:1, -35, 'rd')
grid on
axis([0 0.5 -40 max(average_fft_log)])
ylabel('Magnitude (dB)')
xlabel('Normalized Frequency (0.5 = fs/2)')
title('Windowed OFDM Signal Spectrum')
%====================添加噪声============================================
Tx_signal_power = var(windowed_Tx_data);%发送信号功率
linear_SNR=10^(SNR/10);%线性信噪比 
noise_sigma=Tx_signal_power/linear_SNR;
noise_scale_factor = sqrt(noise_sigma);%标准差sigma
noise=randn(1,((symbols_per_carrier)*(IFFT_bin_length+GI))+GIP)*noise_scale_factor;%产生正态分布噪声序列
 
%noise=wgn(1,length(windowed_Tx_data),noise_sigma,'complex');%产生复GAUSS白噪声信号 
 
Rx_data=windowed_Tx_data +noise;%接收到的信号加噪声
%=====================接收信号  串/并变换 去除前缀与后缀==========================================
Rx_data_matrix=zeros(symbols_per_carrier,IFFT_bin_length+GI+GIP);
for i=1:symbols_per_carrier;
    Rx_data_matrix(i,:)=Rx_data(1,(i-1)*(IFFT_bin_length+GI)+1:i*(IFFT_bin_length+GI)+GIP);%串并变换
end
Rx_data_complex_matrix=Rx_data_matrix(:,GI+1:IFFT_bin_length+GI);%去除循环前缀与循环后缀，得到有用信号矩阵
 
%============================================================
%================================================================
 
%==============================================================
%                      OFDM解码   16QAM解码
%=================FFT变换=================================
Y1=fft(Rx_data_complex_matrix,IFFT_bin_length,2);%OFDM解码 即FFT变换
Rx_carriers=Y1(:,carriers);%除去IFFT/FFT变换添加的0，选出映射的子载波
Rx_phase =angle(Rx_carriers);%接收信号的相位
Rx_mag = abs(Rx_carriers);%接收信号的幅度
figure(7);
polar(Rx_phase, Rx_mag,'bd');%极坐标坐标下画出接收信号的星座图
%======================================================================
 
 
[M, N]=pol2cart(Rx_phase, Rx_mag); %将极坐标转化为直角坐标
 
Rx_complex_carrier_matrix = complex(M, N);%创建复数
figure(8);
plot(Rx_complex_carrier_matrix,'*r');%XY坐标接收信号的星座图
axis([-4, 4, -4, 4]);
grid on
%====================16qam解调==================================================
Rx_serial_complex_symbols = reshape(Rx_complex_carrier_matrix',size(Rx_complex_carrier_matrix, 1)*size(Rx_complex_carrier_matrix,2),1)' ;
%并行数据转换成串行数据
Rx_decoded_binary_symbols=demoduqam16(Rx_serial_complex_symbols);%解调
 
 
%============================================================
baseband_in = Rx_decoded_binary_symbols;
 
figure(9);
subplot(2,1,1);
stem(baseband_out(1:100));
subplot(2,1,2);
stem(baseband_in(1:100));
%================误码率计算=============================================
bit_errors=find(baseband_in ~=baseband_out);
bit_error_count = size(bit_errors, 2) 
ber=bit_error_count/baseband_out_length
 