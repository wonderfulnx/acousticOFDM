function bits = QAM16demod(input, d)
% QAM16 demodulation, output bits
% 
% Usage:
%   bits = QAM16demod(input, d)
%   input:
%           input      -> complex qam vector (col)
%           d          -> distance of output data to origin
%   output: bits       -> bitdata vector (row)
%
    d1 = d / (3 * sqrt(2));
    mapping = [
        -3*d1  3*d1; -d1  3*d1; d1  3*d1; 3*d1  3*d1;
        -3*d1    d1; -d1    d1; d1    d1; 3*d1    d1;
        -3*d1   -d1; -d1   -d1; d1   -d1; 3*d1   -d1;
        -3*d1 -3*d1; -d1 -3*d1; d1 -3*d1; 3*d1 -3*d1;
    ];
    com_mapping = complex(mapping(:, 1), mapping(:, 2));
    for i = 1:length(input)
        for j = 1:16
            dis(j) = abs(input(i, 1) - com_mapping(j, 1));
        end
        [min_dis, symbol(i)] = min(dis);
    end
    bits = de2bi((symbol - 1)', 4, 'left-msb');
    bits = reshape(bits', 1, 4 * length(input));
end