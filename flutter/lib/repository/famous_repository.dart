import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdb_trainer/localhost.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class FamousRepository {
  static Future<String> _loadFamousdataFromLocation() async {
    return await rootBundle.loadString('assets/json/workout.json');
  }

  static Future<String> _loadFamousdataFromServer() async {
    var url =
    Uri.parse(LocalHost.getLocalHost() + "/api/famous");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<FamousList> loadFamousdata() async {
    String jsonString = await _loadFamousdataFromServer();
    final jsonResponse = json.decode(jsonString);
    FamousList famousdata = FamousList.fromJson(jsonResponse);
    print(famousdata);
    return (famousdata);
  }
}

class ProgramSubscribe {
  final int id;
  ProgramSubscribe({
    required this.id,

  });
  Future<String> _programSubscribeFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["id"] = id;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/famoussubscribe/${id}");
    var response = await http.post(url, body: json.encode(formData));
    print(json.encode(formData));
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

  Future<Map<String, dynamic>> subscribeProgram() async {
    String jsonString = await _programSubscribeFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}



class ProgramPost {
  final String user_email;
  final int type;
  final String image;
  final Routinedatas routinedata;
  final int level;
  final int category;
  ProgramPost({
    required this.user_email,
    required this.type,
    required this.image,
    required this.routinedata,
    required this.level,
    required this.category,
  });
  Future<String> _programPostFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["user_email"] = user_email;
    formData["type"] = type;
    formData["id"] = 0;
    formData["image"] = image;
    formData["routinedata"] = routinedata;
    formData["like"] = [];
    formData["dislike"] = [];
    formData["level"] = level;
    formData["subscribe"] = 0;
    formData["category"] = category;

    print(formData["image"]);

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/famouscreate");
    var response = await http.post(url, body: json.encode(formData));
    print(json.encode(formData));
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

  Future<Map<String, dynamic>> postProgram() async {
    String jsonString = await _programPostFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class FamousEdit {
  final String user_email;
  final int id;
  final List<Routinedatas> famousdatas;
  FamousEdit({
    required this.user_email,
    required this.id,
    required this.famousdatas,
  });
  Future<String> _workoutEditFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["user_email"] = user_email;
    formData["id"] = id;
    formData["famousdatas"] = jsonEncode(famousdatas);

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/workout");
    var response = await http.put(url, body: json.encode(formData));
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
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

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

class FamousImageEdit {
  final int famous_id;
  final dynamic file;
  FamousImageEdit({required this.famous_id, required this.file});
  Future<Map<String, dynamic>> _patchFamousImageFromServer() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");
    var formData =
    FormData.fromMap({'file': await MultipartFile.fromFile(file)});
    var dio = new Dio();
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;
      dio.options.headers["Authorization"] = "Bearer " + token!;

      var response = await dio.post(
        LocalHost.getLocalHost() + '/api/temp/famousimages/${famous_id}',
        data: formData,
      );
      print(response);
      return response.data;
    } catch (e) {
      print(e);
      throw Exception('Failed to load post');
    }
  }

  Future<Famous?> patchFamousImage() async {
    var jsonString = await _patchFamousImageFromServer();
    if (jsonString == null) {
      return null;
    } else {
      Famous famousdata = Famous.fromJson(jsonString);
      return (famousdata);
    }
  }
}

