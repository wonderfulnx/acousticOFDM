package com.example.ofdmtrans;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.app.ActivityCompat;
import android.os.Bundle;

import android.Manifest;
import android.content.pm.PackageManager;
import android.media.MediaPlayer;

import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import java.io.File;
import java.io.IOException;

public class MainActivity extends AppCompatActivity {
    protected static final String TAG = "RecordActivity";
    MainActivity main_activity = this;
    private Button play_btn;
    private Button record_btn;
    private Button clear_btn;
    private EditText editText;
    private Recorder recorder;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        getPermission();

        // editText init
        this.editText = this.findViewById(R.id.editText);
        this.editText.setKeyListener(null);

        // play signal init
        this.play_btn = this.findViewById(R.id.play_btn);
        this.play_btn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                // play signal
                MediaPlayer mediaPlayer = new MediaPlayer();
                try {
                    if (ContextCompat.checkSelfPermission(main_activity, Manifest.permission.READ_EXTERNAL_STORAGE)!=
                            PackageManager.PERMISSION_GRANTED
                    ) {
                        ActivityCompat.requestPermissions(main_activity, new String[]{android.Manifest.permission.READ_EXTERNAL_STORAGE}, 0);
                    }
                    File f = new File(Utils.messageFilePath);
                    if (f.canRead()) Log.e(TAG, "can read");
                    else Log.e(TAG, "cant read");
                    mediaPlayer.setDataSource(Utils.messageFilePath);
                    mediaPlayer.prepare();
                    mediaPlayer.setLooping(false);
                    mediaPlayer.start();

                    MainActivity.this.play_btn.setEnabled(false);
                    MainActivity.this.record_btn.setEnabled(false);
                    MainActivity.this.clear_btn.setEnabled(false);

                    while (mediaPlayer.isPlaying());
                    mediaPlayer.stop();
                    mediaPlayer.release();

                    MainActivity.this.play_btn.setEnabled(true);
                    MainActivity.this.record_btn.setEnabled(true);
                    MainActivity.this.clear_btn.setEnabled(true);
                } catch (IOException e) {
                    Log.e(TAG, "unable to play source");
                    MainActivity.this.logToDisplay("unable to play source.");
                }
            }
        });

        // Record btn init
        this.record_btn = this.findViewById(R.id.record_btn);
        this.record_btn.setOnClickListener(new View.OnClickListener() {
            boolean recording = false;
            @Override
            public void onClick(View view) {
                if (this.recording) {
                    this.recording = false;
                    //结束录音

                    MainActivity.this.recorder.recording = false;
                    try {
                        MainActivity.this.recorder.join();
                    } catch (InterruptedException e){
                        Log.e(TAG, "record thread Interrupted;");
                    }

                    MainActivity.this.logToDisplay("end the record.");

                    MainActivity.this.play_btn.setEnabled(true);
                    MainActivity.this.record_btn.setText("RECORD");
                }
                else {
                    this.recording = true;
                    // 开始录音
                    MainActivity.this.logToDisplay("start the record.");
                    recorder = new Recorder();
                    recorder.start();
                    MainActivity.this.play_btn.setEnabled(false);
                    MainActivity.this.record_btn.setText("STOP RECORD");
                }
            }
        });

        // clear btn init
        this.clear_btn = this.findViewById(R.id.clear_btn);
        this.clear_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                MainActivity.this.editText.setText("");
            }
        });

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void getPermission() {

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)!=
                PackageManager.PERMISSION_GRANTED||
                ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)!=
                        PackageManager.PERMISSION_GRANTED||
                ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)!=
                        PackageManager.PERMISSION_GRANTED
        ) {

            ActivityCompat.requestPermissions(this,
                    new String[]{android.Manifest.permission.RECORD_AUDIO,
                            android.Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            android.Manifest.permission.READ_EXTERNAL_STORAGE}, 0);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case 0:
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 &&
                        grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    MainActivity.this.logToDisplay("Permission granted.");
                    // Permission is granted. Continue the action or workflow
                    // in your app.
                } else {
                    MainActivity.this.logToDisplay("Failed to get permission.");
                    // Explain to the user that the feature is unavailable because
                    // the features requires a permission that the user has denied.
                    // At the same time, respect the user's decision. Don't link to
                    // system settings in an effort to convince the user to change
                    // their decision.
                }
                return;
        }
        // Other 'case' lines to check for other
        // permissions this app might request.
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