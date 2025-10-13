class Member {
  int? id;
  String name;
  String role;
  bool active;

  Member({
    this.id,
    required this.name,
    this.role = 'Member',
    this.active = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'role': role,
        'active': active ? 1 : 0,
      };

  factory Member.fromMap(Map<String, dynamic> map) => Member(
        id: map['id'] as int?,
        name: map['name'],
        role: map['role'],
        active: map['active'] == 1,
      );
}
