# flutter_app_upgrade

A new Flutter plugin.



flutter应用升级插件
   安卓：下载应用包+安装
   IOS：根据传入的url跳转到AppStore

   1.提供简单的UI弹窗
    //传入约定的json参考Version对应的json
    //更新内容remark
    //是否有新版本 currentLastFlag 0有新版本 1没有新版本
    //更新连接redirectUrl;
    //是否强制更新 forceFlag 0非强制更新 1强制
    var mustJson={
    	"forceFlag": 1,
    	"currentLastFlag": 0,
    	"remark": "我是一个版本更新，此版本是强制更新，我是更新内容",
    	"redirectUrl": "https://*******.apk"
    };
    FlutterAppUpgrade.showUpgradeDialog(context, mustJson);

   2.提供直接更新的方法
    含下载进度/失败回调
    FlutterAppUpgrade.upgradeApp(
                      "https://*****.apk",
                      downLoadCallBack: (current, total) {
                        print("共$total,已下载$current");
                      },
                      error: (err) {
                        print("更新异常：$err");
                      },
                    );

    权限说明：
        IOS无
        安卓清单文件需要含有以下配置
            <uses-permission android:name="android.permission.INTERNET" />
            <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

        7.0之后的provider配置
            清单文件application结点内添加
                <provider
                    android:name="androidx.core.content.FileProvider"
                    android:authorities="{包名}.fileprovider"
                    android:exported="false"
                    android:grantUriPermissions="true">
                          <meta-data
                                android:name="android.support.FILE_PROVIDER_PATHS"
                                android:resource="@xml/file_paths" />
                </provider>

            res/xml/file_paths配置里面需包含 external-path 示例如下
                <?xml version="1.0" encoding="utf-8"?>
                <paths xmlns:android="http://schemas.android.com/apk/res/android">
                    <external-path name="external_download" path=""/>
                </paths>


