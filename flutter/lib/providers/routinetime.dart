import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/utils/notification.dart';

class RoutineTimeProvider extends ChangeNotifier {
  int _routineTime = 0;
  int _routineNewRecord = 0;
  int get routineNewRecord => _routineNewRecord;
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
  Color _restbuttoncolor = const Color(0xFF717171);
  Color get restbuttoncolor => _restbuttoncolor;
  String _routineButton = '운동 시작 하기';
  String get routineButton => _routineButton;
  Color _buttoncolor = const Color(0xff7a28cb);
  Color get buttoncolor => _buttoncolor;
  DateTime _starttime = DateTime(2022, 08, 06, 10, 30);
  DateTime _timerstarttime = DateTime(2022, 08, 06, 10, 30);

  var _prefs;

  nowoneindexupdate(value) {
    _nowoneindex = value;
  }

  newRoutineUpdate() {
    _routineNewRecord = _routineNewRecord + 1;
  }

  getinfo() {
    notifyListeners();
  }

  getrest() async {
    _prefs = await SharedPreferences.getInstance();
    _userest = _prefs.getBool('userest');
    notifyListeners();
  }

  setrest() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('userest', _userest);
  }

  restcheck() {
    _userest
        ? [
            _userest = !_userest,
            setrest(),
            restbutton = 'Rest Timer off',
            _restbuttoncolor = const Color(0xFF717171)
          ]
        : [
            _userest = !_userest,
            setrest(),
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

  addRestTime(int addedTime) {
    _timeron = _timeron + addedTime;
    _timerstarttime = _timerstarttime.add(Duration(seconds: addedTime));
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
    const storage = FlutterSecureStorage();
    _starttime = await getstarttime();
    if (_isstarted == false) {
      await storage.write(key: "sdb_isStart", value: "true");
      await storage.write(key: "sdb_startTime", value: _starttime.toString());
      await storage.write(key: "sdb_initialEx", value: "");
      await storage.write(key: "sdb_initialRindex", value: rindex.toString());
      int counter = 10001;
      timer1 = Timer.periodic(const Duration(seconds: 1), (timer) {
        _routineTime = DateTime.now().difference(_starttime).inSeconds;
        _timeron = _timetosubstract -
            DateTime.now().difference(_timerstarttime).inSeconds;
        if (_timeron == 0 && _userest) {
          Vibration.vibrate(
              pattern: [500, 1000, 500, 2000], intensities: [1, 255]);
        }
        counter--;
        notifyListeners();
        if (counter == 0) {
          timer.cancel();
          _routineTime = 0;
        }
      });
      _routineNewRecord = 0;
      _routineButton = '운동 종료 하기';
      _buttoncolor = const Color(0xFffc60a8);
      _isstarted = !_isstarted;
      _nowonrindex = rindex;
      showNotificationWithChronometer(_starttime);
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
      cancelNotificationWithChronometer();
      notifyListeners();
    }
  }

  void routineInitialCheck() async {
    const storage = FlutterSecureStorage();
    try {
      String? _isInitialStart = await storage.read(key: "sdb_isStart");
      String? _isInitialTime = await storage.read(key: "sdb_startTime");
      String? _initialRindex = await storage.read(key: "sdb_initialRindex");

      if (_isInitialStart == "true") {
        _starttime = await getstarttime();
        _starttime = DateTime.parse(_isInitialTime!);
        print(_starttime);
        int counter = 10001;
        resettimer(0);
        timer1 = Timer.periodic(const Duration(seconds: 1), (timer) {
          _routineTime = DateTime.now().difference(_starttime).inSeconds;
          _timeron = _timetosubstract -
              DateTime.now().difference(_timerstarttime).inSeconds;
          if (_timeron == 0 && _userest) {
            Vibration.vibrate(
                pattern: [500, 1000, 500, 2000], intensities: [1, 255]);
          }
          counter--;
          notifyListeners();
          if (counter == 0) {
            timer.cancel();
            _routineTime = 0;
          }
        });
        showNotificationWithChronometer(_starttime);
        _routineButton = '운동 종료 하기';
        _buttoncolor = const Color(0xFffc60a8);
        _isstarted = !_isstarted;
        _nowonrindex = int.parse(_initialRindex!);
        notifyListeners();
      }
    } catch (e) {
      await storage.write(key: "sdb_isStart", value: "false");
      await storage.write(key: "sdb_startTime", value: "");
      await storage.write(key: "sdb_initialEx", value: "");
      await storage.write(key: "sdb_initialRindex", value: "");

      cancelNotificationWithChronometer();
      null;
    }
  }
}
