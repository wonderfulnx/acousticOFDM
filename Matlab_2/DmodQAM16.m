function bits = DmodQAM16(input， d)
% dmodQAM - demodule QAM16
%
% Syntax: bits = DmodQAM16(input)
%
% input: complex qam vector (col)
% output: bitdata vector (row)
    mapping = [
        -3*d  3*d; -d  3*d; d  3*d; 3*d  3*d;
        -3*d    d; -d    d; d    d; 3*d    d;
        -3*d   -d; -d   -d; d   -d; 3*d   -d;
        -3*d -3*d; -d -3*d; d -3*d; 3*d -3*d;
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