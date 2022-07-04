import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:sdb_trainer/localhost.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

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
    SDBdataList sdbdata = SDBdataList.fromJson(jsonResponse);
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

class HistorydataFriends {
  final String user_email;
  HistorydataFriends({required this.user_email});
  Future<String> _loadFriendsSDBdataFromServer() async {
    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/historyFriends/${user_email}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<SDBdataList> loadSDBdataFriends() async {
    String jsonString = await _loadFriendsSDBdataFromServer();
    final jsonResponse = json.decode(jsonString);
    SDBdataList sdbdata = SDBdataList.fromJson(jsonResponse);
    return (sdbdata);
  }
}

class HistoryPost {
  final String user_email;
  final String nickname;
  final List<Exercises> exercises;
  final int new_record;
  final int workout_time;
  HistoryPost({
    required this.user_email,
    required this.exercises,
    required this.new_record,
    required this.workout_time,
    required this.nickname,
  });
  Future<String> _historyPostFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["user_email"] = user_email;
    formData["exercises"] = jsonEncode(exercises);
    formData["new_record"] = new_record;
    formData["workout_time"] = workout_time;
    formData["like"] = [];
    formData["dislike"] = [];
    formData["image"] = [];
    formData["comment"] = "";
    formData["nickname"] = nickname;

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

class HistoryLike {
  final int history_id;
  final String user_email;
  final String status;
  final String disorlike;
  HistoryLike(
      {required this.history_id,
      required this.user_email,
      required this.status,
      required this.disorlike});
  Future<String> _historyLikeFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["history_id"] = history_id;
    formData["email"] = user_email;
    formData["status"] = status;
    formData["disorlike"] = disorlike;

    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/history/likes/${history_id}");
    var response = await http.patch(url, body: json.encode(formData));
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

  Future<Map<String, dynamic>> patchHistoryLike() async {
    String jsonString = await _historyLikeFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class HistoryCommentEdit {
  final int history_id;
  final String user_email;
  final String comment;
  HistoryCommentEdit(
      {required this.history_id,
      required this.user_email,
      required this.comment});
  Future<String> _historyCommentFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["id"] = history_id;
    formData["email"] = user_email;
    formData["comment"] = comment;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/history/comment/edit");
    var response = await http.patch(url, body: json.encode(formData));
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

  Future<Map<String, dynamic>> patchHistoryComment() async {
    String jsonString = await _historyCommentFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class HistoryExercisesEdit {
  final int history_id;
  final String user_email;
  final List<Exercises> exercises;
  HistoryExercisesEdit(
      {required this.history_id,
      required this.user_email,
      required this.exercises});
  Future<String> _historyExercisesEditfromServer() async {
    var formData = new Map<String, dynamic>();
    formData["id"] = history_id;
    formData["email"] = user_email;
    formData["exercises"] = exercises;

    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/history/exercises/edit");
    var response = await http.patch(url, body: json.encode(formData));
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

  Future<Map<String, dynamic>> patchHistoryExercises() async {
    String jsonString = await _historyExercisesEditfromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class HistoryVisibleEdit {
  final int history_id;
  final String status;
  HistoryVisibleEdit({
    required this.history_id,
    required this.status,
  });
  Future<String> _historyVisibleEditfromServer() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");
    var formData = new Map<String, dynamic>();
    formData["history_id"] = history_id;
    formData["status"] = status;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/historyVisible");
    var response = await http.patch(url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token}',
        },
        body: json.encode(formData));
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

  Future<Map<String, dynamic>> patchHistoryVisible() async {
    String jsonString = await _historyVisibleEditfromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class HistoryDelete {
  final int history_id;
  HistoryDelete({
    required this.history_id,
  });
  Future<String> _historyDeletefromServer() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");

    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/historyDelete/${history_id}");
    var response = await http.delete(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${token}',
      },
    );
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

  Future<Map<String, dynamic>> deleteHistory() async {
    String jsonString = await _historyDeletefromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}
