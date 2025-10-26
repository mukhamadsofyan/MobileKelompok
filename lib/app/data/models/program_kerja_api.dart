class Programker {
  final int id;
  final int bidangId;
  final String judul;
  final String deskripsi;
  final String tanggal;

  Programker({
    required this.id,
    required this.bidangId,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
  });

  factory Programker.fromMap(Map<String, dynamic> map) {
    return Programker(
      id: map['id'],
      bidangId: map['bidangId'], // pastikan key ini sesuai dari API
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      tanggal: map['tanggal'],
    );
  }
}

