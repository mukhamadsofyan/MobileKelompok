import 'package:get/get.dart';
import '../data/db/db_helper.dart';
import '../data/models/activity.dart';
import '../data/models/AgendaModel.dart';

class OrgController extends GetxController {
  final DBHelper _db = DBHelper();

  var activities = <Activity>[].obs;
  var agendaList = <AgendaOrganisasi>[].obs; // daftar agenda
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();       // load activities
    loadAgenda();    // load agenda
  }

  // Load semua activities
  Future<void> loadAll() async {
    loading.value = true;
    try {
      activities.assignAll(await _db.getActivities());
    } finally {
      loading.value = false;
    }
  }

  // Load semua agenda
  Future<void> loadAgenda() async {
    loading.value = true; // optional: pisahkan loadingAgenda
    try {
      final list = await _db.getAgendaOrganisasi();
      agendaList.assignAll(list);
    } finally {
      loading.value = false;
    }
  }

  // Tambah activity
  Future<void> addActivity(Activity a) async {
    await _db.insertActivity(a);
    await loadAll();
  }

  // Mark attendance → gunakan agendaId, bukan activityId
  Future<void> markAttendance(int agendaId, int strukturalId, bool present) async {
    await _db.markAttendance(agendaId, strukturalId, present);
  }
}
