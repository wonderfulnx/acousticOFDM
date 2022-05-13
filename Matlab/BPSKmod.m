function [bpsk_data] = BPSKmod(bits, d)
% BPSK modulation, output BPSK complex data
% 
% Usage:
%   bpsk_data = BPSKmod(bits, d);
%   input:
%           bits       -> bit data vector (row)
%           d          -> distance of output data to origin
%   output: bpsk_data  -> complex bpsk vector (col)
%
    mapping = [d -d];
    source = [];
    for i = 1:length(bits)
        source = [source, 1 + bits(i)];
    end
    bpsk_data(:, 1) = mapping(source(:));
end