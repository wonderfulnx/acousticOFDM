function bits = DmodQPSK(input)
%
% Syntax: bits = DmodQPSK(input)
%
% input: complex bpsk vector (col)
% output: bitdata vector (row)
    mapping = [1 -1];
    for i = 1:length(input)
        for j = 1:2
            dis(j) = abs(input(i, 1) - mapping(j));
        end
        [~, symbol(i)] = min(dis);
    end
    bits = de2bi((symbol - 1)', 1, 'left-msb');
    bits = reshape(bits', 1, length(input));
end