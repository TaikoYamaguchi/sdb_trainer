import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:sdb_trainer/localhost.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/model/interviewdata.dart';

class InterviewService {
  static Future<String> _loadInterviewDataFromServer() async {
    final storage = new FlutterSecureStorage();
    String? user_email = await storage.read(key: "sdb_email");
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/interview/" + user_email!);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<InterviewDataList> loadInterviewDataByEmail() async {
    String jsonString = await _loadInterviewDataFromServer();
    final jsonResponse = json.decode(jsonString);
    InterviewDataList interviewData = InterviewDataList.fromJson(jsonResponse);
    return (interviewData);
  }
}

class InterviewdataFirst {
  static Future<String> _loadInterviewDataFromServer() async {
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/interview");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<InterviewDataList> loadInterviewDataFirst() async {
    String jsonString = await _loadInterviewDataFromServer();
    final jsonResponse = json.decode(jsonString);
    InterviewDataList interviewData = InterviewDataList.fromJson(jsonResponse);
    return (interviewData);
  }
}

class InterviewdataPagination {
  final int final_interview_id;
  InterviewdataPagination({
    required this.final_interview_id,
  });

  Future<String> _loadInterviewDataPageFromServer() async {
    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/interviews/${final_interview_id}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<InterviewDataList> loadInterviewDataAllPagination() async {
    String jsonString = await _loadInterviewDataPageFromServer();
    final jsonResponse = json.decode(jsonString);
    InterviewDataList interviewDatas = InterviewDataList.fromJson(jsonResponse);
    return (interviewDatas);
  }
}

class InterviewPost {
  final String user_email;
  final String user_nickname;
  final String title;
  final String content;
  final List<String> tags;
  InterviewPost({
    required this.user_email,
    required this.user_nickname,
    required this.title,
    required this.content,
    required this.tags,
  });
  Future<String> _interviewPostFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["user_email"] = user_email;
    formData["user_nickname"] = user_nickname;
    formData["title"] = title;
    formData["content"] = content;
    formData["tags"] = tags;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/interviewcreate");
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

  Future<Map<String, dynamic>> postInterview() async {
    String jsonString = await _interviewPostFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class InterviewLike {
  final int interview_id;
  final String user_email;
  final String status;
  final String disorlike;
  InterviewLike(
      {required this.interview_id,
      required this.user_email,
      required this.status,
      required this.disorlike});
  Future<String> _interviewLikeFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["interview_id"] = interview_id;
    formData["email"] = user_email;
    formData["status"] = status;
    formData["disorlike"] = disorlike;

    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/interview/likes/${interview_id}");
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

  Future<Map<String, dynamic>> patchInterviewLike() async {
    String jsonString = await _interviewLikeFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class InterviewDelete {
  final int interview_id;
  InterviewDelete({
    required this.interview_id,
  });
  Future<String> _interviewDeletefromServer() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");

    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/interviewDelete/${interview_id}");
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

  Future<Map<String, dynamic>> deleteInterview() async {
    String jsonString = await _interviewDeletefromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}
