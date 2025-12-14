import 'package:get/get.dart';

enum FetchMode { http, dio }

class ModeController extends GetxController {
  var mode = FetchMode.http.obs;
}
