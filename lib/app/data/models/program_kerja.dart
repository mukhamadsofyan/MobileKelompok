class ProgramKerja {
  int id;
  int bidangId; // bisa 0 atau null kalau ini global
  String judul;
  String deskripsi;
  DateTime tanggal; // satu tanggal untuk program

  ProgramKerja({
    required this.id,
    required this.bidangId,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
  });

  factory ProgramKerja.fromMap(Map<String, dynamic> map) {
    return ProgramKerja(
      id: map['id'],
      bidangId: map['bidangId'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      tanggal: DateTime.parse(map['tanggal']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'bidangId': bidangId,
        'judul': judul,
        'deskripsi': deskripsi,
        'tanggal': tanggal.toIso8601String(),
      };
}
