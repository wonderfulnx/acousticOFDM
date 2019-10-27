package com.example.asonicofdm;

public class OFDMConfig {

    public int carrier_count;
    public int symbol_per_carrier;
    public int bits_per_symbol;
    public int IFFT_length;
    public int d;
    public double PrefixRatio;
    public double beta;
    public int Fc;
    public int Fs;
    public int GI;
    public int GIP;
    public int[] carriers;
    public int[] conjugate_carriers;
    public int baseband_length;
    public int modulate = 2;
    public int[] preamble;

    public OFDMConfig(boolean is_pre) {
        if (is_pre) {
            carrier_count = 4;
            symbol_per_carrier =2;
            bits_per_symbol = 2;
            IFFT_length = 256;
        }
        else {
            carrier_count = 16;
            symbol_per_carrier = 16;
            bits_per_symbol = 2;
            IFFT_length = 512;
        }
        d = 5;
        PrefixRatio = (double)1 / 4;
        beta = (double)1 / 32;
        Fc = 17000;
        Fs = 10000;
        GI = (int)(PrefixRatio * IFFT_length);
        GIP = (int)(beta * (IFFT_length + GI));
        carriers = new int[carrier_count];
        conjugate_carriers = new int[carrier_count];
        for (int i = 0; i < carrier_count; i++)
            carriers[i] = i + (IFFT_length / 5) - carrier_count / 2;
        for (int i = 0; i < carrier_count; i++)
            conjugate_carriers[i] = IFFT_length - carriers[i];
        baseband_length = carrier_count * symbol_per_carrier * bits_per_symbol;
        modulate = 2;
        preamble = new int[]{0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1};
    }
}
