function bits = DmodQPSK(input, d)
%
% Syntax: bits = DmodQPSK(input)
%
% input: complex qpsk vector (col)
% output: bitdata vector (row)
    mapping = [complex(d, -d) complex(-d, d) complex(d, d) complex(-d, -d)];
    for i = 1:length(input)
        for j = 1:4
            dis(j) = abs(input(i, 1) - mapping(j));
        end
        [~, symbol(i)] = min(dis);
    end
    bits = de2bi((symbol - 1)', 2, 'left-msb');
    bits = reshape(bits', 1, 2 * length(input));
end