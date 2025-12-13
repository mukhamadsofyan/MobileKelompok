import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/routes/app_pages.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Digunakan untuk notifikasi penting',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notif_sound'),
  );

  Future<NotificationService> init() async {
    // Permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Init local notif
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings =
        InitializationSettings(android: androidInit);

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          _handlePayload(response.payload!);
        }
      },
    );

    // Create channel
    final androidPlugin =
        _localNotif.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);

    // FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCM][FOREGROUND] ${message.data}');
      _showLocalNotif(message);
    });

    // BACKGROUND (klik notif)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('[FCM][OPENED] ${message.data}');
      _navigate(message.data);
    });

    // TERMINATED
    final initialMsg = await _fcm.getInitialMessage();
    if (initialMsg != null) {
      print('[FCM][TERMINATED] ${initialMsg.data}');
      _navigate(initialMsg.data);
    }

    final token = await _fcm.getToken();
    print('[FCM TOKEN] $token');

    return this;
  }

  void _showLocalNotif(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          sound: _channel.sound,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handlePayload(String payload) {
    final data = jsonDecode(payload);
    _navigate(data);
  }

  void _navigate(Map<String, dynamic> data) {
    final type = data['type'];

    if (type == 'agenda') {
      Get.toNamed(Routes.AGENDA_ORGANISASI,
          arguments: {'id': data['agenda_id']});
    } else {
      // Get.toNamed(Routes.NOTIFICATION_LIST);
    }
  }
}
