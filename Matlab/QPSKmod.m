function [qpsk_data] = QPSKmod(bits, d)
% QPSK modulation, output QPSK complex data
% 
% Usage:
%   qpsk_data = QPSKmod(bits, d);
%   input:
%           bits       -> bit data vector (row)
%           d          -> max distance of output data to origin
%   output: qpsk_data  -> complex qpsk vector (col)
%
    d1 = d / sqrt(2);
    mapping = [complex(d1, -d1) complex(-d1, d1) complex(d1, d1) complex(-d1, -d1)];
    source = [];
    for i = 1:2:length(bits)
        source = [source, 1 + bits(i) * 2 + bits(i+1)];
    end
    qpsk_data(:, 1) = mapping(source(:));
end