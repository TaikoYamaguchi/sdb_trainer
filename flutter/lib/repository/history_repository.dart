import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:sdb_trainer/localhost.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/model/historydata.dart';

class ExerciseService {
  static Future<String> _loadSDBdataFromLocation() async {
    return await rootBundle.loadString("assets/json/history.json");
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  static Future<String> _loadSDBdataFromServer() async {
    final storage = new FlutterSecureStorage();
    String? user_email = await storage.read(key: "sdb_email");
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/history/" + user_email!);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<SDBdataList> loadSDBdata() async {
    String jsonString = await _loadSDBdataFromServer();
    final jsonResponse = json.decode(jsonString);
    print(jsonResponse);
    SDBdataList sdbdata = SDBdataList.fromJson(jsonResponse);
    print(sdbdata);
    return (sdbdata);
  }
}

class HistorydataAll {
  static Future<String> _loadSDBdataFromServer() async {
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/history");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<SDBdataList> loadSDBdataAll() async {
    String jsonString = await _loadSDBdataFromServer();
    final jsonResponse = json.decode(jsonString);
    SDBdataList sdbdata = SDBdataList.fromJson(jsonResponse);
    return (sdbdata);
  }
}

class HistoryPost {
  final String user_email;
  final List<Exercises> exercises;
  final int new_record;
  final int workout_time;
  HistoryPost({
    required this.user_email,
    required this.exercises,
    required this.new_record,
    required this.workout_time,
  });
  Future<String> _historyPostFromServer() async {
    var formData = new Map<String, dynamic>();
    print(user_email);
    formData["user_email"] = user_email;
    formData["exercises"] = jsonEncode(exercises);
    formData["new_record"] = new_record;
    formData["workout_time"] = workout_time;
    print(formData);

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/historycreate");
    var response = await http.post(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> postHistory() async {
    String jsonString = await _historyPostFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}
