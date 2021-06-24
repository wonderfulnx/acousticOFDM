function [bpsk_data] = BPSK(bits, d)
%
% Syntax: [bpsk_data] = BPSK(bits)
%
% input: bitdata vector (row)
% output: complex bpsk vector (col)
    mapping = [d -d];
    source = [];
    for i = 1:length(bits)
        source = [source, 1 + bits(i)];
    end
    bpsk_data(:, 1) = mapping(source(:));
end