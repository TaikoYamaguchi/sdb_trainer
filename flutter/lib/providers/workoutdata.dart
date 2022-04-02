import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';

class WorkoutdataProvider extends ChangeNotifier {
  var _workoutdata;
  get workoutdata => _workoutdata;

  getdata() {
    RoutineRepository.loadRoutinedata().then((value) {
      _workoutdata = value;
      notifyListeners();
    });

  }

}