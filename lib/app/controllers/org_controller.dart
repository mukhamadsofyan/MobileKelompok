import 'package:get/get.dart';
import 'package:orgtrack/app/data/db/db_helper.dart';
import 'package:orgtrack/app/data/models/bidang_model.dart';
import 'package:orgtrack/app/data/models/AgendaModel.dart';

class OrgController extends GetxController {
  final SupabaseDB db = SupabaseDB();

  // === FIX: Tambahkan loading agar tidak error ===
  var loading = false.obs;

  // === Data Bidang ===
  var bidangList = <BidangMo>[].obs;
  var loadingBidang = false.obs;

  // === FIX: Tambahkan agendaList agar HomeView tidak error ===
  var agendaList = <AgendaOrganisasi>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBidang();
    fetchAgenda(); // FIX: tambahkan load agenda
  }

  // ================================
  //        BIDANG
  // ================================
  Future<void> fetchBidang() async {
    loading.value = true;

    try {
      final response = await db.supabase
          .from('bidang')
          .select()
          .order('id', ascending: true);

      final list = response
          .map((e) => BidangMo.fromMap(e))
          .toList();

      bidangList.assignAll(list);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data bidang: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      loading.value = false;
    }
  }

  // ================================
  //        AGENDA ORGANISASI
  // ================================
  Future<void> fetchAgenda() async {
    try {
      final data = await db.getAgendaOrganisasi();
      agendaList.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat agenda: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
