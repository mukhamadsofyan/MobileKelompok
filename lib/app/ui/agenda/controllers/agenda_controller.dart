import 'package:get/get.dart';
import 'package:orgtrack/app/data/models/AgendaModel.dart';
import '../../../data/db/db_helper.dart';

class AgendaController extends GetxController {
  final DBHelper db = DBHelper();

  var agendas = <AgendaOrganisasi>[].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAgendas();
  }

  void fetchAgendas() async {
    loading.value = true;
    agendas.value = await db.getAgendaOrganisasi();
    loading.value = false;
  }

  void addAgenda(AgendaOrganisasi a) async {
    await db.insertAgenda(a);
    fetchAgendas();
  }

  void deleteAgenda(int id) async {
    await db.deleteAgenda(id);
    fetchAgendas();
  }

  void updateAgenda(AgendaOrganisasi a) async {
    await db.updateAgenda(a);
    fetchAgendas();
  }
}
