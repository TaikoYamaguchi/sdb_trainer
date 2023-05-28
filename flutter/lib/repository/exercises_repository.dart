import 'dart:convert';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:http/http.dart' as http;
import 'package:sdb_trainer/localhost.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExercisesRepository {
  static Future<String> _loadExercisesdataFromServer() async {
    const storage = FlutterSecureStorage();
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

  static Future<String> _loadExercisesdataAllFromServer() async {
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/exercise/");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<ExercisesdataList> loadExercisesdataAll() async {
    String jsonString = await _loadExercisesdataAllFromServer();
    final jsonResponse = json.decode(jsonString);
    ExercisesdataList exercisesdatalist =
        ExercisesdataList.fromJson(jsonResponse);
    return (exercisesdatalist);
  }
}

class ExercisePost {
  final String user_email;
  final List<Exercises> exercises;
  ExercisePost({
    required this.user_email,
    required this.exercises,
  });
  Future<String> _exercisePostFromServer() async {
    var formData = Map<String, dynamic>();
    formData["user_email"] = user_email;
    formData["exercises"] = jsonEncode(exercises);
    formData["modified_number"] = 0;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/exercisecreate");
    var response = await http.post(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> postExercise() async {
    String jsonString = await _exercisePostFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class ExerciseEdit {
  final String user_email;
  final List<Exercises> exercises;
  ExerciseEdit({
    required this.user_email,
    required this.exercises,
  });
  Future<String> _exerciseEditFromServer() async {
    var formData = Map<String, dynamic>();
    formData["user_email"] = user_email;
    formData["exercises"] = jsonEncode(exercises);
    formData["modified_number"] = 0;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/exercise");
    var response = await http.put(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> editExercise() async {
    String jsonString = await _exerciseEditFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class ExerciseEditAll {
  final List<Exercisesdata> exercisedatas;
  ExerciseEditAll({
    required this.exercisedatas,
  });
  Future<String> _exerciseEditFromServer() async {
    var formData = Map<String, dynamic>();
    formData["exercisedatas"] = jsonEncode(exercisedatas);
    print(formData);

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/exercise/all");
    var response = await http.put(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<List<dynamic>> editExercise() async {
    String jsonString = await _exerciseEditFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}
