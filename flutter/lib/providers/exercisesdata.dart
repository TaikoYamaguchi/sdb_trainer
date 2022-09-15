import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';

class ExercisesdataProvider extends ChangeNotifier {
  var _exercisesdata;
  var _homeExList;
  get exercisesdata => _exercisesdata;
  get homeExList => _homeExList;
  getdata() async {
    await ExercisesRepository.loadExercisesdata().then((value) {
      _exercisesdata = value;
      notifyListeners();
    });
  }

  addExdata(Exercises) {
    _exercisesdata.exercises.add(Exercises);
    notifyListeners();
  }

  putHomeExList(exList) async {
    _homeExList = exList;
    notifyListeners();
  }

  removeHomeExList(index) async {
    _homeExList.removeAt(index);
    notifyListeners();
  }

  insertHomeExList(index, item) async {
    _homeExList.insert(index, item);
    notifyListeners();
  }

  addHomeExList(item) async {
    _homeExList.add(item);
    notifyListeners();
  }
}
