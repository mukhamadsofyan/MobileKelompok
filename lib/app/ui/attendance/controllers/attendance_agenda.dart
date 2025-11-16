import 'package:get/get.dart';
import 'package:orgtrack/app/data/db/db_helper.dart';
import 'package:orgtrack/app/data/models/AgendaModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceAgendaController extends GetxController {
  final SupabaseDB db = SupabaseDB();

  var agendaList = <AgendaOrganisasi>[].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAgenda();
  }

Future<void> loadAgenda() async {
  loading.value = true;
  try {
    print("🔍 Mengambil agenda dari Supabase...");

    final raw = await Supabase.instance.client
        .from('agenda_organisasi')
        .select()
        .order('date', ascending: false);

    print("📦 RAW DATA SUPABASE:");
    print(raw);  // <--- INI RAW JSON YANG KITA BUTUH

    final list = raw
        .map<AgendaOrganisasi>((e) => AgendaOrganisasi.fromMap(e))
        .toList();

    print("📌 JUMLAH AGENDA PARSE: ${list.length}");

    agendaList.assignAll(list);
  } catch (e) {
    print("❌ ERROR PARSING: $e");
  } finally {
    loading.value = false;
  }
}

}
