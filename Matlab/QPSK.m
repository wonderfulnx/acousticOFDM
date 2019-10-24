function [qpsk_data] = QPSK(bits)
%
% Syntax: [qpsk_data] = QPSK(bits)
%
% input: bitdata vector (row)
% output: complex qpsk vector (col)
    mapping = [1-1i -1+1i 1+1i -1-1i];
    source = [];
    for i = 1:2:length(bits)
        source = [source, 1 + bits(i) * 2 + bits(i+1)];
    end
    qpsk_data(:, 1) = mapping(source(:));
end