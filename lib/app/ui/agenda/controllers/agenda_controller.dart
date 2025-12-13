import 'package:get/get.dart';
import 'package:orgtrack/app/data/db/db_helper.dart';
import 'package:orgtrack/app/data/models/AgendaModel.dart';

class AgendaController extends GetxController {
  final SupabaseDB db = SupabaseDB();

  var agendas = <AgendaOrganisasi>[].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAgendas();
  }

  // ===============================
  // Ambil daftar agenda dari Supabase
  // ===============================
  Future<void> fetchAgendas() async {
    loading.value = true;

    try {
      final data = await db.getAgendaOrganisasi();
      agendas.assignAll(data);                  // 👍 lebih aman daripada value =
    } catch (e, stack) {
      print("🔥 Error fetching agendas: $e");
      print(stack);                             // 👍 biar tau error asli
    } finally {
      loading.value = false;                    // 👍 tetap matikan loading
    }
  }

  // Alias tombol refresh
  Future<void> loadAgenda() async => fetchAgendas();

  // ===============================
  // Tambah agenda
  // ===============================
  Future<void> addAgenda(AgendaOrganisasi a) async {
    try {
      await db.insertAgenda(a);
      await fetchAgendas();                     // 👍 pastikan data refresh
    } catch (e) {
      print("🔥 Error addAgenda: $e");
    }
  }

  // ===============================
  // Hapus agenda
  // ===============================
  Future<void> deleteAgenda(int id) async {
    try {
      await db.deleteAgenda(id);
      await fetchAgendas();
    } catch (e) {
      print("🔥 Error deleteAgenda: $e");
    }
  }

  // ===============================
  // Update agenda
  // ===============================
  Future<void> updateAgenda(AgendaOrganisasi a) async {
    try {
      await db.updateAgenda(a);
      await fetchAgendas();
    } catch (e) {
      print("🔥 Error updateAgenda: $e");
    }
  }
}
