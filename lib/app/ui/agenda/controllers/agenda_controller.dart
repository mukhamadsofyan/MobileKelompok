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
      agendas.value = await db.getAgendaOrganisasi();
    } catch (e) {
      print("Error fetching agendas: $e");
    }
    loading.value = false;
  }

  // Alias untuk tombol "Muat Ulang"
  Future<void> loadAgenda() async {
    return fetchAgendas();
  }

  // ===============================
  // Tambah agenda baru
  // ===============================
  Future<void> addAgenda(AgendaOrganisasi a) async {
    await db.insertAgenda(a);
    fetchAgendas();
  }

  // ===============================
  // Hapus agenda
  // ===============================
  Future<void> deleteAgenda(int id) async {
    await db.deleteAgenda(id);
    fetchAgendas();
  }

  // ===============================
  // Update agenda
  // ===============================
  Future<void> updateAgenda(AgendaOrganisasi a) async {
    await db.updateAgenda(a);
    fetchAgendas();
  }
}
