class ProgramKerja {
  final int? id;
  final String nama;
  final String deskripsi;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;

  ProgramKerja({
    this.id,
    required this.nama,
    required this.deskripsi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
  });

  factory ProgramKerja.fromMap(Map<String, dynamic> map) {
    return ProgramKerja(
      id: map['id'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      tanggalMulai: DateTime.parse(map['tanggalMulai']),
      tanggalSelesai: DateTime.parse(map['tanggalSelesai']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nama': nama,
        'deskripsi': deskripsi,
        'tanggalMulai': tanggalMulai.toIso8601String(),
        'tanggalSelesai': tanggalSelesai.toIso8601String(),
      };
}
