function [rcosw]=rcoswindow(beta, Ts)
    %定义升余弦窗，其中beta为滚降系数，Ts为包含循环前缀的OFDM符号的长度,Ts为正偶数
    t = 0 : (1+beta)*Ts;
    rcosw = zeros(1, (1 + beta) * Ts); 
    for i = 1:(beta * Ts)
        rcosw(i)=0.5+0.5*cos(pi+ t(i)*pi/(beta*Ts));
    end
        rcosw(beta*Ts+1:Ts)=1;
    for j=Ts+1:(1+beta)*Ts+1
        rcosw(j-1)=0.5+0.5*cos((t(j)-Ts)*pi/(beta*Ts)); 
    end
    rcosw=rcosw';
end