package com.example.asonicofdm;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Bundle;
import com.example.asonicofdm.Recorder;

import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

public class MainActivity extends AppCompatActivity {
    protected static final String TAG = "RecordActivity";
    private Button start_btn;
    private EditText editText;
    private Recorder recorder;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        getPermission();

        // ------------- UI init
        this.editText = this.findViewById(R.id.editText);
        this.editText.setKeyListener(null);

        this.start_btn = this.findViewById(R.id.record);
        this.start_btn.setOnClickListener(new View.OnClickListener() {
            boolean recording = false;
            @Override
            public void onClick(View view) {
                if (this.recording) {
                    this.recording = false;
                    //结束录音

                    recorder.recording = false;
                    try {
                        recorder.join();
                    } catch (InterruptedException e){
                        Log.e(TAG, "record thread Interrupted;");
                    }

                    MainActivity.this.logToDisplay("end the record.");
                    MainActivity.this.start_btn.setText("Start Record");
                }
                else {
                    this.recording = true;
                    // 开始录音
                    MainActivity.this.logToDisplay("start the record.");
                    recorder = new Recorder();
                    recorder.start();
                    MainActivity.this.start_btn.setText("Stop Record");
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void getPermission() {

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)!=
                PackageManager.PERMISSION_GRANTED||
        ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)!=
                PackageManager.PERMISSION_GRANTED||
                ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)!=
                        PackageManager.PERMISSION_GRANTED
        ) {

            ActivityCompat.requestPermissions(this,
                    new String[]{android.Manifest.permission.RECORD_AUDIO,
                            android.Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            Manifest.permission.READ_EXTERNAL_STORAGE}, 0);
        }
    }

    private void logToDisplay(final String msg) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                MainActivity.this.editText.append(msg + "\n");
            }
        });
    }
}
