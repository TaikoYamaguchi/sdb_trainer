import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';


class RoutineRepository {


  static Future<String> _loadExercisedataFromLocation() async {
    return await rootBundle.loadString('assets/json/exercises.json');
  }

  static Future<Exercisesdata> loadExercisesdata() async {
    String jsonString = await _loadExercisedataFromLocation();
    final jsonResponse = json.decode(jsonString);
    Exercisesdata exercisesdata = Exercisesdata.fromJson(jsonResponse);
    print(exercisesdata);
    return (exercisesdata);
  }
}
