class Appointmentpricingmodel {
  String? id;
  String? name;
  int? amount;
  int? dollarAmount;
  int? duration;

  Appointmentpricingmodel({
    this.id,
    this.name,
    this.amount,
    this.dollarAmount,
    this.duration,
  });

  factory Appointmentpricingmodel.fromJson(Map<String, dynamic> json) {
    return Appointmentpricingmodel(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      dollarAmount: json['dollarAmount'],
      duration: json['duration'],
    );
  }
}
