import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';

class ExercisesdataProvider extends ChangeNotifier {
  var _exercisesdata;
  get exercisesdata => _exercisesdata;
  getdata() async {
    print("!!!!!!!!!!!!!!!nononono");
    await ExercisesRepository.loadExercisesdata().then((value) {
      print("nononono");
      _exercisesdata = value;
      notifyListeners();
    });
  }
}
