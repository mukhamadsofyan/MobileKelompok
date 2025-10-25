class Struktural {
  int? id;
  String name;
  String role;

  Struktural({this.id, required this.name, required this.role});

  factory Struktural.fromMap(Map<String, dynamic> map) {
    return Struktural(
      id: map['id'],
      name: map['name'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }
}
