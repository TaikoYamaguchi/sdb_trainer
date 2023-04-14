import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

void fcmSetting() async {
  // firebase core 기능 사용을 위한 필수 initializing
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true);

  // foreground에서의 푸시 알림 표시를 위한 알림 중요도 설정
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  // foreground에서의 푸시 알림 표시를 위한 local notifications 설정
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification)));

  // foreground 푸시 알림 핸들링
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ));
    }
  });

  // 사용자가 푸시 알림을 허용했는지 확인 (optional)
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final isNotificationEnabled = await prefs.getBool('commentNotification');
  if (isNotificationEnabled == false) {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: false, badge: false, sound: false);
  }

  final isFCMEnabled = await prefs.getBool('FCM_ENABLED');
  print("this is token");
  print("fcm enabled: $isFCMEnabled");
  if (isFCMEnabled == null || isFCMEnabled) {
    // firebase token 발급
    String? firebaseToken = await FirebaseMessaging.instance.getToken();
    final storage = new FlutterSecureStorage();
    print("firebaseToken: $firebaseToken");

    if (firebaseToken != null) {
      try {
        String? stored_fcm_token = await storage.read(key: "sdb_fcm_token");
        print("stored_fcm_token: $stored_fcm_token");
        if (stored_fcm_token == firebaseToken) {
          print("fcm_token 일치");
          null;
          UserFCMTokenEdit(fcmToken: firebaseToken).patchUserFCMToken();
          await storage.write(key: "sdb_fcm_token", value: firebaseToken);
        } else {
          UserFCMTokenEdit(fcmToken: firebaseToken).patchUserFCMToken();
          await storage.write(key: "sdb_fcm_token", value: firebaseToken);
        }
      } catch (e) {
        UserFCMTokenEdit(fcmToken: firebaseToken).patchUserFCMToken();
        await storage.write(key: "sdb_fcm_token", value: firebaseToken);
      }

      // 서버로 firebase token 갱신
    }
  }
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {}
