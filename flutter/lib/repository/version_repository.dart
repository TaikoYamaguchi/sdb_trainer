import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:sdb_trainer/localhost.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/model/historydata.dart';

class VersionService {
  static Future<String> _loadVersionDataFromServer() async {
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/version");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<String> loadVersionData() async {
    String jsonString = await _loadVersionDataFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}
