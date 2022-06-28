import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';

class WorkoutdataProvider extends ChangeNotifier {
  var _workoutdata;
  List<Exercises>? backupdata;
  get workoutdata => _workoutdata;

  getdata() {
    RoutineRepository.loadRoutinedata().then((value) {
      _workoutdata = value;
      print("getdataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa?");
      notifyListeners();
    });

  }

  getdatawbu() {
    RoutineRepository.loadRoutinedata().then((value) {
      _workoutdata = value;
      print("getdataaaaaaaaaawbu?");
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

  removeroutineAt(rindex) {
    _workoutdata.routinedatas.removeAt(rindex);
    notifyListeners();
  }

  insertroutineAt(rindex, data) {
    _workoutdata.routinedatas.insert(rindex,data);
    notifyListeners();
  }

  addroutine(routine) {
    _workoutdata.routinedatas.add(routine);
    notifyListeners();
  }

  removeexAt(rindex,eindex) {
    _workoutdata.routinedatas[rindex].exercises.removeAt(eindex);
    notifyListeners();
  }

  addexAt(rindex,ex) {
    _workoutdata.routinedatas[rindex].exercises.add(ex);
    notifyListeners();
  }

  namechange(rindex ,newname) {
    _workoutdata.routinedatas[rindex].name = newname;
    notifyListeners();
  }

  dataBU(rindex){
    backupdata = new List.from(_workoutdata.routinedatas[rindex].exercises);

  }

  changebudata(rindex){
    _workoutdata.routinedatas[rindex].exercises = backupdata;
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