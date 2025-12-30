class AttendanceModel {
  final int agendaId;
  final int strukturalId;
  final bool present;
  final DateTime updatedAt;

  AttendanceModel({
    required this.agendaId,
    required this.strukturalId,
    required this.present,
    required this.updatedAt,
  });

  // ================= FROM DB =================
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      agendaId: json['agenda_id'] as int,
      strukturalId: json['struktural_id'] as int,
      present: json['present'] == true || json['present'] == 1,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // ================= TO DB =================
  Map<String, dynamic> toJson() {
    return {
      'agenda_id': agendaId,
      'struktural_id': strukturalId,
      'present': present,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
