function [rcosw] = rcoswindow(beta, len)
% Raised-cosine window function, where beta is the roll-off factor,
%   and len is the desired length
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