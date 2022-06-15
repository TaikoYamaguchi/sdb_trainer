import 'dart:async';

import 'package:flutter/cupertino.dart';

class RoutineTimeProvider extends ChangeNotifier {
  int _routineTime = 0;
  int get routineTime => _routineTime;
  Timer? timer1;
  bool _isstarted = false;
  bool get isstarted => _isstarted;
  String _routineButton = 'Start Workout';
  String get routineButton => _routineButton;
  Color _buttoncolor = Color(0xFF2196F3);
  Color get buttoncolor => _buttoncolor;
  void routinecheck(){
    if(_isstarted==false)
    {
      int counter = 10001;
      timer1  = Timer.periodic(Duration(seconds: 1), (timer){
        _routineTime++;
        print(_routineTime);
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
