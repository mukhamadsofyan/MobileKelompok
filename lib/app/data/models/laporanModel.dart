import 'package:hive/hive.dart';

// Penting: pastikan typeId unik di project kamu
class Report {
  final String judul;
  final String tanggal;

  Report({
    required this.judul,
    required this.tanggal,
  });
}

// Adapter manual tanpa build_runner
class ReportAdapter extends TypeAdapter<Report> {
  @override
  final int typeId = 0;

  @override
  Report read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Report(
      judul: fields[0] as String,
      tanggal: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(2) // jumlah field
      ..writeByte(0)
      ..write(obj.judul)
      ..writeByte(1)
      ..write(obj.tanggal);
  }
}
