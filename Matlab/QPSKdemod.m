function bits = QPSKdemod(input, d)
% QPSK demodulation, output bits
% 
% Usage:
%   bits = QPSKdemod(input, d)
%   input:
%           input      -> complex qpsk vector (col)
%           d          -> distance of output data to origin
%   output: bits       -> bitdata vector (row)
%
    d1 = d / sqrt(2);
    mapping = [complex(d1, -d1) complex(-d1, d1) complex(d1, d1) complex(-d1, -d1)];
    for i = 1:length(input)
        for j = 1:4
            dis(j) = abs(input(i, 1) - mapping(j));
        end
        [~, symbol(i)] = min(dis);
    end
    bits = de2bi((symbol - 1)', 2, 'left-msb');
    bits = reshape(bits', 1, 2 * length(input));
end