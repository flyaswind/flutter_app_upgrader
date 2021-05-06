import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_upgrade/update_dialog_widget.dart';
import 'package:flutter_app_upgrade/version.dart';
import 'package:url_launcher/url_launcher.dart';

///
/// flutter应用升级插件
///   安卓：下载应用包+安装
///   IOS：根据传入的url跳转到AppStore
///
/// 1.提供简单的UI弹窗
///   传入约定的json参考Version对应的json
/// 2.提供直接更新的方法
///   含下载进度/失败回调
///
/// 权限说明：
///   IOS无
///   安卓清单文件需要含有以下配置
///   <uses-permission android:name="android.permission.INTERNET" />
///   <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
///
///   7.0之后的provider配置
///     清单文件application结点内添加
///       <provider
///             android:name="androidx.core.content.FileProvider"
///             android:authorities="{包名}.fileprovider"
///             android:exported="false"
///            android:grantUriPermissions="true">
///             <meta-data
///                 android:name="android.support.FILE_PROVIDER_PATHS"
///                 android:resource="@xml/file_paths" />
///        </provider>
///
///     res/xml/file_paths配置里面需包含 external-path 示例如下
///       <?xml version="1.0" encoding="utf-8"?>
///       <paths xmlns:android="http://schemas.android.com/apk/res/android">
///          <external-path name="external_download" path=""/>
///       </paths>
///
///
class FlutterAppUpgrade {
  static const MethodChannel _channel = const MethodChannel('flutter_app_upgrade');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> _installApk() {
    return _channel.invokeMethod<bool>('installApk');
  }

  static Future<String> _getExternalFilesDirPath() {
    return _channel.invokeMethod<String>('getExternalFilesDirPath');
  }

  static Future<String> _getPackageName() {
    return _channel.invokeMethod<String>('getPackageName');
  }

  ///删除本地已下载的apk包
  ///每次插件引擎挂载成功之后默认会去清除已下载的apk包
  ///极少数特殊情况如有需要也可调用此api来主动清除，比如个人中心设置中的清除缓操作~
  static Future<bool> deleteApk() {
    return _channel.invokeMethod<bool>('deleteApk');
  }

  ///安装本地已经下载好的包
  ///例如如果用户下载完了没有安装又返回到弹窗页面，下载进度100%，再次点击立即更新，则直接安装文件
  static void installLocalUnInstalledApk() async {
    _installApk();
  }

  ///默认提供的ui显示版本更新提示框
  ///versionJson:版本更新json
  ///更新内容remark
  ///是否有新版本 currentLastFlag 0有新版本 1没有新版本
  ///更新连接redirectUrl;
  ///是否强制更新 forceFlag 0非强制更新 1强制
  ///Map mustJson = {"forceFlag": 1, "currentLastFlag": 0, "remark": "我是一个版本更新，此版本是强制更新", "redirectUrl": "http"};
  ///Map json = {"forceFlag": 0, "currentLastFlag": 0, "remark": "我是一个版本更新，此版本不是强制更新，可跳過", "redirectUrl": "http"};
  static void showUpgradeDialog(BuildContext context, Map versionJson) {
    if (context == null || versionJson == null) return;
    Version version = Version.fromJson(versionJson);
    if (version.isValidNewVersion())
      showDialog(
        context: context,
        barrierDismissible: version.forceFlag == 0,
        builder: (context) {
          return UpdateDialogWidget(version);
        },
      );
  }

  ///不使用默认的ui来更新app
  ///安卓下载+安装
  ///iOS去应用市场
  ///url:更新app连接
  ///downLoadCallBack:下载回调
  ///error:更新异常
  static void upgradeApp(String url, {Function downLoadCallBack, Function error}) {
    if (Platform.isIOS) {
      _toAppStore(url, error: error);
    } else if (Platform.isAndroid) {
      _downloadApk(
        url,
        downLoadCallBack: downLoadCallBack,
        error: error,
      );
    }
  }

  static void _toAppStore(String url, {Function error}) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("IOS跳转地址异常:$url");
      error?.call("IOS跳转地址异常:$url");
    }
  }

  static void _downloadApk(String url, {Function downLoadCallBack, Function error}) async {
    if (!Platform.isAndroid) {
      print("此方法只能在Android平台使用");
      error?.call("此方法只能在Android平台使用");
      return;
    }
    if (url?.isEmpty ?? true) {
      print("下载地址为空");
      error?.call("下载地址为空");
      return;
    }
    if (!url.startsWith("http")) {
      print("下载地址异常:$url");
      error?.call("下载地址异常:$url");
      return;
    }
    String externalFilesDirPath = await _getExternalFilesDirPath();
    String packageName = await _getPackageName();
    String saveFilePath = '$externalFilesDirPath/$packageName.apk';
    // _installApk();
    // return;
    await Dio()
        .download(
          url,
          saveFilePath,
          onReceiveProgress: downLoadCallBack,
          options: Options(receiveTimeout: 5 * 60 * 1000),
        )
        .then((value) => _installApk())
        .catchError(
      (err) {
        deleteApk();
        error?.call(err);
      },
    );
  }
}
