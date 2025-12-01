import 'package:get/get.dart';
import 'package:orgtrack/app/ui/agenda/services/agenda_service.dart';
import 'package:orgtrack/app/data/models/AgendaModel.dart';

class AgendaController extends GetxController {
  final AgendaService _service = AgendaService();

  var loading = false.obs;
  var agendas = <AgendaOrganisasi>[].obs;
  var notifications = <AgendaOrganisasi>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAgendas();
  }

  Future<void> loadAgendas() async {
    loading.value = true;
    try {
      final list = await _service.getAll();

      agendas.value = List.from(list)..sort((a, b) => a.date.compareTo(b.date));
      notifications.value = List.from(list)
        ..sort((a, b) => b.date.compareTo(a.date));
    } finally {
      loading.value = false;
    }
  }

  // CREATE
  Future<void> addAgenda(AgendaOrganisasi agenda) async {
    loading.value = true;
    try {
      final newItem = await _service.create(agenda);

      agendas.add(newItem);
      agendas.sort((a, b) => a.date.compareTo(b.date));
      agendas.refresh();

      notifications.insert(0, newItem);
      notifications.refresh();
    } finally {
      loading.value = false;
    }
  }

  // UPDATE
  Future<void> updateAgenda(AgendaOrganisasi agenda) async {
    loading.value = true;
    try {
      await _service.update(agenda);

      // Update agendas
      final i = agendas.indexWhere((e) => e.id == agenda.id);
      if (i != -1) agendas[i] = agenda;
      agendas.sort((a, b) => a.date.compareTo(b.date));
      agendas.refresh();

      // Update notifications
      final j = notifications.indexWhere((e) => e.id == agenda.id);
      if (j != -1) notifications[j] = agenda;
      notifications.sort((a, b) => b.date.compareTo(a.date));
      notifications.refresh();
    } finally {
      loading.value = false;
    }
  }

  // DELETE
  Future<void> deleteAgenda(int id) async {
    loading.value = true;
    try {
      await _service.delete(id);

      agendas.removeWhere((e) => e.id == id);
      agendas.refresh();

      notifications.removeWhere((e) => e.id == id);
      notifications.refresh();
    } finally {
      loading.value = false;
    }
  }

  // MARK AS READ (notifikasi)
  Future<void> markAsRead(AgendaOrganisasi agenda) async {
    if (agenda.id == null) return;

    await _service.markRead(agenda.id!, true);

    // Update local agendas
    final i = agendas.indexWhere((e) => e.id == agenda.id);
    if (i != -1) agendas[i].isread = true;

    // Update notifikasi
    final j = notifications.indexWhere((e) => e.id == agenda.id);
    if (j != -1) notifications[j].isread = true;

    agendas.refresh();
    notifications.refresh();
  }

  // ================= NOTIFICATION DELETE =================
  /// Hapus notifikasi dari list (TIDAK menghapus agenda dari database)
  void deleteNotification(AgendaOrganisasi agenda) {
    notifications.removeWhere((n) => n.id == agenda.id);
    notifications.refresh();
  }
}
