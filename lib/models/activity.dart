class Activity {
  int? id;
  String title;
  String description;
  DateTime date;
  String? photoPath; // optional path to documentation photo
  bool completed;

  Activity({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.photoPath,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'photoPath': photoPath,
      'completed': completed ? 1 : 0,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as int?,
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      photoPath: map['photoPath'],
      completed: map['completed'] == 1,
    );
  }
}
