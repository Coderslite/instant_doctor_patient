class Appointmentpricingmodel {
  String? id;
  String? name;
  int? amount;
  int? duration;

  Appointmentpricingmodel({
    this.id,
    this.name,
    this.amount,
    this.duration,
  });

  factory Appointmentpricingmodel.fromJson(Map<String, dynamic> json) {
    return Appointmentpricingmodel(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      duration: json['duration'],
    );
  }
}
