import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../src/model/sdbdata.dart';

class ExerciseService {
  static Future<String> _loadSDBdataFromLocation() async {
    return await rootBundle.loadString("assets/json/history.json");
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  static Future<SDBdataList> loadSDBdata() async {
    String jsonString = await _loadSDBdataFromLocation();
    final jsonResponse = json.decode(jsonString);
    SDBdataList sdbdata = SDBdataList.fromJson(jsonResponse);
    print(sdbdata.sdbdatas);
    return (sdbdata);
  }
}
