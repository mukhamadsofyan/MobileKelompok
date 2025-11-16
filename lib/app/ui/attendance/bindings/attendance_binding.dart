import 'package:get/get.dart';
import 'package:orgtrack/app/ui/attendance/controllers/attendance_agenda.dart';

class AttendanceAgendaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceAgendaController>(() => AttendanceAgendaController());
  }
}
