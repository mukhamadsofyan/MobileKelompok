class Activity {
  int? id;
  String title;
  String description;
  DateTime date;

  Activity({
    this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Activity.fromMap(Map<String, dynamic> m) => Activity(
        id: m['id'] as int?,
        title: m['title'] ?? '',
        description: m['description'] ?? '',
        date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,  // biarkan null untuk auto increment
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
      };
}
