class AgendaOrganisasi {
  int? id;
  String title;
  String? description;
  DateTime date;

  AgendaOrganisasi({
    this.id,
    required this.title,
    this.description,
    required this.date,
  });

  factory AgendaOrganisasi.fromMap(Map<String, dynamic> map) {
    return AgendaOrganisasi(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
