class SettingModel {
  bool? trial;
  bool? anonymous;
  bool? inappNotice;
  String? marquee;
  String? currentVersion;
  int? versionCode;
  bool? showMarquee;
  String? trialDoctor;
  bool? forceUpdate;

  SettingModel({
    this.trial,
    this.anonymous,
    this.inappNotice,
    this.marquee,
    this.currentVersion,
    this.versionCode,
    this.showMarquee,
    this.trialDoctor,
    this.forceUpdate,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      trial: json['trial'],
      anonymous: json['anonymous'],
      inappNotice: json['inappNotice'],
      marquee: json['marquee'],
      currentVersion: json['version'],
      versionCode: json['versionCode'],
      showMarquee: json['showMarquee'],
      trialDoctor: json['trialDoctor'],
      forceUpdate: json['forceUpdate'],
    );
  }
}
