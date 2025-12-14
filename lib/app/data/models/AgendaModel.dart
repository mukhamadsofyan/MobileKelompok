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
      id: map['id'] as int?,
      title: map['title']?.toString() ?? '', // ✅ AMAN
      description: map['description']?.toString(),
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.fromMillisecondsSinceEpoch(0), // ✅ AMAN
      isread: map['isread'] == true,
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
