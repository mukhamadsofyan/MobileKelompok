import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orgtrack/app/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:orgtrack/app/ui/agenda/controllers/agenda_controller.dart';
import 'app/routes/app_pages.dart';

// ===============
//    MIDDLEWARE
// ===============
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = Supabase.instance.client.auth.currentSession;

    // Jika belum login → arahkan ke halaman LOGIN
    if (session == null) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    return null; // lanjutkan route
  }
}

// ===============
//    MAIN APP
// ===============
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load(fileName: ".env");

  // Init Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Controller GLOBAL
  Get.put(AgendaController());
  Get.put(AuthController()); // ← AUTH aktif disini

  runApp(const KelompokApp());
}

class KelompokApp extends StatelessWidget {
  const KelompokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "OrgTrack",

      // Start selalu dari Login
      initialRoute: Routes.WELCOME,

      getPages: AppPages.routes,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
    );
  }
}
