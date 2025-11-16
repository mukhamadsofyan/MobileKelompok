class Keuanganmodel {
  final int? id;
  final String title;
  final double amount;
  final String type;
  final DateTime date;

  Keuanganmodel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  factory Keuanganmodel.fromMap(Map<String, dynamic> map) {
    return Keuanganmodel(
      id: map['id'],
      title: map['title'] ?? '',
      amount: (map['amount'] is int)
          ? (map['amount'] as int).toDouble()
          : (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}
