function bits = BPSKdemod(input, d)
% BPSK demodulation, output bits
% 
% Usage:
%   bits = BPSKdemod(input, d)
%   input:
%           input      -> complex bpsk vector (col)
%           d          -> distance of output data to origin
%   output: bits       -> bitdata vector (row)
%
    mapping = [d -d];
    for i = 1:length(input)
        for j = 1:2
            dis(j) = abs(input(i, 1) - mapping(j));
        end
        [~, symbol(i)] = min(dis);
    end
    bits = de2bi((symbol - 1)', 1, 'left-msb');
    bits = reshape(bits', 1, length(input));
end