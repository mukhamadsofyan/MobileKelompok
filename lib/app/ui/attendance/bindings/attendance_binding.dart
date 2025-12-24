// attendance_binding.dart
import 'package:get/get.dart';
import '../../../data/models/AgendaModel.dart';
import '../controllers/attendance_controller.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    final agenda = Get.arguments as AgendaOrganisasi?;

    // kalau arguments null, biarkan page builder yang handle "Agenda tidak valid"
    if (agenda == null) return;

    // gunakan lazyPut supaya tidak double
    Get.lazyPut<AttendanceController>(
      () => AttendanceController(agenda: agenda),
      fenix: false,
    );
  }
}
