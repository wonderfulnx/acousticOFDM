package com.example.asonicofdm;

public class OFDM {
    public static double[] modulate(OFDMConfig config, int[] bits) {
        // 目前只写了QPSK
        Complex[] complex_data = Utils.qpsk(bits, config.d);

        // IFFT


        for (int sym_cnt = 0; sym_cnt < config.symbol_per_carrier; sym_cnt++) {

            // 分别计算ifft
            Complex[] ifft_mod = new Complex[config.IFFT_length];
            double[] ifft_res = new double[config.IFFT_length];
            for (int i = 0; i < config.IFFT_length; i++) ifft_mod[i] = new Complex(0,0);

            for (int car_cnt = 0; car_cnt < config.carrier_count; car_cnt++) {
                ifft_mod[config.carriers[car_cnt]] = complex_data[sym_cnt * config.carrier_count + car_cnt];
                ifft_mod[config.conjugate_carriers[car_cnt]] =
                        (complex_data[sym_cnt * config.carrier_count + car_cnt]).conjugate();
            }
            Complex[] tmp = FFT.ifft(ifft_mod);
            for (int i = 0; i < tmp.length; i++) ifft_res[i] = tmp[i].re();

            // 将结果放入矩阵
        }


        return new double[]{};
    }
}
