import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

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

  Timer? timer1;
  bool _isstarted = false;
  bool get isstarted => _isstarted;
  bool _userest = false;
  bool get userest => _userest;
  String restbutton = 'Rest Timer off';
  Color _restbuttoncolor = Color(0xFF717171);
  Color get restbuttoncolor => _restbuttoncolor;
  String _routineButton = 'Start Workout';
  String get routineButton => _routineButton;
  Color _buttoncolor = Color(0xFF2196F3);
  Color get buttoncolor => _buttoncolor;
  DateTime _starttime = DateTime(2022, 08, 06, 10, 30);
  DateTime _timerstarttime = DateTime(2022, 08, 06, 10, 30);

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

  getstarttime() {
    _starttime = DateTime.now();
  }

  void routinecheck(rindex) {
    getstarttime();
    if (_isstarted == false) {
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
          print('cancel timer');
          timer.cancel();
          _routineTime = 0;
        }
      });
      _routineButton = 'Finish Workout';
      _buttoncolor = Color(0xFF9C27B0);
      _isstarted = !_isstarted;
      _nowonrindex = rindex;
      notifyListeners();
    } else {
      timer1!.cancel();
      _routineTime = 0;
      _timeron = 0;
      _routineButton = 'Start Workout';
      _buttoncolor = Color(0xFF2196F3);
      _isstarted = !_isstarted;
      notifyListeners();
    }
  }
}
