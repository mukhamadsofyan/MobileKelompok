import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:orgtrack/app/middleware/auth_middleware.dart';
import 'package:orgtrack/app/ui/about/view/about_app_view.dart';
import 'package:orgtrack/app/ui/agenda/bindings/agenda_binding.dart';
import 'package:orgtrack/app/ui/agenda/views/agenda_view.dart';
import 'package:orgtrack/app/ui/attendance/bindings/binding_agenda.dart';
import 'package:orgtrack/app/ui/attendance/views/AttendanceAgendaView.dart';
import 'package:orgtrack/app/ui/attendance/views/attendance_view.dart';
import 'package:orgtrack/app/ui/benefit/view/benefitview.dart';
import 'package:orgtrack/app/ui/bidang/views/bidang_view.dart';
import 'package:orgtrack/app/ui/contact/view/contactview.dart';
import 'package:orgtrack/app/ui/home/welcome/welcome.dart';
import 'package:orgtrack/app/ui/notifikasi/bindings/notifikasi_binding.dart';
import 'package:orgtrack/app/ui/notifikasi/views/notifikasi_view.dart';
import 'package:orgtrack/app/ui/profile/controllers/profile_controller.dart';
import 'package:orgtrack/app/ui/profile/views/profile_view.dart';
import 'package:orgtrack/app/ui/programkerja/bindings/programkerja_binding.dart';
import 'package:orgtrack/app/ui/programkerja/views/programkerja_view.dart';
import 'package:orgtrack/app/ui/register/views/registerview.dart';
import 'package:orgtrack/app/ui/visimisi/bindings/visi_misi_binding.dart';
import 'package:orgtrack/app/ui/visimisi/views/visi_misi_view.dart';
import 'package:orgtrack/app/ui/login/views/login_view.dart';
import 'package:orgtrack/modules/lokasi/controllers/lokasi_sekretariat_controller.dart';
import 'package:orgtrack/modules/lokasi/views/lokasi_sekretariat_view.dart';
import '../ui/home/views/home_view.dart';
import '../ui/keuangan/views/keuangan_view.dart';
import '../ui/struktur/views/struktur_view.dart';
import '../ui/struktur/bindings/struktur_binding.dart';
import '../ui/laporan/views/laporan_view.dart';
import '../ui/laporan/bindings/laporan_binding.dart';
import '../ui/dokumentasi/views/dokumentasi_view.dart';
import '../ui/dokumentasi/bindings/dokumentasi_binding.dart';
import '../data/models/AgendaModel.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    // ================= ATTENDANCE AGENDA =================
    GetPage(
      name: Routes.ATTENDANCE_AGENDA,
      page: () => AttendanceAgendaView(),
      binding: AttendanceAgendaBinding(),
    ),

    // ================= ATTENDANCE (INI YANG FIX ERROR) =================
    GetPage(
      name: Routes.ATTENDANCE,
      page: () {
        final agenda = Get.arguments as AgendaOrganisasi?;
        if (agenda == null) {
          return const Scaffold(
            body: Center(child: Text("Agenda tidak valid")),
          );
        }
        return AttendanceView(agenda: agenda);
      },
    ),
    GetPage(
      name: Routes.LOKASI_SEKRETARIAT,
      page: () => const LokasiSekretariatView(),
      binding: BindingsBuilder(() {
        Get.put(LokasiSekretariatController());
      }),
    ),
    GetPage(name: Routes.BENEFIT_HMIF, page: () => const BenefitHMIFView()),

    // ================= ABOUT APP =================
    GetPage(name: Routes.ABOUT, page: () => const AboutAppView()),
    GetPage(
      name: Routes.CONTACT, // ⬅️ ROUTE KONTAK
      page: () => const ContactView(),
    ),
    // ================= LAPORAN =================
    GetPage(
      name: Routes.LAPORAN,
      page: () => const LaporanView(),
      binding: LaporanBinding(),
    ),

    // ================= DOKUMENTASI =================
    GetPage(
      name: Routes.DOKUMENTASI,
      page: () => const DokumentasiView(),
      binding: DokumentasiBinding(),
    ),

    // ================= PROGRAM KERJA =================
    GetPage(
      name: Routes.PROGRAMKERJA,
      page: () {
        final id = int.parse(Get.parameters['id']!);
        final name = Get.parameters['name']!;
        return ProgramKerjaView(bidangId: id, bidangName: name);
      },
      binding: ProgramKerjaBinding(),
    ),

    // ================= AGENDA ORGANISASI =================
    GetPage(
      name: '/agenda_organisasi',
      page: () => const AgendaView(),
      binding: AgendaBinding(),
    ),

    // ================= VISI MISI =================
    GetPage(
      name: Routes.VISI_MISI,
      page: () => const VisiMisiView(),
      binding: VisiMisiBinding(),
    ),

    // ================= NOTIFIKASI =================
    GetPage(
      name: Routes.NOTIFIKASI,
      page: () => NotifikasiView(),
      bindings: [NotifikasiBinding(), AgendaBinding()],
    ),

    // ================= BIDANG =================
    GetPage(name: Routes.BIDANG, page: () => const BidangView()),

    // ================= HOME =================
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      middlewares: [AuthMiddleware()],
    ),

    // ================= KEUANGAN =================
    GetPage(
      name: Routes.KEUANGAN,
      page: () => const KeuanganView(),
      middlewares: [AuthMiddleware()],
    ),

    // ================= STRUKTUR =================
    GetPage(
      name: Routes.STRUKTUR,
      page: () => const StrukturKabinetView(),
      middlewares: [AuthMiddleware()],
    ),

    // ================= AUTH =================
    GetPage(name: Routes.WELCOME, page: () => WelcomeView()),
    GetPage(name: Routes.LOGIN, page: () => LoginView()),
    GetPage(name: Routes.REGISTER, page: () => RegisterView()),

    // ================= PROFILE =================
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
  ];
}
