import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RoutineTimeProvider extends ChangeNotifier {
  int _routineTime = 0;
  int _timetosubstract = 0;
  int get routineTime => _routineTime;
  int _changetime = 0;
  int get changetime => _changetime;
  int _timeron = 0;
  int get timeron => _timeron;
  int _nowonrindex = 0;
  int get nowonrindex => _nowonrindex;
  int _nowoneindex = 0;
  int get nowoneindex => _nowoneindex;

  Timer? timer1;
  bool _isstarted = false;
  bool get isstarted => _isstarted;
  bool _userest = false;
  bool get userest => _userest;
  String restbutton = 'Rest Timer off';
  Color _restbuttoncolor = Color(0xFF717171);
  Color get restbuttoncolor => _restbuttoncolor;
  String _routineButton = '운동 시작 하기';
  String get routineButton => _routineButton;
  Color _buttoncolor = const Color(0xff7a28cb);
  Color get buttoncolor => _buttoncolor;
  DateTime _starttime = DateTime(2022, 08, 06, 10, 30);
  DateTime _timerstarttime = DateTime(2022, 08, 06, 10, 30);
  var _workoutdataProvider;

  var _prefs;

  nowoneindexupdate(value) {
    _nowoneindex = value;
  }

  getinfo() {
    notifyListeners();
  }

  restcheck() {
    _userest
        ? [
            _userest = !_userest,
            restbutton = 'Rest Timer off',
            _restbuttoncolor = Color(0xFF717171)
          ]
        : [
            _userest = !_userest,
            restbutton = 'Rest Timer on',
            _restbuttoncolor = Colors.white
          ];

    notifyListeners();
  }

  resttimecheck(resttime) {
    _changetime = resttime;
    notifyListeners();
  }

  resettimer(resttime) {
    _timeron = resttime;
    _timetosubstract = resttime;
    _timerstarttime = DateTime.now();
    notifyListeners();
  }

  getstarttime() async {
    _starttime = await DateTime.now();
    return _starttime;
  }

  getprefs(value) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('lastroutine', value);
  }

  void routinecheck(rindex) async {
    final storage = FlutterSecureStorage();
    _starttime = await getstarttime();
    if (_isstarted == false) {
      await storage.write(key: "sdb_isStart", value: "true");
      print(_starttime);
      print(_starttime.toString());
      await storage.write(key: "sdb_startTime", value: _starttime.toString());
      await storage.write(key: "sdb_initialEx", value: "");
      await storage.write(key: "sdb_initialRindex", value: rindex.toString());
      int counter = 10001;
      timer1 = Timer.periodic(Duration(seconds: 1), (timer) {
        _routineTime = DateTime.now().difference(_starttime).inSeconds;
        _timeron = _timetosubstract -
            DateTime.now().difference(_timerstarttime).inSeconds;
        if (_timeron == 0 && _userest) {
          Vibration.vibrate(duration: 1000);
        }
        counter--;
        notifyListeners();
        if (counter == 0) {
          timer.cancel();
          _routineTime = 0;
        }
      });
      _routineButton = '운동 종료 하기';
      _buttoncolor = Color(0xFffc60a8);
      _isstarted = !_isstarted;
      _nowonrindex = rindex;
      _showNotificationWithChronometer(_starttime);
      notifyListeners();
    } else {
      await storage.write(key: "sdb_isStart", value: "false");
      await storage.write(key: "sdb_startTime", value: "");
      await storage.write(key: "sdb_initialEx", value: "");
      await storage.write(key: "sdb_initialRindex", value: "");
      timer1!.cancel();
      _routineTime = 0;
      _timeron = 0;
      _routineButton = '운동 시작 하기';
      _buttoncolor = const Color(0xff7a28cb);
      _isstarted = !_isstarted;
      _cancelNotificationWithChronometer();
      notifyListeners();
    }
  }

  void routineInitialCheck() async {
    var _initialTime;
    var _isInitialStart;
    var _initialEx;
    var _initialRindex;
    final storage = FlutterSecureStorage();
    try {
      String? _isInitialStart = await storage.read(key: "sdb_isStart");
      String? _isInitialTime = await storage.read(key: "sdb_startTime");
      String? _initialEx = await storage.read(key: "sdb_initialEx");
      String? _initialRindex = await storage.read(key: "sdb_initialRindex");

      if (_isInitialStart == "true") {
        _starttime = await getstarttime();
        _starttime = DateTime.parse(_isInitialTime!);
        print(_starttime);
        int counter = 10001;
        timer1 = Timer.periodic(Duration(seconds: 1), (timer) {
          _routineTime = DateTime.now().difference(_starttime).inSeconds;
          _timeron = _timetosubstract -
              DateTime.now().difference(_timerstarttime).inSeconds;
          if (_timeron == 0 && _userest) {
            Vibration.vibrate(duration: 1000);
          }
          counter--;
          notifyListeners();
          if (counter == 0) {
            timer.cancel();
            _routineTime = 0;
          }
        });
        _showNotificationWithChronometer(_starttime);
        _routineButton = '운동 종료 하기';
        _buttoncolor = Color(0xFffc60a8);
        _isstarted = !_isstarted;
        _nowonrindex = int.parse(_initialRindex!);
        notifyListeners();
      }
    } catch (e) {
      await storage.write(key: "sdb_isStart", value: "false");
      await storage.write(key: "sdb_startTime", value: "");
      await storage.write(key: "sdb_initialEx", value: "");
      await storage.write(key: "sdb_initialRindex", value: "");

      _cancelNotificationWithChronometer();
      null;
    }
  }

  Future<void> _showNotificationWithChronometer(DateTime _starttime) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    print(DateTime.now());
    print(DateTime.now().millisecondsSinceEpoch / 1000);
    print(_starttime);
    print(_starttime.millisecondsSinceEpoch / 1000);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('Supero', 'Supero',
            channelDescription: 'Supero에서는 운동을 지원합니다',
            importance: Importance.max,
            priority: Priority.high,
            when: _starttime.millisecondsSinceEpoch,
            usesChronometer: true,
            ongoing: true,
            autoCancel: false);
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, '운동을 하고 있어요', "누른 후 운동으로 돌아가보세요", platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _cancelNotificationWithChronometer() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}
