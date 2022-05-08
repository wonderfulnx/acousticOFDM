function [rcosw]=rcoswindow(beta, len)
    %定义升余弦窗，其中beta为滚降系数，len为需要的窗长度
    t = 0:len;
    rcosw = ones(1, len); 
    for i = 1:(beta * len)
        rcosw(i) = 0.5 + 0.5 * cos(pi + t(i)*pi/(beta*len));
    end
    for j = len:-1:(1-beta)*len+1
        rcosw(j) = rcosw(len+1-j);
    end
    rcosw=rcosw';
end