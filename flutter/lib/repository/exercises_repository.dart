import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:http/http.dart' as http;
import 'package:sdb_trainer/localhost.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExercisesRepository {
  static Future<String> _loadExercisesdataFromLocation() async {
    return await rootBundle.loadString('assets/json/exercises.json');
  }

  static Future<String> _loadExercisesdataFromServer() async {
    final storage = new FlutterSecureStorage();
    String? user_email = await storage.read(key: "sdb_email");
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/exercise/" + user_email!);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<Exercisesdata> loadExercisesdata() async {
    String jsonString = await _loadExercisesdataFromServer();
    final jsonResponse = json.decode(jsonString);
    Exercisesdata exercisesdata = Exercisesdata.fromJson(jsonResponse);
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
  ExercisesRepository.loadExercisesdata().then((value) {
    _routinedata = value;
    final data1 = _routinedata!.exercises.where((ex) {
      final name = ex.name;
      return name.contains("스쿼트");
    }).toList();
    print(data1);
  });

  dynamic _routinedata2;
  ExercisesRepository.loadExercisesdata2().then((value) {
    _routinedata2 = value;
    _routinedata2["asd"] = "asd";
    //print(_routinedata2!["asd"]);
  });
}
