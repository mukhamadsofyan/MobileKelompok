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

  // INSERT : tanpa ID (Supabase auto increment)
  Map<String, dynamic> toInsertMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),  // timestamp di Supabase cocok dengan ISO
    };
  }

  // UPDATE : juga tanpa ID (ID dikirim via .eq)
  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
  