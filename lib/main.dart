import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/ui/agenda/controllers/agenda_controller.dart';
import 'app/routes/app_pages.dart';

void main() {
  Get.put(AgendaController());
  runApp(const KelompokApp());
}

class KelompokApp extends StatelessWidget {
  const KelompokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OrgTrack',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
    );
  }
}
