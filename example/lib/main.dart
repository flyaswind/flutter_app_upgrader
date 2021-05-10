import 'package:flutter/material.dart';

import 'package:flutter_app_upgrade/flutter_app_upgrade.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: [
            RaisedButton(
              onPressed: () {
                Map mustJson = {
                  "forceFlag": 1,
                  "currentLastFlag": 0,
                  "remark": "我是一个版本更新，此版本是强制更新",
                  "redirectUrl": "https://gz.bcebos.com/v1/newretail/test/update.apk"
                };
                FlutterAppUpgrade.showUpgradeDialog(context, mustJson);
              },
              child: Text("弹强更窗口"),
            ),
            RaisedButton(
              onPressed: () {
                Map json = {
                  "forceFlag": 0,
                  "currentLastFlag": 0,
                  "remark": "我是一个版本更新，此版本不是强制更新，可跳過",
                  "redirectUrl": "https://gz.bcebos.com/v1/newretail/test/update.apk"
                };
                FlutterAppUpgrade.showUpgradeDialog(context, json);
              },
              child: Text("弹非强更窗口"),
            ),
            RaisedButton(
              onPressed: () {
                Map json = {"forceFlag": 0, "currentLastFlag": 1, "remark": "我是一个版本更新，此版本不是强制更新，可跳過"};
                FlutterAppUpgrade.showUpgradeDialog(context, json);
              },
              child: Text("传入没有新版本的数据"),
            ),
            RaisedButton(
              onPressed: () {
                if ((_progress ?? 0) == 0) {
                  FlutterAppUpgrade.upgradeApp("https://gz.bcebos.com/v1/newretail/test/update.apk",
                      downLoadCallBack: (current, total) {
                    print("downLoad===current:$current,total:$total");
                    setState(() {
                      _progress = current / total;
                    });
                  }, error: (err) {
                    print("downLoadError:$err");
                    setState(() {
                      _progress = 0;
                    });
                  });
                } else if (_progress == 1) {
                  FlutterAppUpgrade.installLocalUnInstalledApk();
                }
              },
              child: Text("直接调用更新api   ${(_progress ?? 0) * 100}%"),
            ),
            RaisedButton(
              onPressed: () async {
                bool hasNewVersion = await FlutterAppUpgrade.hasNewVersionInAppStore();
                print("=====$hasNewVersion");
              },
              child: Text("检查IOS当前版本是否是最新的"),
            ),
          ],
        ),
      ),
    );
  }
}
