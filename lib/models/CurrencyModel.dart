class CurrencyModel {
  String? id;
  String? symbol;

  CurrencyModel({this.id, this.symbol});
  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(id: json['id'], symbol: json['symbol']);
  }
}
