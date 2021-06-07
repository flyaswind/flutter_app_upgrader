/* 
* created by 1129502088@qq.com
* Date 2021/4/25 10:43
*/

import 'package:flutter/material.dart';
import 'package:flutter_app_upgrade/flutter_app_upgrader.dart';
import 'package:flutter_app_upgrade/version.dart';

class UpdateDialogWidget extends StatefulWidget {
  final Version version;

  UpdateDialogWidget(this.version);

  @override
  _UpdateDialogWidgetState createState() => _UpdateDialogWidgetState();
}

class _UpdateDialogWidgetState extends State<UpdateDialogWidget> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(widget.version?.forceFlag == 0),
      child: UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 3 * 2,
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        '发现新版本',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "${widget.version?.remark ?? ""}",
                        style: TextStyle(color: Color(0xFF333333)),
                      ),
                    ),
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2 - 50 * 2 - 3),
                  ),
                  Offstage(
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 3,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    offstage: _progress == 0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0XFFD8D8D8), width: 0.5)),
                    ),
                    height: 40,
                    child: Row(
                      children: [
                        if (widget.version?.forceFlag == 0)
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (_progress == 0 || _progress == 1) Navigator.pop(context);
                              },
                              child: Center(
                                child: Text(
                                  '暂不更新',
                                  style: TextStyle(color: Color(0xFF999999)),
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_progress == 0) {
                                FlutterAppUpgrader.upgradeApp("${widget.version?.redirectUrl ?? ""}",
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
                                FlutterAppUpgrader.installLocalUnInstalledApk();
                              }
                            },
                            child: Center(
                              child: Text(
                                '立即更新',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
