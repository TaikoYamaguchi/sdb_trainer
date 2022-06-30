import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoutineTimeProvider extends ChangeNotifier {
  int _routineTime = 0;
  int get routineTime => _routineTime;
  int _changetime = 0;
  int get changetime => _changetime;
  int _timeron = 0;
  int get timeron => _timeron;

  Timer? timer1;
  bool _isstarted = false;
  bool get isstarted => _isstarted;
  bool _userest = false;
  bool get userest => _userest;
  String restbutton = 'Rest Timer off';
  Color _restbuttoncolor = Color(0xFF2196F3);
  Color get restbuttoncolor => _restbuttoncolor;
  String _routineButton = 'Start Workout';
  String get routineButton => _routineButton;
  Color _buttoncolor = Color(0xFF717171);
  Color get buttoncolor => _buttoncolor;

  restcheck() {
    _userest
    ? [_userest = !_userest, restbutton = 'Rest Timer off',_restbuttoncolor = Color(0xFF717171)]
    : [_userest = !_userest, restbutton = 'Rest Timer on',_restbuttoncolor = Colors.white];

    notifyListeners();
  }

  resttimecheck(resttime) {
    _changetime = resttime;

  }
  resettimer() {
    _timeron = _changetime;
    notifyListeners();

  }

  void routinecheck(){
    if(_isstarted==false)
    {
      int counter = 10001;
      _timeron = _changetime;
      timer1  = Timer.periodic(Duration(seconds: 1), (timer){
        _routineTime++;
        _timeron--;
        if(_timeron == 0){
          print('진동!!!!!!!!');
        }
        counter--;
        notifyListeners();
        if (counter == 0) {
          print('cancel timer');
          timer.cancel();
          _routineTime=0;
        }
      });
      _routineButton = 'Finish Workout';
      _buttoncolor = Color(0xFF9C27B0);
      _isstarted = !_isstarted;
      notifyListeners();
    }
    else{
      timer1!.cancel();
      _routineTime=0;
      _routineButton = 'Start Workout';
      _buttoncolor = Color(0xFF2196F3);
      _isstarted = !_isstarted;
      notifyListeners();
    }
  }


}
