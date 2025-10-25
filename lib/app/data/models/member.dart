
class Member {
  int? id;
  String name;
  String role;

  Member({this.id, required this.name, required this.role});

  factory Member.fromMap(Map<String, dynamic> m) => Member(
        id: m['id'] as int?,
        name: m['name'] as String,
        role: m['role'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'role': role,
      };
}
