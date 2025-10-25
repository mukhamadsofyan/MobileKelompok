import 'package:get/get.dart';
import 'package:orgtrack/app/data/models/AgendaModel.dart';
import 'package:orgtrack/app/ui/agenda/bindings/agenda_binding.dart';
import 'package:orgtrack/app/ui/agenda/views/agenda_view.dart';
import 'package:orgtrack/app/ui/attendance/views/AttendanceAgendaView.dart';
import 'package:orgtrack/app/ui/notifikasi/bindings/notifikasi_binding.dart';
import 'package:orgtrack/app/ui/notifikasi/views/notifikasi_view.dart';
import 'package:orgtrack/app/ui/visimisi/bindings/visi_misi_binding.dart';
import 'package:orgtrack/app/ui/visimisi/views/visi_misi_view.dart';
import '../ui/home/views/home_view.dart';
import '../ui/attendance/views/attendance_view.dart';
import '../ui/keuangan/views/keuangan_view.dart';
import '../ui/programkerja/views/programkerja_view.dart';
import '../ui/keuangan/bindings/keuangan_binding.dart';
import '../ui/programkerja/bindings/programkerja_binding.dart';
import '../ui/org/bindings/org_binding.dart';
import '../ui/struktur/views/struktur_view.dart';
import '../ui/struktur/bindings/struktur_binding.dart';
import '../ui/laporan/views/laporan_view.dart';
import '../ui/laporan/bindings/laporan_binding.dart';
import '../ui/dokumentasi/views/dokumentasi_view.dart';
import '../ui/dokumentasi/bindings/dokumentasi_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: OrgBinding(),
    ),
    GetPage(
      name: Routes.ATTENDANCE_AGENDA,
      page: () => AttendanceAgendaView(),
    ),
    GetPage(
      name: Routes.ATTENDANCE,
      page: () {
        // Ambil agenda dari Get.arguments
        final agenda = Get.arguments as AgendaOrganisasi;
        return AttendanceView(agenda: agenda);
      },
    ),
    GetPage(
      name: Routes.KEUANGAN,
      page: () => KeuanganView(),
      binding: KeuanganBinding(),
    ),
    GetPage(
      name: Routes.PROGRAMKERJA,
      page: () => const ProgramKerjaView(),
      binding: ProgramKerjaBinding(),
    ),
    GetPage(
      name: Routes.STRUKTUR,
      page: () => StrukturKabinetView(),
      binding: StrukturBinding(),
    ),
    GetPage(
      name: Routes.LAPORAN,
      page: () => const LaporanView(),
      binding: LaporanBinding(),
    ),
    GetPage(
      name: Routes.DOKUMENTASI,
      page: () => const DokumentasiView(),
      binding: DokumentasiBinding(),
    ),
    GetPage(
      name: '/agenda_organisasi',
      page: () => const AgendaView(),
      binding: AgendaBinding(),
    ),
        GetPage(
      name: Routes.VISI_MISI,
      page: () => const VisiMisiView(),
      binding: VisiMisiBinding(),
    ),
    GetPage(
      name: Routes.NOTIFIKASI,
      page: () => const NotifikasiView(),
      binding: NotifikasiBinding(),
    ),
  ];
}
