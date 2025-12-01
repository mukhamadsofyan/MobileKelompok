import 'package:orgtrack/app/data/models/bidang_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/AgendaModel.dart';
import '../models/KeuanganModel.dart';
import '../models/StrukturalModel.dart';
import '../models/program_kerja.dart';
import '../models/activity.dart';

class SupabaseDB {
  final supabase = Supabase.instance.client;

  // ================= CRUD ACTIVITIES =================
  Future<List<Activity>> getActivities() async {
    final data = await supabase
        .from('activities')
        .select()
        .order('id', ascending: false);

    return data.map<Activity>((e) => Activity.fromMap(e)).toList();
  }

  Future<dynamic> insertActivity(Activity a) async {
    return await supabase.from('activities').insert(a.toMap());
  }

  Future<dynamic> updateActivity(Activity a) async {
    if (a.id == null) throw Exception("ID Activity tidak boleh null");
    return await supabase.from('activities').update(a.toMap()).eq('id', a.id!);
  }

  Future<dynamic> deleteActivity(int id) async {
    return await supabase.from('activities').delete().eq('id', id);
  }

  // ================= CRUD PROGRAM KERJA =================
  Future<List<ProgramKerja>> getProgramKerja({int? bidangId}) async {
    List<dynamic> raw;

    if (bidangId != null) {
      raw = await supabase
          .from('program_kerja')
          .select()
          .eq('bidangId', bidangId)
          .order('tanggal', ascending: false);
    } else {
      raw = await supabase
          .from('program_kerja')
          .select()
          .order('tanggal', ascending: false);
    }

    return raw.map<ProgramKerja>((e) => ProgramKerja.fromMap(e)).toList();
  }

  Future<dynamic> insertProgramKerja(ProgramKerja p) async {
    return await supabase.from('program_kerja').insert(p.toMap());
  }

  Future<dynamic> updateProgramKerja(ProgramKerja p) async {
    if (p.id == null) throw Exception("ID Program Kerja null");
    return await supabase
        .from('program_kerja')
        .update(p.toMap())
        .eq('id', p.id!);
  }

  Future<dynamic> deleteProgramKerja(int id) async {
    return await supabase.from('program_kerja').delete().eq('id', id);
  }

  // ================= CRUD KEUANGAN =================
  Future<List<Keuanganmodel>> getKeuangan() async {
    final data = await supabase
        .from('keuangan')
        .select()
        .order('date', ascending: false);

    return data.map<Keuanganmodel>((e) => Keuanganmodel.fromMap(e)).toList();
  }

  Future<dynamic> insertKeuangan(Keuanganmodel k) async {
    return await supabase.from('keuangan').insert(k.toMap());
  }

  Future<dynamic> updateKeuangan(Keuanganmodel k) async {
    if (k.id == null) throw Exception("ID Keuangan null");
    return await supabase.from('keuangan').update(k.toMap()).eq('id', k.id!);
  }

  Future<dynamic> deleteKeuangan(int id) async {
    return await supabase.from('keuangan').delete().eq('id', id);
  }

  // ================= CRUD STRUKTURAL =================
  Future<List<Struktural>> getStruktural() async {
    final data = await supabase
        .from('struktural')
        .select()
        .order('id', ascending: false);

    return data.map<Struktural>((e) => Struktural.fromMap(e)).toList();
  }

  Future<dynamic> insertStruktural(Struktural s) async {
    return await supabase.from('struktural').insert(s.toInsertMap());
  }

  Future<dynamic> updateStruktural(Struktural s) async {
    if (s.id == null) throw Exception("ID Struktural null");

    return await supabase
        .from('struktural')
        .update(s.toUpdateMap()) // ← tanpa ID
        .eq('id', s.id!);
  }

  Future<dynamic> deleteStruktural(int id) async {
    return await supabase.from('struktural').delete().eq('id', id);
  }

  Future<Struktural> getStrukturalById(int id) async {
    final data =
        await supabase.from('struktural').select().eq('id', id).single();

    return Struktural.fromMap(data);
  }

  // ================= CRUD BIDANG =================
  Future<List<BidangModel>> getBidang() async {
    final data =
        await supabase.from('bidang').select().order('nama', ascending: true);

    return data.map<BidangModel>((e) => BidangModel.fromMap(e)).toList();
  }

  Future<dynamic> insertBidang(BidangModel b) async {
    return await supabase.from('bidang').insert(b.toMap());
  }

  Future<dynamic> updateBidang(BidangModel b) async {
    if (b.id == null) throw Exception("ID Bidang null");

    return await supabase.from('bidang').update(b.toMap()).eq('id', b.id!);
  }

  Future<dynamic> deleteBidang(int id) async {
    return await supabase.from('bidang').delete().eq('id', id);
  }

  // ================= CRUD AGENDA ORGANISASI =================
  Future<List<AgendaOrganisasi>> getAgendaOrganisasi() async {
    final raw = await supabase
        .from('agenda_organisasi')
        .select()
        .order('date', ascending: false);

    return raw
        .map<AgendaOrganisasi>((e) => AgendaOrganisasi.fromMap(e))
        .toList();
  }

  Future<dynamic> insertAgenda(AgendaOrganisasi a) async {
    return await supabase.from('agenda_organisasi').insert(a.toInsertMap());
  }

  Future<dynamic> updateAgenda(AgendaOrganisasi a) async {
    if (a.id == null) throw Exception("ID Agenda null");

    return await supabase
        .from('agenda_organisasi')
        .update(a.toUpdateMap())
        .eq('id', a.id!);
  }

  Future<dynamic> deleteAgenda(int id) async {
    // Hapus attendance dulu
    await deleteAttendanceByAgenda(id);

    // Baru hapus agenda
    return await supabase.from('agenda_organisasi').delete().eq('id', id);
  }

  // ================= CRUD ATTENDANCE =================
  Future<List<Map<String, dynamic>>> getAttendanceByAgenda(int agendaId) async {
    return await supabase.from('attendance').select().eq('agenda_id', agendaId);
  }

  Future<dynamic> markAttendance(
      int agendaId, int strukturalId, bool present) async {
    final existing = await supabase
        .from('attendance')
        .select()
        .eq('agenda_id', agendaId)
        .eq('struktural_id', strukturalId);

    if (existing.isNotEmpty) {
      return await supabase
          .from('attendance')
          .update({'present': present ? 1 : 0})
          .eq('agenda_id', agendaId)
          .eq('struktural_id', strukturalId);
    }

    return await supabase.from('attendance').insert({
      'agenda_id': agendaId,
      'struktural_id': strukturalId,
      'present': present ? 1 : 0,
    });
  }

  Future<dynamic> deleteAttendanceByAgenda(int agendaId) async {
    return await supabase.from('attendance').delete().eq('agenda_id', agendaId);
  }
}
