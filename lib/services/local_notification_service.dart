import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(settings: initSettings);
  }

  static Future<void> showStrikeNotification({
    required String fishName,
    required double weightKg,
    required String spotName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'strike_channel',
      'Strike Alerts',
      channelDescription: 'Notifikasi tangkapan strike ikan berhasil',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🎣 Strike Berhasil Dicatat!',
      body: '$fishName ($weightKg kg) berhasil didaratkan di $spotName.',
      notificationDetails: notificationDetails,
    );
  }
}
