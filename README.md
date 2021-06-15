**flutter 应用升级插件**

**升级功能说明：**

	应用程序升级是 App 的基础功能之一，下面介绍应用程序升级的方式：
	从平台方面来说：
	IOS：跳转到 app store 升级。
	Android：跳转到应用市场升级，或下载 apk 包升级。
	从强制性来说：
	强制升级：用户必须升级才能继续使用 App。
	非强制升级：用户可以选择取消升级当前版本。

**升级流程说明：**

	访问后台接口获取是否有新的版本，IOS 还可通过https://itunes.apple.com/cn/lookup?bundleId=*** 来获取。
	有新版本则弹出升级提示框，根据当前版本是否是强制更新控制是否显示取消按钮。
	用户如选择取消，提示框消失。
	用户如选择升级，IOS 跳转 app store 完成更新，Android 下载 apk 完成后跳转到 apk 安装页面。

**安装说明：**

	在pubspec.yaml中加入：
		flutter_app_upgrader:
			git:
				url: https://github.com/flyaswind/flutter_app_upgrader.git
	执行flutter命令获取包
		flutter pub get
	引入
		import 'package:flutter_app_upgrader/flutter_app_upgrader.dart';

	安卓平台需要的额外配置：
		安卓清单文件./android/app/src/main/AndroidManifest.xml 需要含有以下配置
		权限配置：
			<uses-permission android:name="android.permission.INTERNET" />
			<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

		application 结点内添加
			<provider
				android:name="androidx.core.content.FileProvider"
				android:authorities="{包名}.fileprovider"
				android:exported="false"
				android:grantUriPermissions="true">
				<meta-data
						android:name="android.support.FILE_PROVIDER_PATHS"
						android:resource="@xml/file_paths" />
			</provider>

		./android/app/src/main/res/xml/file_paths 配置里面需包含 external-path 示例如下
			<?xml version="1.0" encoding="utf-8"?>
			<paths xmlns:android="http://schemas.android.com/apk/res/android">
				<external-path name="external_download" path=""/>
				...
			</paths>

**使用说明：**

	1.提供简单的 UI 弹窗
    //传入约定的json参考Version对应的json
    //remark 更新内容
    //currentLastFlag 是否有新版本  0有新版本 1没有新版本
    //redirectUrl 更新连接
    //forceFlag 是否强制更新 0非强制更新 1强制
    var upgradeJson={
		"forceFlag": 1,
		"currentLastFlag": 0,
		"remark": "我是一个版本更新，此版本是强制更新，我是更新内容",
		"redirectUrl": "https://*******.apk"
    };
    FlutterAppUpgrader.showUpgradeDialog(context, upgradeJson);

    2.提供直接更新的方法
    //传入更新地址，安卓完成下载安装，iOS跳转到AppStore
    //含下载进度/失败回调
    //url 更新的连接 iOS是跳转app store地址 android是apk下载地址
    //downLoadCallBack 下载过程中的回调
    //error 异常信息的回调
    FlutterAppUpgrader.upgradeApp(
    	"https://*****.apk",
        downLoadCallBack: (current, total) {
        	print("共$total,已下载$current");
        },
        error: (err) {
        	print("更新异常：$err");
        },
    );

    3.提供检查IOS AppStore里是否有不同版本的方法
    bool hasNewVersion = await FlutterAppUpgrader.hasNewVersionInAppStore();


