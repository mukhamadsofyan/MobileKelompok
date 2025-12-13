import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:orgtrack/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

// CONTROLLERS
import 'app/controllers/auth_controller.dart';
import 'app/ui/agenda/controllers/agenda_controller.dart';
import 'app/controllers/theme_controller.dart';
import 'app/ui/programkerja/controllers/programkerja_controller.dart';

// DATA
import 'app/data/models/laporanModel.dart';

// THEME
import 'app/theme/theme.dart';

// ROUTES
import 'app/routes/app_pages.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('[FCM][BACKGROUND] ${message.data}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================= FIREBASE =================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler);

  // ================= NOTIFICATION SERVICE =================
  await Get.putAsync(() => NotificationService().init());

  // ================= ENV =================
  await dotenv.load(fileName: ".env");

  // ================= HIVE =================
  await Hive.initFlutter();
  Hive.registerAdapter(ReportAdapter());
  await Hive.openBox<Report>('reportsBox');

  // ================= SUPABASE =================
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // ================= CONTROLLERS =================
  Get.put(AgendaController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(ProgramKerjaSupabaseController(), permanent: true);

  runApp(const OrgTrackApp());
}

// ================= APP =================
class OrgTrackApp extends StatelessWidget {
  const OrgTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OrgTrack',
        initialRoute: Routes.WELCOME,
        getPages: AppPages.routes,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeC.isDark ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }
}
