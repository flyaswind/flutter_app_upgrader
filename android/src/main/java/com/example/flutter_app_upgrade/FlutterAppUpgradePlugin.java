package com.example.flutter_app_upgrade;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import java.io.File;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterAppUpgradePlugin
 */
public class FlutterAppUpgradePlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_app_upgrade");
        channel.setMethodCallHandler(this);
        deleteApk();
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("getExternalFilesDirPath")) {
            result.success(context.getExternalFilesDir(null).getAbsolutePath());
        } else if (call.method.equals("getPackageName")) {
            result.success(context.getPackageName());
        } else if (call.method.equals("installApk")) {
            try {
                installApk();
                result.success(true);
            } catch (Exception e) {
                System.out.println(e.getMessage());
                result.success(false);
            }
        } else if (call.method.equals("deleteApk")) {
            try {
                deleteApk();
                result.success(true);
            } catch (Exception e) {
                System.out.println(e.getMessage());
                result.success(false);
            }
        } else {
            result.notImplemented();
        }
    }

    private void deleteApk() {
        String apkPath = context.getExternalFilesDir(null).getAbsolutePath() + "/" + context.getPackageName() + ".apk";
        System.out.println("apkPath:" + apkPath);
        File file = new File(apkPath);
        if (file.isFile() && file.exists()) {
            file.delete();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }


    private void installApk() {
        String apkPath = context.getExternalFilesDir(null).getAbsolutePath() + "/" + context.getPackageName() + ".apk";
        File apk = new File(apkPath);
//        System.out.println(apkPath + "=====" + apk.isFile() + "===" + apk.exists());
        if (!apk.isFile()) return;
        if (!apk.exists()) return;
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            Uri uri = FileProvider.getUriForFile(context, context.getPackageName() + ".fileprovider", apk);
            intent.setDataAndType(uri, "application/vnd.android.package-archive");
        } else {
            intent.setDataAndType(Uri.fromFile(apk), "application/vnd.android.package-archive");
        }

        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }
}