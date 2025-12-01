import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orgtrack/app/data/models/laporanModel.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/program_kerja_mode.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/programkerja_controller.dart';
import 'package:orgtrack/app/ui/programkerja/controllers/programkerja_dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

// CONTROLLERS
import 'package:orgtrack/app/controllers/auth_controller.dart';
import 'package:orgtrack/app/ui/agenda/controllers/agenda_controller.dart';
import 'package:orgtrack/app/controllers/theme_controller.dart';

// THEME
import 'package:orgtrack/app/theme/theme.dart';

// ROUTES
import 'app/routes/app_pages.dart';


// =======================
//     MIDDLEWARE LOGIN
// =======================
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}

// =======================
//          MAIN
// =======================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load(fileName: ".env");

  // ================================
  //            INIT HIVE
  // ================================
  await Hive.initFlutter();
  Hive.registerAdapter(ReportAdapter());
  await Hive.openBox<Report>('reportsBox');

  // ================================
  //          INIT SUPABASE
  // ================================
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // ================================
  //      GLOBAL CONTROLLERS
  // ================================
  Get.put(AgendaController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  // ================================
  //   WAJIB UNTUK PROGRAM KERJA
  // ================================
  Get.put(ProgramControllerHttp(), permanent: true);
  Get.put(ProgramControllerDio(), permanent: true);
  Get.put(ModeController(), permanent: true);

  runApp(const OrgTrackApp());
}

// =======================
//      MAIN APP WIDGET
// =======================
class OrgTrackApp extends StatelessWidget {
  const OrgTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "OrgTrack",

        initialRoute: Routes.WELCOME,
        getPages: AppPages.routes,

        // THEME SYSTEM
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeC.isDark ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }
}
