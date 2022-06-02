import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';

class WorkoutdataProvider extends ChangeNotifier {
  var _workoutdata;
  get workoutdata => _workoutdata;

  getdata() {
    RoutineRepository.loadRoutinedata().then((value) {
      _workoutdata = value;
      notifyListeners();
    });

  }

  boolcheck(rindex, eindex, sindex, newvalue) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets[sindex].ischecked = newvalue;
    notifyListeners();
  }

  weightcheck(rindex, eindex, sindex, newvalue) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets[sindex].weight = newvalue;
    notifyListeners();
  }

  repscheck(rindex, eindex, sindex, newvalue) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets[sindex].reps = newvalue;
    notifyListeners();
  }

  setsminus(rindex, eindex) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets.removeLast();
    notifyListeners();
  }

  setsplus(rindex, eindex) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets.add(new Sets(
        index: _workoutdata.routinedatas[rindex].exercises[eindex].sets.length + 1,
        weight: 0.0,
        reps: 1,
        ischecked: false));
    notifyListeners();
  }

}