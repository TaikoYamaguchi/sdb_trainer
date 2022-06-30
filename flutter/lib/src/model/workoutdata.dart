import 'dart:convert';

import 'package:flutter/material.dart';




class Routinedatas {
  String name;
  List<Exercises> exercises;
  final double? routine_time;
  Routinedatas(
      {
      required this.name,
      required this.exercises,
      required this.routine_time});

  Map toJson() => {"name": name, "exercises": exercises, "routine_time": routine_time};

  factory Routinedatas.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'].runtimeType == String
        ? json.decode(parsedJson['exercises']) as List
        : parsedJson['exercises'] as List;
    List<Exercises> exerciseList =
        list.map((i) => Exercises.fromJson(i)).toList();
    return Routinedatas(
        name: parsedJson['name'],
        exercises: exerciseList,
        routine_time: parsedJson["routine_time"]);
  }
}

class Routinedata {
  final int id;
  final String user_email;
  final List<Routinedatas> routinedatas;
  final String? date;
  Routinedata({
    required this.id,
    required this.user_email,
    required this.routinedatas,
    required this.date,
  });

  factory Routinedata.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['routinedatas'].runtimeType == String
        ? json.decode(parsedJson['routinedatas']) as List
        : parsedJson['routinedatas'] as List;
    List<Routinedatas> routinedatas = list.map((i) => Routinedatas.fromJson(i)).toList();

    return Routinedata(
      id: parsedJson["id"],
      user_email: parsedJson['user_email'],
      routinedatas: routinedatas,
      date: parsedJson["date"],
    );
  }
}


class Exercises {
  final String name;
  final List<Sets> sets;
  final double? onerm;
  int rest;
  Exercises(
      {required this.name,
      required this.sets,
      required this.onerm,
      required this.rest});

  Map toJson() => {"name": name, "sets": sets, "onerm": onerm, "rest": rest};
  factory Exercises.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["sets"] as List;
    List<Sets> setList = list.map((i) => Sets.fromJson(i)).toList();
    return Exercises(
        name: parsedJson["name"],
        sets: setList,
        onerm: parsedJson["onerm"],
        rest: parsedJson["rest"]);
  }
}



class Sets {
  final int index;
  double weight;
  int reps;
  bool? ischecked;
  Sets(
      {required this.index,
      required this.weight,
      required this.reps,
      required this.ischecked});
  Map toJson() => {"index": index, "weight": weight, "reps": reps, "ischecked": ischecked};
  factory Sets.fromJson(Map<String, dynamic> parsedJson) {
    return Sets(
      index: parsedJson["index"],
      weight: parsedJson["weight"],
      reps: parsedJson["reps"],
      ischecked: parsedJson["ischecked"],
    );
  }
}

class Setslist {
  List<Sets> setslist = [
  Sets(index:0, weight: 0.0, reps: 1 , ischecked: false),
  Sets(index:1, weight: 0.0, reps: 1 , ischecked: false),
  Sets(index:2, weight: 0.0, reps: 1 , ischecked: false)
];
}

class Controllerlist {
  List<TextEditingController> controllerlist = [];
}
