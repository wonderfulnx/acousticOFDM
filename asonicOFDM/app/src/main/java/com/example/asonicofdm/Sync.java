package com.example.asonicofdm;

import java.util.ArrayList;
import java.util.Collections;

public class Sync {
    public static double[] sync(OFDMConfig con_pre, OFDMConfig con, double[] Rx_sound) {
        int preamble_len = con_pre.symbol_per_carrier * (con_pre.GI + con_pre.IFFT_length) + con_pre.GIP;
        int data_len = con.symbol_per_carrier * (con.GI + con.IFFT_length) + con.GIP;

        double[] Rx_sum = getSum(Rx_sound, preamble_len);

        // 找到峰值的target
        int[] x = new int[Rx_sum.length];
        for (int i = 0; i < Rx_sum.length; i++) x[i] = i;
        int[] locs = findallpeaks(x, Rx_sum, 3, preamble_len/10);
        double[] y = new double[locs.length];
        for (int i = 0; i < y.length; i++) y[i] = Rx_sum[locs[i]];
        int[] final_locs = findallpeaks(locs, y, 3, 0);

        for (int att = 0; att < 3 && att < final_locs.length; att++) {

            int target = locs[final_locs[att]] - preamble_len;

            // 匹配Preamble
            ArrayList<Integer> pre_inds = new ArrayList<>();
            for (int i = target > 0 ? target : 0; i < target + preamble_len; i++) {
                double [] rx_data = new double[preamble_len];
                for (int j = 0; j < preamble_len; j++) rx_data[j] = Rx_sound[i + j];
                int[] bits = OFDM.demodulate(con_pre, rx_data);
                if (Utils.bits_equal(bits, con_pre.preamble)) pre_inds.add(i);
            }

            if (!pre_inds.isEmpty()) {
                int final_ind = pre_inds.get(pre_inds.size() / 2) + preamble_len * 2;
                double[] rx_data = new double[data_len];
                for (int i = 0; i < data_len; i++) rx_data[i] = Rx_sound[i + final_ind];
                return rx_data;
            }
        }
        return new double[]{};
    }

    private static double[] getSum(double[] signal, int window_len) {
        double[] Rx_sum = new double[signal.length - window_len];
        double tmp = 0;
        for (int i = 0; i < window_len; i++) tmp += signal[i];
        for (int i = 0; i < signal.length - window_len; i++) {
            Rx_sum[i] = tmp;
            tmp -= Math.abs(signal[i]);
            tmp += Math.abs(signal[window_len + i]);
        }
        return Rx_sum;
    }

    private static int[] findallpeaks(int[] x, double[] y, double threshold, int peakdistance) {
        double[] y_cpy = y.clone();
        double[] markPeaks = dif(sign(dif(y_cpy)));
        int N = x.length;

        // 估计最多可能出现的峰值数目P
        int P = 1;
        for (int i = 0; i < N; i++) if (y_cpy[i] < threshold) y_cpy[i] = Double.MIN_VALUE;
        for (int i = 1; i < N; i++) if ((y_cpy[i] >= threshold) && markPeaks[i-1] == -2) P++;

        // 寻找第一个峰值的位置
        double Peak = threshold;
        ArrayList<Integer> locs = new ArrayList<>();
        locs.add(1);
        for (int i = 1; i < N; i++) if ((y_cpy[i] > Peak) && markPeaks[i-1] == -2) {
            Peak = y_cpy[i];
            locs.set(0, i);
        }
        int M = peakdistance / (x[1] - x[0]);

        // 把峰值附近半径peakdistance以内的数据干掉
        for (int i = 0; i < P; i++){
            int left = 0; int right = N;
            if (locs.get(i) - M >= 0) left = locs.get(i) - M;
            if (locs.get(i) + M < N) right = locs.get(i) + M + 1;
            for (int j = left; j < right; j++) y_cpy[j] = Double.MIN_VALUE;

            Peak = threshold;
            locs.add(Integer.MAX_VALUE);
            for (int j = 1; j < N; j++) if ((y_cpy[j] > Peak) && markPeaks[j - 1] == -2) {
                Peak = y_cpy[j];
                locs.set(i + 1, j);
            }
        }

        // 真实的峰值数目Q
        int Q = 0;
        for (int i = 0; i < P; i++) if (locs.get(i) != Integer.MAX_VALUE) Q++;
        Collections.sort(locs);

        int[] ans = new int[Q];
        for (int i = 0; i < Q; i++) ans[i] = locs.get(i);
        return ans;
    }

    private static double[] sign(double[] s) {
        double[] res = new double[s.length];
        for (int i = 0; i < s.length; i++)
            res[i] = s[i] > 0 ? 1 : -1;
        return res;
    }

    private static double[] dif(double[] y) {
        double[] dy = new double[y.length];
        int len = y.length;
        for (int i = 0; i < len - 1; i++) dy[i] = y[i + 1] - y[i];
        dy[len - 1] = (y[len - 3] + 2 * y[len - 2] + 3 * y[len - 1]) / 6;
        return dy;
    }
}
