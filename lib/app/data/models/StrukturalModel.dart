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

  // INSERT — tanpa ID
  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'role': role,
    };
  }

  // UPDATE — tanpa ID
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'role': role,
    };
  }
}
