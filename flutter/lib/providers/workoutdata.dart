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

  restPlanTime(rindex, progress, newvalue) {
    _workoutdata.routinedatas[rindex].exercises[0].plans[progress].exercises[0]
        .rest = newvalue;
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
    print(progress);
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
    var cur_ex_sets = _workoutdata
        .routinedatas[rindex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rindex].exercises[0].progress]
        .exercises[eindex]
        .sets;
    if (cur_ex_sets.isEmpty) {
      cur_ex_sets.add(Sets(index: 40, weight: 5, reps: 12, ischecked: false));
    } else {
      cur_ex_sets.add(Sets(
          index: cur_ex_sets.last.index,
          weight: cur_ex_sets.last.weight,
          reps: cur_ex_sets.last.reps,
          ischecked: false));
    }
    notifyListeners();
  }

  planSetsCheck(rIndex, eIndex, onerm) {
    List<Sets> cur_ex_sets = _workoutdata
        .routinedatas[rIndex]
        .exercises[0]
        .plans[_workoutdata.routinedatas[rIndex].exercises[0].progress]
        .exercises[eIndex]
        .sets;
    for (Sets set in cur_ex_sets) {
      if (onerm != 0) {
        if (set.ischecked == false) {
          set.weight =
              (onerm / (1 + set.reps / 30) * set.index / 100 / 0.5).floor() *
                  0.5;
        }
      } else {
        if (set.ischecked == false) {
          set.weight = 5;
        }
      }
    }
  }
}
