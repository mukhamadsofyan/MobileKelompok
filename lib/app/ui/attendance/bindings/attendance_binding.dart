import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../../../data/models/AgendaModel.dart';

class AttendanceBinding extends Bindings {
  final AgendaOrganisasi agenda;
  AttendanceBinding({required this.agenda});

  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceController(agenda: agenda));
  }
}
