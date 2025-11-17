import 'package:get/get.dart';
import 'package:orgtrack/app/middleware/auth_middleware.dart';
import 'package:orgtrack/app/ui/agenda/bindings/agenda_binding.dart';
import 'package:orgtrack/app/ui/agenda/views/agenda_view.dart';
import 'package:orgtrack/app/ui/attendance/bindings/binding_agenda.dart';
import 'package:orgtrack/app/ui/attendance/views/AttendanceAgendaView.dart';
import 'package:orgtrack/app/ui/bidang/controllers/bidang_controller.dart';
import 'package:orgtrack/app/ui/bidang/views/bidang_view.dart';
import 'package:orgtrack/app/ui/home/welcome/welcome.dart';
import 'package:orgtrack/app/ui/notifikasi/bindings/notifikasi_binding.dart';
import 'package:orgtrack/app/ui/notifikasi/views/notifikasi_view.dart';
import 'package:orgtrack/app/ui/profile/controllers/profile_controller.dart';
import 'package:orgtrack/app/ui/profile/views/profile_view.dart';
import 'package:orgtrack/app/ui/register/views/registerview.dart';
import 'package:orgtrack/app/ui/visimisi/bindings/visi_misi_binding.dart';
import 'package:orgtrack/app/ui/visimisi/views/visi_misi_view.dart';
import 'package:orgtrack/app/ui/login/views/login_view.dart';
import '../ui/home/views/home_view.dart';
import '../ui/keuangan/views/keuangan_view.dart';
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
    // GetPage(
    //   name: Routes.ATTENDANCE_AGENDA,
    //   page: () => AttendanceAgendaView(),
    //   binding: AttendanceAgendaBinding(),
    // ),
    GetPage(
      name: Routes.ATTENDANCE_AGENDA,
      page: () => AttendanceAgendaView(),
      binding: AttendanceAgendaBinding(),
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
    // app_pages.dart
    GetPage(
      name: Routes.Bidang,
      page: () => BidangView(),
      binding: BindingsBuilder(() {
        Get.put(BidangControllerSupabase());
      }),
    ),

    // GetPage(
    //   name: '/test-supabase',
    //   page: () => const TestSupabasePage(),
    // ),

    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.KEUANGAN,
      page: () => const KeuanganView(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.STRUKTUR,
      page: () => const StrukturKabinetView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.WELCOME,
      page: () => WelcomeView(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterView(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
  ];
}
