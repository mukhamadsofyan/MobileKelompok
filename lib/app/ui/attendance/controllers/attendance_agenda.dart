import 'package:get/get.dart';
import '../../../data/db/db_helper.dart';
import '../../../data/models/AgendaModel.dart';

class AttendanceAgendaController extends GetxController {
  final db = DBHelper();
  var agendaList = <AgendaOrganisasi>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAgenda();
  }

  Future<void> loadAgenda() async {
    final list = await db.getAgendaOrganisasi();
    agendaList.assignAll(list);
  }
}
