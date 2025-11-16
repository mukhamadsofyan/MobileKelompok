class ProgramKerja {
  int? id;
  int bidangId;
  String judul;
  String deskripsi;
  DateTime tanggal;

  ProgramKerja({
    this.id,
    required this.bidangId,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
  });

  factory ProgramKerja.fromMap(Map<String, dynamic> map) {
    return ProgramKerja(
      id: map['id'],
      bidangId: map['bidangId'] ?? 0,
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      tanggal: DateTime.tryParse(map['tanggal'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'bidangId': bidangId,
        'judul': judul,
        'deskripsi': deskripsi,
        'tanggal': tanggal.toIso8601String(),
      };
}
