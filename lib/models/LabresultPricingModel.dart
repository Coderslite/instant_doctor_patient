class LabresultPricingModel {
  String? id;
  String? name;
  int? amount;

  LabresultPricingModel({
    this.id,
    this.name,
    this.amount,
  });

  factory LabresultPricingModel.fromJson(Map<String, dynamic> json) {
    return LabresultPricingModel(
      id: json['id'],
      name: json['name'],
      amount: json['price'],
    );
  }
}
