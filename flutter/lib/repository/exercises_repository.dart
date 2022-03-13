import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';


class ExercisesRepository {


  static Future<String> _loadExercisesdataFromLocation() async {
    return await rootBundle.loadString('assets/json/exercises.json');
  }

  static Future<Exercisesdata> loadExercisesdata() async {
    String jsonString = await _loadExercisesdataFromLocation();
    final jsonResponse = json.decode(jsonString);
    Exercisesdata exercisesdata = Exercisesdata.fromJson(jsonResponse);
    print(exercisesdata);
    return (exercisesdata);
  }
  static Future<dynamic> loadExercisesdata2() async {
    String jsonString = await _loadExercisesdataFromLocation();
    final dynamic jsonResponse2 = json.decode(jsonString);
    return jsonResponse2;
  }
}


main() {
  WidgetsFlutterBinding.ensureInitialized();
  Exercisesdata? _routinedata;
  ExercisesRepository.loadExercisesdata().then((value){
    _routinedata = value;
    final data1 = _routinedata!.exercises.where((ex){
      final name = ex.name;
      return name.contains("스쿼트");
    }).toList();
    print(data1);
  });


  dynamic _routinedata2;
  ExercisesRepository.loadExercisesdata2().then((value){
    _routinedata2 = value;
    _routinedata2["asd"]="asd";
    //print(_routinedata2!["asd"]);
  });
}

