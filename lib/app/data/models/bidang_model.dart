import 'dart:convert';

class BidangModel {
  final int id;
  final String nama;
  final String deskripsi;
  final String? logoUrl; // opsional (kalau memakai logo)

  BidangModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    this.logoUrl,
  });

  /// =============================
  /// FROM MAP (MAP → OBJECT)
  /// =============================
  factory BidangModel.fromMap(Map<String, dynamic> map) {
    return BidangModel(
      id: map['id'] is String ? int.tryParse(map['id']) ?? 0 : map['id'] ?? 0,
      nama: map['nama'] ?? map['name'] ?? '',
      deskripsi: map['deskripsi'] ?? map['description'] ?? '',
      logoUrl: map['logo'] ?? map['logoUrl'],
    );
  }

  /// FROM JSON
  factory BidangModel.fromJson(String source) =>
      BidangModel.fromMap(json.decode(source));

  /// =============================
  /// TO MAP (OBJECT → MAP)
  /// =============================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'logoUrl': logoUrl,
    };
  }

  /// TO JSON
  String toJson() => json.encode(toMap());

  /// =============================
  /// COPYWITH (UPDATE SEBAGIAN DATA)
  /// =============================
  BidangModel copyWith({
    int? id,
    String? nama,
    String? deskripsi,
    String? logoUrl,
  }) {
    return BidangModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
