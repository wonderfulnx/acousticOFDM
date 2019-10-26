package com.example.asonicofdm;

public class Utils {
    public static int[] generate_rand(int length) {
        // 生成随机二进制串
        int[] res = new int[length];
        for (int i = 0; i < length; i++) {
            res[i] = Math.random() > 0.5 ? 0 : 1;
        }
        return res;
    }

    public static String bin2str(int[] bits) {
        // bits流转为字节
        int len = bits.length;
        assert len % 4 == 0;
        String str = "0123456789ABCEDF";
        char[] ans = new char[len / 4];
        for (int i = 0; i < len; i += 4){
            ans[i/4] = str.charAt(bits[i] * 8 + bits[i+1] * 4 + bits[i+2] * 2 + bits[i+3]);
        }
        return "0x" + new String(ans);
    }

    public static Complex[] qpsk(int[] bits, int d) {
        int len = bits.length;
        Complex[] mapping = new Complex[]{ new Complex(d, -d), new Complex(-d, d), new Complex(d, d), new Complex(-d, -d)};
        Complex[] data = new Complex[len / 2];
        for (int i = 0; i < len; i += 2)
            data[i/2] = mapping[bits[i] * 2 + bits[i+1]];
        return data;
    }

    public static int[] dmod_qpsk(Complex[] input, int d) {
        int len = input.length;
        Complex[] mapping = new Complex[]{ new Complex(d, -d), new Complex(-d, d), new Complex(d, d), new Complex(-d, -d)};
        int[] bits = new int[len * 2];
        for (int i = 0; i < len; i++) {
            double min_dis = Double.MAX_VALUE; int min_ind = 0;
            for (int j = 0; j < 4; j++) {
                double dis = (input[i].minus(mapping[j])).abs();
                if (dis < min_dis) { min_dis = dis; min_ind = j; }
            }
            bits[2 * i] = (min_ind / 2) % 2;
            bits[2 * i + 1] = min_ind % 2;
        }
        return bits;
    }

}
