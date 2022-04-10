import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdb_trainer/localhost.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RoutineRepository {
  static Future<String> _loadRoutinedataFromLocation() async {
    return await rootBundle.loadString('assets/json/workout.json');
  }

  static Future<String> _loadRoutinedataFromServer() async {
    final storage = new FlutterSecureStorage();
    String? user_email = await storage.read(key: "sdb_email");
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/workout/" + user_email!);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<RoutinedataList> loadRoutinedata() async {
    String jsonString = await _loadRoutinedataFromServer();
    final jsonResponse = json.decode(jsonString);
    RoutinedataList routinedata = RoutinedataList.fromJson(jsonResponse);
    return (routinedata);
  }
}

main() {
  WidgetsFlutterBinding.ensureInitialized();
  RoutinedataList _routinedata;
  RoutineRepository.loadRoutinedata().then((value) {
    _routinedata = value;
    print(_routinedata.routinedatas[0].exercises[0].sets[0].ischecked);
    _routinedata.routinedatas[0].exercises[0].sets[0].ischecked = true;

    print(_routinedata.routinedatas[0].exercises[0].sets[0].ischecked);
  });
}
