import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:sdb_trainer/localhost.dart';
import 'package:http/http.dart' as http;

import 'package:sdb_trainer/src/model/historydata.dart';

class ExerciseService {
  static Future<String> _loadSDBdataFromLocation() async {
    return await rootBundle.loadString("assets/json/history.json");
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  static Future<String> _loadSDBdataFromServer() async {
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/history/cksdnr1@gmail.com");
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
    print(jsonString);
    final jsonResponse = json.decode(jsonString);
    SDBdataList sdbdata = SDBdataList.fromJson(jsonResponse);
    print(sdbdata);
    return (sdbdata);
  }
}
