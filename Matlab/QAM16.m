function [qam_data] = QAM16(bits)
% QAM16 - use 16 QAM to modulate input bit data
%
% Syntax: [qam_data] = QAM16(bits)
%
% input: bitdata vector (row)
% output: complex qam vector (col)
    d = 1;
    mapping = [
        -3*d  3*d; -d  3*d; d  3*d; 3*d  3*d;
        -3*d    d; -d    d; d    d; 3*d    d;
        -3*d   -d; -d   -d; d   -d; 3*d   -d;
        -3*d -3*d; -d -3*d; d -3*d; 3*d -3*d;
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
