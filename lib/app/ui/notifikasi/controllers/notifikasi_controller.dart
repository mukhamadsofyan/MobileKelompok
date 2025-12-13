import 'package:get/get.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime time;
  final Map<String, dynamic> payload;

  AppNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.payload,
  });
}

class NotificationController extends GetxController {
  final notifications = <AppNotification>[].obs;

  void addNotification(AppNotification notif) {
    notifications.insert(0, notif);
  }
}
