import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';

// ================= SERVICES =================
import 'package:orgtrack/services/notification_service.dart';

// ================= CONTROLLERS =================
import 'app/controllers/auth_controller.dart';
import 'app/controllers/theme_controller.dart';
import 'app/ui/agenda/controllers/agenda_controller.dart';
import 'app/ui/programkerja/controllers/programkerja_controller.dart';

// ================= DATA =================
import 'app/data/models/laporanModel.dart';

// ================= THEME & ROUTES =================
import 'app/theme/theme.dart';
import 'app/routes/app_pages.dart';

/// =======================================================
/// BACKGROUND FCM HANDLER (WAJIB TOP LEVEL)
/// =======================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('[FCM][BACKGROUND] ${message.data}');
}

/// =======================================================
/// ROUTE OBSERVER (SIMPAN ROUTE TERAKHIR)
/// =======================================================
class AppRouteObserver extends GetObserver {
  final box = GetStorage();

  @override
  void didPush(Route route, Route? previousRoute) {
    _saveRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _saveRoute(newRoute);
  }

  void _saveRoute(Route? route) {
    final name = route?.settings.name;

    if (name == null) return;

    // ⛔ Jangan simpan halaman auth
    if (name == Routes.WELCOME || name == Routes.LOGIN) return;

    box.write('last_route', name);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================= GET STORAGE =================
  await GetStorage.init();

  // ================= FIREBASE =================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // ================= NOTIFICATION =================
  await Get.putAsync<NotificationService>(
    () async => await NotificationService().init(),
    permanent: true,
  );

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
  Get.put(AuthController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(AgendaController(), permanent: true);
  Get.put(ProgramControllerHttp(), permanent: true);

  runApp(const OrgTrackApp());
}

/// =======================================================
/// APP ROOT
/// =======================================================
class OrgTrackApp extends StatelessWidget {
  const OrgTrackApp({super.key});

  String _getInitialRoute() {
    final auth = Get.find<AuthController>();
    final box = GetStorage();

    // ❌ Belum login → selalu ke welcome
    if (!auth.isLoggedIn) {
      box.remove('last_route');
      return Routes.WELCOME;
    }

    // ✅ Login → kembali ke halaman terakhir
    final lastRoute = box.read<String>('last_route');
    return lastRoute ?? Routes.HOME;
  }

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OrgTrack',
        initialRoute: _getInitialRoute(),
        getPages: AppPages.routes,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeC.isDark ? ThemeMode.dark : ThemeMode.light,
        navigatorObservers: [
          AppRouteObserver(), // ⭐ KUNCI RESTORE ROUTE
        ],
      ),
    );
  }
}
