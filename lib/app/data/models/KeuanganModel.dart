class Keuanganmodel {
  final int? id;
  final String title;
  final double amount;
  final String type; // "Pemasukan" / "Pengeluaran"
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
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  factory Keuanganmodel.fromMap(Map<String, dynamic> map) {
    return Keuanganmodel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: map['type'],
      date: DateTime.parse(map['date']),
    );
  }
}
