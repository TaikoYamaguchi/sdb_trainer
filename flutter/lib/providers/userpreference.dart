import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PrefsProvider extends ChangeNotifier {
  bool? _commentNotification = true;
  bool? _systemNotification = true;
  bool? get commentNotification => _commentNotification;
  bool? get systemNotification => _systemNotification;
  String? _nowonplan = "";
  String? get nowonplan => _nowonplan;

  var _prefs;
  SharedPreferences get prefs => _prefs;

  getprefs() async {
    _prefs = await SharedPreferences.getInstance();

    _prefs.getString('lastroutine') == null
        ? await _prefs.setString('lastroutine', '')
        : null;

    _prefs.getBool('userest') == null
        ? await _prefs.setBool('userest', false)
        : null;
    _prefs.getString('nowonplan') == null
        ? [
            await _prefs.setString('nowonplan', ''),
            _nowonplan = _prefs.getString('nowonplan')
          ]
        : _nowonplan = _prefs.getString('nowonplan');

    notifyListeners();
  }

  getAlarmPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.getBool('commentNotification') == null
        ? [
            await _prefs.setBool('commentNotification', true),
            _commentNotification = _prefs.getBool('commentNotification'),
          ]
        : [
            _commentNotification = _prefs.getBool('commentNotification'),
          ];
    if (_commentNotification!) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
    } else {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: false, badge: false, sound: false);
    }
    notifyListeners();
  }

  setAlarmPrefs(value) async {
    await _prefs.setBool('commentNotification', value);
    _commentNotification = _prefs.getBool('commentNotification');
    if (_commentNotification!) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
    } else {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: false, badge: false, sound: false);
    }
    notifyListeners();
  }

  getSystemNotification() async {
    PermissionStatus status = await Permission.notification.request();
    // 결과 확인
    if (!status.isGranted) {
      _systemNotification = false;
      _commentNotification = false;
      await _prefs.setBool('commentNotification', false);
      if (_commentNotification!) {
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
      } else {
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
            alert: false, badge: false, sound: false);
      }
      // 허용이 안된 경우
    }
  }



  lastplan(value) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('lastroutine', value);
    notifyListeners();
  }

  setplan(name) async {
    await _prefs.setString('nowonplan', name);
    _nowonplan = _prefs.getString('nowonplan');

    notifyListeners();
  }
}
