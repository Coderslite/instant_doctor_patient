class Appointmentpricingmodel {
  String? id;
  String? name;
  int? amount;
  String? desc;
  int? duration;

  Appointmentpricingmodel({
    this.id,
    this.name,
    this.amount,
    this.desc,
    this.duration,
  });

  factory Appointmentpricingmodel.fromJson(Map<String, dynamic> json) {
    return Appointmentpricingmodel(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      desc: json['description'],
      duration: json['duration'],
    );
  }
}
