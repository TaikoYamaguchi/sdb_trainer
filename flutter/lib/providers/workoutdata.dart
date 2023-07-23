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
      notifyListeners();
    });
  }

  getdatawbu() {
    RoutineRepository.loadRoutinedata().then((value) {
      _workoutdata = value;
      notifyListeners();
    });
  }

  boolcheck(rindex, eindex, sindex, newvalue) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets[sindex].ischecked =
        newvalue;
    notifyListeners();
  }

  boolplancheck(rindex, eindex, sindex, progress_day, newvalue) {
    _workoutdata.routinedatas[rindex].exercises[0].plans[progress_day]
        .exercises[eindex].sets[sindex].ischecked = newvalue;
    notifyListeners();
  }

  planboolcheck(rindex, eindex, sindex, newvalue) {
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises[eindex]
        .sets[sindex]
        .ischecked = newvalue;
    notifyListeners();
  }

  weightcheck(rindex, eindex, sindex, newvalue) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets[sindex].weight =
        newvalue;
    notifyListeners();
  }

  plansetcheck(rindex, eindex, sindex, newWeightRatio, newWeight, newReps) {
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises[eindex]
        .sets[sindex]
        .weight = newWeight;
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises[eindex]
        .sets[sindex]
        .reps = newReps;
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises[eindex]
        .sets[sindex]
        .index = newWeightRatio;
    notifyListeners();
  }

  repscheck(rindex, eindex, sindex, newvalue) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets[sindex].reps =
        newvalue;
    notifyListeners();
  }

  resttimecheck(rindex, eindex, newvalue) {
    _workoutdata.routinedatas[rindex].exercises[eindex].rest = newvalue;
    notifyListeners();
  }

  setsminus(rindex, eindex) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets.removeLast();
    notifyListeners();
  }

  plansetsminus(rindex, eindex) {
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises[eindex]
        .sets
        .removeLast();
    notifyListeners();
  }

  setsminusIndex(rindex, eindex, index) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets.removeAt(index);
    notifyListeners();
  }

  removeroutineAt(rindex) {
    _workoutdata.routinedatas.removeAt(rindex);
    notifyListeners();
  }

  insertroutineAt(rindex, data) {
    _workoutdata.routinedatas.insert(rindex, data);
    notifyListeners();
  }

  addroutine(routine) {
    _workoutdata.routinedatas.add(routine);
    notifyListeners();
  }

  removeexAt(rindex, eindex) {
    _workoutdata.routinedatas[rindex].exercises.removeAt(eindex);
    notifyListeners();
  }

  planremoveexAt(rindex) {
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises
        .removeLast();
    notifyListeners();
  }

  addexAt(rindex, ex) {
    _workoutdata.routinedatas[rindex].exercises.add(ex);
    notifyListeners();
  }

  addplanAt(rindex, ex) {
    _workoutdata.routinedatas[rindex].exercises[0].plans.insert(
        _workoutdata.routinedatas[rindex].exercises[0].progress + 1, ex);
    notifyListeners();
  }

  removeplanAt(rindex) {
    _workoutdata.routinedatas[rindex].exercises[0].plans
        .removeAt(_workoutdata.routinedatas[rindex].exercises[0].progress);
    notifyListeners();
  }

  setplanprogress(rindex, progress) {
    _workoutdata.routinedatas[rindex].exercises[0].progress = progress;
    notifyListeners();
  }

  planaddexAt(rindex, ex) {
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises
        .add(ex);
    notifyListeners();
  }

  planchangeexnameAt(rindex, eindex, change) {
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises[eindex]
        .name = change;

    notifyListeners();
  }

  planchangeexrefnameAt(rindex, eindex, change) {
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises[eindex]
        .ref_name = change;
    notifyListeners();
  }

  namechange(rindex, newname) {
    _workoutdata.routinedatas[rindex].name = newname;
    notifyListeners();
  }

  dataBU(rindex) {
    backupdata = List.from(_workoutdata.routinedatas[rindex].exercises);
  }

  changebudata(rindex) {
    _workoutdata.routinedatas[rindex].exercises = backupdata;
    notifyListeners();
  }

  setsplus(rindex, eindex, lastset) {
    _workoutdata.routinedatas[rindex].exercises[eindex].sets.add(Sets(
        index: 0.0,
        weight: lastset.weight,
        reps: lastset.reps,
        ischecked: false));
    notifyListeners();
  }

  plansetsplus(rindex, eindex) {
    _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises[eindex]
        .sets
        .add(Sets(index: 30, weight: 20, reps: 8, ischecked: false));
    notifyListeners();
  }
}
