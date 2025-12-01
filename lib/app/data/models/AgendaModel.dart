class AgendaOrganisasi {
  final int? id;
  final String title;
  final String? description;
  final DateTime date;
  bool isread;

  AgendaOrganisasi({
    this.id,
    required this.title,
    this.description,
    required this.date,
    this.isread = false,
  });

  factory AgendaOrganisasi.fromMap(Map<String, dynamic> map) {
    return AgendaOrganisasi(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      isread: map['isread'] ?? false,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'isread': isread,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'isread': isread,
    };
  }
}
