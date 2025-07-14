import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  final bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    print("Initializing NotificationService");
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationPlugin.initialize(initializationSettings);
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'SSCDefaultChannel',
        'SSC Channel',
        channelDescription: 'SSC channel for notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    );
  }

  Future<void> showNotification(
      {int id = 0, String? title, String? body}) async {
    return notificationPlugin.show(id, title, body, notificationDetails());
  }
}
