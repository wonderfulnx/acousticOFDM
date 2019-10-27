package com.example.asonicofdm;

public class OFDM {
    public static double[] modulate(OFDMConfig config, int[] bits) {
        // 目前只写了QPSK
        Complex[] complex_data = Utils.qpsk(bits, config.d);

        // IFFT
        double[][] time_mat_cp = new double[config.symbol_per_carrier][config.IFFT_length + config.GI + config.GIP];
        for (int i = 0; i < config.symbol_per_carrier; i++)
            for (int j = 0; j < config.IFFT_length + config.GI + config.GIP; j++) time_mat_cp[0][0] = 0;

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

            // 将结果放入矩阵 添加循环前后缀
            for (int i = 0; i < config.GI; i++) time_mat_cp[sym_cnt][i] = ifft_res[i + config.IFFT_length - config.GI];
            for (int i = 0; i < config.IFFT_length; i++) time_mat_cp[sym_cnt][i + config.GI] = ifft_res[i];
            for (int i = 0; i < config.GIP; i++) time_mat_cp[sym_cnt][config.IFFT_length + config.GI + i] = ifft_res[i];
        }

        // 加窗
        for (int sym_cnt = 0; sym_cnt < config.symbol_per_carrier; sym_cnt++) {
            double[] rcosw = Utils.rcoswindow(config.beta, config.IFFT_length + config.GI);
            for (int i = 0; i < config.IFFT_length + config.GI + 1; i++)
                time_mat_cp[sym_cnt][i] *= rcosw[i];
        }

        // 并转串
        double[] Tx_data = new double[config.symbol_per_carrier*(config.IFFT_length + config.GI)+config.GIP];
        for (int i = 0; i < config.IFFT_length + config.GI + config.GIP; i++)
            Tx_data[i] = time_mat_cp[0][i];
        for (int i = 1; i < config.symbol_per_carrier; i++)
            // for (int j = (config.IFFT_length + config.GI)*i; j < (config.IFFT_length + config.GI)*(i+1)+config.GIP; j++)
            for (int j = 0; j < config.IFFT_length + config.GI + config.GIP; j++)
                Tx_data[(config.IFFT_length + config.GI)*i + j] = time_mat_cp[i][j];

        return Tx_data;
    }

    public static 
}
