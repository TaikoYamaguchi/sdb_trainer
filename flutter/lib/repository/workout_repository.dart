import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';

class RoutineRepository {


  static Future<String> _loadRoutinedataFromLocation() async {
    return await rootBundle.loadString('assets/json/workout.json');
  }

  static Future<RoutinedataList> loadRoutinedata() async {
    String jsonString = await _loadRoutinedataFromLocation();
    final jsonResponse = json.decode(jsonString);
    RoutinedataList routinedata = RoutinedataList.fromJson(jsonResponse);
    print(routinedata);
    return (routinedata);
  }
}


main() {
  WidgetsFlutterBinding.ensureInitialized();
  RoutinedataList _routinedata;
  RoutineRepository.loadRoutinedata().then((value) {
    _routinedata = value;
    print(_routinedata.routinedatas[0].exercises[0].sets[0].ischecked);
    _routinedata.routinedatas[0].exercises[0].sets[0].ischecked=true;


    print(_routinedata.routinedatas[0].exercises[0].sets[0].ischecked);
  });
}
