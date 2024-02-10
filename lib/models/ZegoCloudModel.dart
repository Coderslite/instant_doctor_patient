class ZegocloudModel {
  int? appId;
  String? appSign;
  bool? inUse;

  ZegocloudModel({
    this.appId,
    this.appSign,
    this.inUse,
  });

  factory ZegocloudModel.fromJson(Map<String, dynamic> json) {
    return ZegocloudModel(
      appId: json['appId'],
      appSign: json['appSign'],
      inUse: json['inUse'],
    );
  }
}
