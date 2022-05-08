function binary = String2Bin(str)
% string2bi - convert string to binary
%
% Syntax: bits = String2Bin(str)
%
    ascii = abs(str);
    L = length(ascii);
    binary = [];
    for i = 1:L
        b_str = dec2bin(ascii(i), 8);
        for j = 1:8
            binary = [binary, str2num(b_str(j))];
        end
    end
end
