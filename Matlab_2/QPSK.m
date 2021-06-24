function [qpsk_data] = QPSK(bits, d)
%
% Syntax: [qpsk_data] = QPSK(bits)
%
% input: bitdata vector (row)
% output: complex qpsk vector (col)
    mapping = [complex(d, -d) complex(-d, d) complex(d, d) complex(-d, -d)];
    source = [];
    for i = 1:2:length(bits)
        source = [source, 1 + bits(i) * 2 + bits(i+1)];
    end
    qpsk_data(:, 1) = mapping(source(:));
end