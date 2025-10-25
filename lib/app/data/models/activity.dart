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
        title: m['title'] as String,
        description: m['description'] as String? ?? '',
        date: DateTime.parse(m['date'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
      };

  static Activity sample() => Activity(
        id: 1,
        title: 'Rapat Mingguan',
        description: 'Rapat koordinasi mingguan',
        date: DateTime.now(),
      );
}
