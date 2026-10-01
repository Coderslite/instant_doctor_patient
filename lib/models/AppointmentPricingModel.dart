class Appointmentpricingmodel {
  String? id;
  String? name;
  int? amount;
  String? desc;
  int? duration;
  String? type;

  Appointmentpricingmodel({
    this.id,
    this.name,
    this.amount,
    this.desc,
    this.duration,
    this.type,
  });

  factory Appointmentpricingmodel.fromJson(Map<String, dynamic> json) {
    return Appointmentpricingmodel(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      desc: json['description'],
      duration: json['duration'],
      type: json['type'],
    );
  }
}
