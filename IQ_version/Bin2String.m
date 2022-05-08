function str = Bin2String(bin)
% string2bi - convert binary to string
%
% Syntax: bits = Bin2String(str)
%
    mapping = '0123456789ABCDEF';
    str = "0x";
    for i = 1:4:length(bin)
        str = [str, mapping(bin(i) * 8 + bin(i+1) * 4 + bin(i+2) * 2 + bin(i+3) + 1)];
    end
end
    