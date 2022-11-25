import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notifications = FlutterLocalNotificationsPlugin();

initLocalNotificationPlugin() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launch_background');
  DarwinInitializationSettings initializationSettingsiOS =
      DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true);
  InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsiOS,
    macOS: initializationSettingsiOS,
  );
  await notifications.initialize(initializationSettings);
}

Future<void> showNotificationWithChronometer(DateTime _starttime) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('Supero', 'Supero',
          channelDescription: 'Supero에서는 운동을 지원합니다',
          importance: Importance.max,
          priority: Priority.high,
          when: _starttime.millisecondsSinceEpoch,
          usesChronometer: true,
          ongoing: true,
          autoCancel: false);
  var iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iosDetails);
  await notifications.show(
      0, '운동이 진행 중 이에요', "알림은 운동 종료시 사라져요!", platformChannelSpecifics,
      payload: 'item x');
}

Future<void> cancelNotificationWithChronometer() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.cancel(0);
}
