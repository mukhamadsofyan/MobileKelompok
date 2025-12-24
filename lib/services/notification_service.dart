import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:orgtrack/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';


class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  // ================= ANDROID CHANNEL =================
  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Digunakan untuk notifikasi penting',
    importance: Importance.max,
  );

  // ===================================================
  // INIT
  // ===================================================
  Future<NotificationService> init() async {
    // Permission Android 13+
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Init local notification
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings =
        InitializationSettings(android: androidInit);

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _handlePayload(payload);
        }
      },
    );

    // Create notification channel
    final androidPlugin =
        _localNotif.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);

    // ================= FOREGROUND =================
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // ================= BACKGROUND (CLICK) =================
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigate(message.data);
    });

    // ================= TERMINATED =================
    final initialMsg = await _fcm.getInitialMessage();
    if (initialMsg != null) {
      _navigate(initialMsg.data);
    }

    // Token (debug)
    final token = await _fcm.getToken();
    print('[FCM TOKEN] $token');

    return this;
  }

  // ===================================================
  // FOREGROUND HANDLER
  // ===================================================
  void _handleForeground(RemoteMessage message) {
    print('[FCM][FOREGROUND] ${message.data}');
    _showLocalNotif(message);
  }

  // ===================================================
  // SHOW LOCAL NOTIFICATION
  // ===================================================
  Future<void> _showLocalNotif(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ?? data['title'];
    final body = notification?.body ?? data['body'];

    if (title == null || body == null) return;

    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  // ===================================================
  // TEST NOTIFICATION (MANUAL)
  // ===================================================
  Future<void> showLocalTestNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(payload),
    );
  }

  // ===================================================
  // HANDLE PAYLOAD
  // ===================================================
  void _handlePayload(String payload) {
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        _navigate(data);
      }
    } catch (e) {
      print('[NOTIF PAYLOAD ERROR] $e');
    }
  }

  // ===================================================
  // NAVIGATION
  // ===================================================
  void _navigate(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'agenda':
        Get.toNamed(
          Routes.AGENDA_ORGANISASI,
          arguments: {'id': data['agenda_id']},
        );
        break;

      case 'attendance':
        Get.toNamed(
          Routes.ATTENDANCE_AGENDA,
          arguments: {'action': data['action']},
        );
        break;

      default:
        print('[NOTIF] Unknown type: $type');
    }
  }
}
