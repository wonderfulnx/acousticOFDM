package com.example.ofdmtrans;

import android.os.Environment;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class Utils {
    public static String messageFilePath = Environment.getExternalStorageDirectory() + "/OFDMTransceiver/message.wav";
    public static String rawFilePath = Environment.getExternalStorageDirectory() + "/OFDMTransceiver/raw.wav";
    public static String folderPath = Environment.getExternalStorageDirectory() + "/OFDMTransceiver";

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

    public static byte[] doubles2bytes(double[] ds) {
        byte[] ans = new byte[2 * ds.length];
        int idx = 0;
        for (final double dval: ds) {
            final short val = (short)(dval * 32767);
            ans[idx++] = (byte)(val & 0x00ff);
            ans[idx++] = (byte)((val & 0xff00) >>> 8);
        }
        return ans;
    }

    public static void writeMessage(double[] Preamble, double[] Tx_data) {
        File file = new File(messageFilePath);
        if (file.exists()) file.delete();
        try { file.createNewFile(); } catch (IOException e){
            throw new IllegalStateException("unable to create " + file.toString());
        }
        long longSampleRate = 10000;
        int channels = 1;
        //每分钟录到的数据的字节数
        long byteRate = 16 * longSampleRate * channels / 8;

        byte[] preamble = doubles2bytes(Preamble);
        byte[] tx_data = doubles2bytes(Tx_data);
        byte[] blank = new byte[preamble.length];
        for (int i = 0; i < blank.length; i++) blank[i] = 0;

        try {
            FileOutputStream os = new FileOutputStream(file);
            int audio_len = preamble.length * 2 + tx_data.length;
            Recorder.WriteWaveFileHeader(os, audio_len, audio_len + 36, longSampleRate, channels, byteRate);
            os.write(preamble);
            os.write(blank);
            os.write(tx_data);
            os.close();
        } catch (Throwable t){
            Log.e("MainActivity", "failed to write");
        }
        return;
    }

    public static double[] readRaw() {
        double [] res = {};
        try {
            FileInputStream in = new FileInputStream(rawFilePath);
            long audioLen = in.getChannel().size();
            res = new double[(int)(audioLen / 2)];
            int ind = 0;
            byte[] buff = new byte[2];
            while (in.read(buff) != -1) {
                short s = (short)((buff[1] & 0x00ff) << 8 | buff[0] & 0x00ff);
                res[ind++] = s / 32768f;
            }
        } catch (IOException e) {
            Log.e("Main Activity", "Error Occur");
        }

        return res;
    }
}
