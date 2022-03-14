import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';

class ExercisesdataProvider extends ChangeNotifier {
  Exercisesdata? _exercisesdata;
  get exercisesdata => _exercisesdata;
  getdata() {
    ExercisesRepository.loadExercisesdata().then((value) {
      _exercisesdata = value;
      notifyListeners();
    });

  }

}