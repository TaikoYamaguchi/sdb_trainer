import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdb_trainer/src/model/routinedata.dart';

class RoutineRepository {


  static Future<String> _loadRoutinedataFromLocation() async {
    return await rootBundle.loadString('assets/json/routine.json');
  }

  static Future<RoutinedataList> loadRoutinedata() async {
    String jsonString = await _loadRoutinedataFromLocation();
    final jsonResponse = json.decode(jsonString);
    RoutinedataList routinedata = RoutinedataList.fromJson(jsonResponse);
    print(routinedata);
    return (routinedata);
  }
}
