package com.example.ofdmtrans;
import android.Manifest;
import android.content.pm.PackageManager;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Environment;
import android.util.Log;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Calendar;
import java.util.Date;

public class Recorder extends Thread {
    private int samplingRate = 48000;
    private int channelConfiguration = AudioFormat.CHANNEL_IN_MONO;
    private int audioEncoding = AudioFormat.ENCODING_PCM_16BIT;
    private int bufferSize = 0;
    private String filePath = Environment.getExternalStorageDirectory() + "/OFDMTransceiver/raw.wav";

    public boolean recording = false;

    @Override
    public void run() {
        this.startRecord();
        String path = Environment.getExternalStorageDirectory() + "/OFDMTransceiver/receive.wav";
        File file = new File(path);
        if (file.exists()) file.delete();
        try {
            file.createNewFile();
        } catch (IOException e) {
            throw new IllegalStateException("unable to create " + path);
        }
        copyWaveFile(filePath, path);
    }

    private void startRecord() {
        File file = new File(this.filePath);
        if (file.exists()) file.delete();
        try {
            file.createNewFile();
        } catch (IOException e) {
            throw new IllegalStateException("unable to create " + file.toString());
        }
        try {
            // Main work for recording
            OutputStream os = new FileOutputStream(file);
            BufferedOutputStream bos = new BufferedOutputStream(os);
            DataOutputStream dos = new DataOutputStream(bos);

            bufferSize = AudioRecord.getMinBufferSize(samplingRate, channelConfiguration, audioEncoding);
            AudioRecord audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, samplingRate,
                    channelConfiguration, audioEncoding, bufferSize);
            byte[] buffer = new byte[bufferSize];
            audioRecord.startRecording();
            recording = true;
            while (recording) {
                int bufferReadResult = audioRecord.read(buffer, 0, bufferSize);
                for (int i = 0; i < bufferReadResult; i++)
                    dos.write(buffer[i]);
            }
            audioRecord.stop();
            dos.close();
            bos.close();
            os.close();
        } catch (Throwable t){
            Log.e("MainActivity", "failed to record");
        }
    }

    private void copyWaveFile(String inFileName, String outFileName) {
        FileInputStream in = null;
        FileOutputStream out = null;
        long totalAudioLen = 0;
        //wav文件比原始数据文件多出了44个字节，除去表头和文件大小的8个字节剩余文件长度比原始数据多36个字节
        long totalDataLen = totalAudioLen + 36;
        long longSampleRate = samplingRate;
        int channels = 1;
        //每分钟录到的数据的字节数
        long byteRate = 16 * samplingRate * channels / 8;

        byte[] data = new byte[bufferSize];
        try
        {
            in = new FileInputStream(inFileName);
            out = new FileOutputStream(outFileName);
            //获取真实的原始数据长度
            totalAudioLen = in.getChannel().size();
            totalDataLen = totalAudioLen + 36;
            //为wav文件写文件头
            WriteWaveFileHeader(out, totalAudioLen, totalDataLen, longSampleRate, channels, byteRate);
            //把原始数据写入到wav文件中。
            while(in.read(data) != -1)
            {
                out.write(data);
            }
            in.close();
            out.close();
        } catch (FileNotFoundException e)
        {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e)
        {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    public static void WriteWaveFileHeader(FileOutputStream out, long totalAudioLen,
                                           long totalDataLen, long longSampleRate, int channels, long byteRate)
            throws IOException {
        byte[] header = new byte[44];
        header[0] = 'R'; // RIFF/WAVE header
        header[1] = 'I';
        header[2] = 'F';
        header[3] = 'F';
        header[4] = (byte) (totalDataLen & 0xff);
        header[5] = (byte) ((totalDataLen >> 8) & 0xff);
        header[6] = (byte) ((totalDataLen >> 16) & 0xff);
        header[7] = (byte) ((totalDataLen >> 24) & 0xff);
        header[8] = 'W';
        header[9] = 'A';
        header[10] = 'V';
        header[11] = 'E';
        header[12] = 'f'; // 'fmt ' chunk
        header[13] = 'm';
        header[14] = 't';
        header[15] = ' ';
        header[16] = 16;
        header[17] = 0;
        header[18] = 0;
        header[19] = 0;
        header[20] = 1; // WAV type format = 1
        header[21] = 0;
        header[22] = (byte) channels; //指示是单声道还是双声道
        header[23] = 0;
        header[24] = (byte) (longSampleRate & 0xff); //采样频率
        header[25] = (byte) ((longSampleRate >> 8) & 0xff);
        header[26] = (byte) ((longSampleRate >> 16) & 0xff);
        header[27] = (byte) ((longSampleRate >> 24) & 0xff);
        header[28] = (byte) (byteRate & 0xff); //每分钟录到的字节数
        header[29] = (byte) ((byteRate >> 8) & 0xff);
        header[30] = (byte) ((byteRate >> 16) & 0xff);
        header[31] = (byte) ((byteRate >> 24) & 0xff);
        header[32] = (byte) (2 * 16 / 8); // block align
        header[33] = 0;
        header[34] = 16; // bits per sample
        header[35] = 0;
        header[36] = 'd';
        header[37] = 'a';
        header[38] = 't';
        header[39] = 'a';
        header[40] = (byte) (totalAudioLen & 0xff); //真实数据的长度
        header[41] = (byte) ((totalAudioLen >> 8) & 0xff);
        header[42] = (byte) ((totalAudioLen >> 16) & 0xff);
        header[43] = (byte) ((totalAudioLen >> 24) & 0xff);
        //把header写入wav文件
        out.write(header, 0, 44);
    }
}

