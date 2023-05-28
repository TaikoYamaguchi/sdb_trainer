import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:sdb_trainer/localhost.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RoutineRepository {
  static Future<String> _loadRoutinedataFromLocation() async {
    return await rootBundle.loadString('assets/json/workout.json');
  }

  static Future<String> _loadRoutinedataFromServer() async {
    const storage = FlutterSecureStorage();
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

  static Future<Routinedata> loadRoutinedata() async {
    String jsonString = await _loadRoutinedataFromServer();
    final jsonResponse = json.decode(jsonString);
    Routinedata routinedata = Routinedata.fromJson(jsonResponse);
    return (routinedata);
  }
}

class WorkoutPost {
  final String user_email;
  final List<Routinedatas> routinedatas;
  WorkoutPost({
    required this.user_email,
    required this.routinedatas,
  });
  Future<String> _workoutPostFromServer() async {
    var formData = Map<String, dynamic>();
    formData["user_email"] = user_email;
    formData["id"] = 0;
    formData["routinedatas"] = jsonEncode(routinedatas);

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/workoutcreate");
    var response = await http.post(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.

      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> postWorkout() async {
    String jsonString = await _workoutPostFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class WorkoutEdit {
  final String user_email;
  final int id;
  final List<Routinedatas> routinedatas;
  WorkoutEdit({
    required this.user_email,
    required this.id,
    required this.routinedatas,
  });
  Future<String> _workoutEditFromServer() async {
    var formData = Map<String, dynamic>();
    formData["user_email"] = user_email;
    formData["id"] = id;
    formData["routinedatas"] = jsonEncode(routinedatas);

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/workout");
    var response = await http.put(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.

      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> editWorkout() async {
    String jsonString = await _workoutEditFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class WorkoutDelete {
  final int id;
  WorkoutDelete({
    required this.id,
  });
  Future<String> _workoutDeleteFromServer() async {
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/workout/" + id.toString());
    var response = await http.delete(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to delete');
    }
  }

  Future deleteWorkout() async {
    String jsonString = await _workoutDeleteFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}
