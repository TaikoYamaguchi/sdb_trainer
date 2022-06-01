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
      _isstarted = !_isstarted;
      notifyListeners();
    }
    else{
      timer1!.cancel();
      _routineTime=0;
      _routineButton = 'Start Workout';
      _isstarted = !_isstarted;
      notifyListeners();
    }
  }


}
