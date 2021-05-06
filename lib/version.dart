class Version {
  Version();

  ///更新内容
  String remark;

  ///设备类型
  String deviceType;

  ///0有新版本 1没有新版本
  num currentLastFlag;

  ///更新连接
  String redirectUrl;

  ///0非强制更新 1强制
  num forceFlag;

  ///创建时间
  num createTime;

  ///版本号
  String version;

  factory Version.fromJson(Map json) {
    return Version()
      ..remark = json['remark']?.toString()
      ..deviceType = json['deviceType']?.toString()
      ..currentLastFlag = json['currentLastFlag'] is num ? json['currentLastFlag'] : null
      ..redirectUrl = json['redirectUrl']?.toString()
      ..forceFlag = json['forceFlag'] is num ? json['forceFlag'] : null
      ..createTime = json['createTime'] is num ? json['createTime'] : null
      ..version = json['version']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'remark': remark,
      'deviceType': deviceType,
      'currentLastFlag': currentLastFlag,
      'redirectUrl': redirectUrl,
      'forceFlag': forceFlag,
      'createTime': createTime,
    };
  }

  bool isValidNewVersion() {
    bool isValid = currentLastFlag == 0 &&
        forceFlag != null &&
        (redirectUrl?.isNotEmpty ?? false) &&
        (redirectUrl.startsWith("http"));
    if (!isValid) {
      print("当前版本不是有效版本，请检查传入Json是否异常！");
    }
    return isValid;
  }
}
