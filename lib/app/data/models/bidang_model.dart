/////punya api modul 3/////
class BidangMo {
  final int id;
  final String nama;

  BidangMo({required this.id, required this.nama});

  factory BidangMo.fromMap(Map<String, dynamic> map) {
    return BidangMo(
      id: map['id'],
      nama: map['nama'],
    );
  }
}
