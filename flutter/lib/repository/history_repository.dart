import 'dart:async' show Future;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:sdb_trainer/localhost.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/model/historydata.dart';

class ExerciseService {
  static Future<String> _loadSDBdataFromServer() async {
    const storage = FlutterSecureStorage();
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

class HistorydataAllGetforChange {
  static Future<String> _loadSDBdataFromServer() async {
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/historyallget");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<SDBdataList> loadSDBdataAllchange() async {
    String jsonString = await _loadSDBdataFromServer();
    final jsonResponse = json.decode(jsonString);
    SDBdataList sdbdata = SDBdataList.fromJson(jsonResponse);
    return (sdbdata);
  }
}

class HistorydataPagination {
  final int final_history_id;
  HistorydataPagination({
    required this.final_history_id,
  });

  Future<String> _loadSDBdataPageFromServer() async {
    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/histories/${final_history_id}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<SDBdataList> loadSDBdataPagination() async {
    String jsonString = await _loadSDBdataPageFromServer();
    final jsonResponse = json.decode(jsonString);
    SDBdataList sdbdata = SDBdataList.fromJson(jsonResponse);
    return (sdbdata);
  }
}

class HistorydataFriends {
  Future<String> _loadFriendsSDBdataFromServer() async {
    const storage = FlutterSecureStorage();
    String? user_email = await storage.read(key: "sdb_email");
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

class HistorydataUserEmail {
  final String user_email;
  HistorydataUserEmail({
    required this.user_email,
  });
  Future<String> _loadUserEmailSDBdataFromServer() async {
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/history/${user_email}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<SDBdataList> loadSDBdataUserEmail() async {
    String jsonString = await _loadUserEmailSDBdataFromServer();
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
    var formData = Map<String, dynamic>();
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
    var formData = Map<String, dynamic>();
    formData["history_id"] = history_id;
    formData["email"] = user_email;
    formData["status"] = status;
    formData["disorlike"] = disorlike;

    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/history/likes/${history_id}");
    var response = await http.patch(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
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
    var formData = Map<String, dynamic>();
    formData["id"] = history_id;
    formData["email"] = user_email;
    formData["comment"] = comment;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/history/comment/edit");
    var response = await http.patch(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
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
    var formData = Map<String, dynamic>();
    formData["id"] = history_id;
    formData["email"] = user_email;
    formData["exercises"] = exercises;

    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/history/exercises/edit");
    var response = await http.patch(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
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
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");
    var formData = Map<String, dynamic>();
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
    const storage = FlutterSecureStorage();
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

class HistoryImageEdit {
  final int history_id;
  final List<XFile> file;
  HistoryImageEdit({required this.history_id, required this.file});
  Future<Map<String, dynamic>> _patchHistoryImageFromServer() async {
    final List<MultipartFile> _files = file
        .map((img) => MultipartFile.fromFileSync(
              img.path,
            ))
        .toList();
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");
    var formData = FormData.fromMap({'files': _files});
    var dio = Dio();
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;
      dio.options.headers["Authorization"] = "Bearer " + token!;

      var response = await dio.post(
        LocalHost.getLocalHost() + '/api/temp/historyimages/${history_id}',
        data: formData,
      );
      return response.data;
    } catch (e) {
      print(e);
      throw Exception('Failed to load post');
    }
  }

  Future<SDBdata?> patchHistoryImage() async {
    var jsonString = await _patchHistoryImageFromServer();
    // ignore: unnecessary_null_comparison
    if (jsonString == null) {
      return null;
    } else {
      SDBdata user = SDBdata.fromJson(jsonString);
      return (user);
    }
  }
}

class HistoryImagePut {
  final int history_id;
  final List<dynamic> images;
  HistoryImagePut({
    required this.history_id,
    required this.images,
  });
  Future<String> _historyImageListEditfromServer() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");

    var formData = Map<String, dynamic>();
    formData["image"] = images;
    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/temp/historyimages/${history_id}");
    var response = await http.put(
      url,
      body: json.encode(formData),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${token}',
      },
    );
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> editHistoryListImage() async {
    String jsonString = await _historyImageListEditfromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class HistoryImageDelete {
  final int history_id;
  HistoryImageDelete({
    required this.history_id,
  });
  Future<String> _historyImageDeletefromServer() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");

    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/remove/historyimages/${history_id}");
    var response = await http.put(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${token}',
      },
    );
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> deleteHistoryIamge() async {
    String jsonString = await _historyImageDeletefromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class HistoryEditAll {
  final List<SDBdata> sdbdatas;
  HistoryEditAll({
    required this.sdbdatas,
  });
  Future<String> _historyEditFromServer() async {
    var formData = Map<String, dynamic>();
    formData["sdbdatas"] = jsonEncode(sdbdatas);
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/history/all");
    var response = await http.put(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<List<dynamic>> editHistory() async {
    String jsonString = await _historyEditFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}
