function [qam_data] = QAM16mod(bits, d)
% QAM16 modulation, use 16 QAM to modulate input bit data, 
%   output QAM complex data
% 
% Usage:
%   [qam_data] = QAM16(bits)
%   input:
%           bits       -> bit data vector (row)
%           d          -> distance of output data to origin
%   output: qam_data  -> complex QAM vector (col)
%
    d1 = d / (3 * sqrt(2));
    mapping = [
        -3*d1  3*d1; -d1  3*d1; d1  3*d1; 3*d1  3*d1;
        -3*d1    d1; -d1    d1; d1    d1; 3*d1    d1;
        -3*d1   -d1; -d1   -d1; d1   -d1; 3*d1   -d1;
        -3*d1 -3*d1; -d1 -3*d1; d1 -3*d1; 3*d1 -3*d1;
    ];
    source = [];
    for i = 1:4:length(bits)
        source = [source, 1 + bits(i)*8 + bits(i+1)*4 + bits(i+2)*2 + bits(i+3)];
    end
    for i = 1:length(bits)/4
        pos_data(i, :) = mapping(source(i), :);
    end
    qam_data = complex(pos_data(:, 1), pos_data(:, 2));
end
