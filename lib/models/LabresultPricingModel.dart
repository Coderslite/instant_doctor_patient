class LabresultPricingModel {
  String? id;
  String? name;
  int? dollarAmount;
  int? amount;

  LabresultPricingModel({
    this.id,
    this.name,
    this.amount,
    this.dollarAmount,
  });

  factory LabresultPricingModel.fromJson(Map<String, dynamic> json) {
    return LabresultPricingModel(
      id: json['id'],
      name: json['name'],
      amount: json['price'],
      dollarAmount: json['dollarAmount'],
    );
  }
}
