class BidangModel {
  final int id;
  final String nama;

  BidangModel({
    required this.id,
    required this.nama,
  });

  // ✅ Dipakai kalau kamu panggil BidangModel.fromJson(...)
  factory BidangModel.fromJson(Map<String, dynamic> json) {
    return BidangModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      nama: json['nama'] ?? '',
    );
  }

  // ✅ Dipakai kalau kamu panggil BidangModel.fromMap(...)
  //    Biar nggak bingung, kita delegasikan saja ke fromJson
  factory BidangModel.fromMap(Map<String, dynamic> map) {
    return BidangModel.fromJson(map);
  }

  // (opsional) kalau perlu kirim balik ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}
