import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

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
    List<Routinedatas> routinedatas =
        list.map((i) => Routinedatas.fromJson(i)).toList();

    return Routinedata(
      id: parsedJson["id"],
      user_email: parsedJson['user_email'],
      routinedatas: routinedatas,
      date: parsedJson["date"],
    );
  }
}

class FamousList {
  final List<Famous> famouss;

  FamousList({
    required this.famouss,
  });

  factory FamousList.fromJson(List<dynamic> parsedJson) {
    List<Famous> famouss = <Famous>[];
    famouss = parsedJson.map((i) => Famous.fromJson(i)).toList();

    return new FamousList(famouss: famouss);
  }
}

class Famous {
  final int id;
  final int type;
  final String user_email;
  final String image;
  final Routinedatas routinedata;
  final String? date;
  final List<dynamic> like;
  final List<dynamic> dislike;
  final int level;
  final int subscribe;
  final int category;

  Famous({
    required this.id,
    required this.type,
    required this.user_email,
    required this.image,
    required this.routinedata,
    required this.date,
    required this.like,
    required this.dislike,
    required this.level,
    required this.subscribe,
    required this.category,
  });

  factory Famous.fromJson(Map<String, dynamic> parsedJson) {
    return new Famous(
      id: parsedJson["id"],
      type: parsedJson["type"],
      user_email: parsedJson["user_email"],
      image: parsedJson['image'],
      routinedata: Routinedatas.fromJson(parsedJson['routinedata']),
      date: parsedJson["date"],
      like: parsedJson["like"],
      dislike: parsedJson["dislike"],
      level: parsedJson["level"],
      subscribe: parsedJson["subscribe"],
      category: parsedJson["category"],
    );
  }
}

class Routinedatas {
  String name;
  int mode;
  List exercises;
  var routine_time;
  Routinedatas(
      {required this.name,
      required this.mode,
      required this.exercises,
      required this.routine_time});

  Map toJson() => {
        "name": name,
        "mode": mode,
        "exercises": exercises,
        "routine_time": routine_time
      };

  factory Routinedatas.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'].runtimeType == String
        ? json.decode(parsedJson['exercises']) as List
        : parsedJson['exercises'] as List;
    List exerciseList = parsedJson['mode'] == 0
        ? list.map((i) => Exercises.fromJson(i)).toList()
        : list.map((i) => Program.fromJson(i)).toList();

    return Routinedatas(
        name: parsedJson['name'],
        mode: parsedJson['mode'],
        exercises: exerciseList,
        routine_time: parsedJson["routine_time"]);
  }
}

class Program {
  int progress;
  List<Plans> plans;
  Program({
    required this.progress,
    required this.plans,
  });

  Map toJson() => {"progress": progress, "plans": plans};
  factory Program.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["plans"] as List;
    List<Plans> planList = list.map((i) => Plans.fromJson(i)).toList();
    return Program(
      progress: parsedJson['progress'],
      plans: planList,
    );
  }
}

class Plans {
  List<Plan_Exercises> exercises;
  Plans({
    required this.exercises,
  });

  Map toJson() => {"exercises": exercises};
  factory Plans.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["exercises"] as List;
    List<Plan_Exercises> exerciseList =
        list.map((i) => Plan_Exercises.fromJson(i)).toList();
    return Plans(
      exercises: exerciseList,
    );
  }
}

class Plan_Exercises {
  String name;
  String ref_name;
  final List<Sets> sets;
  int rest;
  Plan_Exercises(
      {required this.name,
      required this.ref_name,
      required this.sets,
      required this.rest});

  Map toJson() =>
      {"name": name, "ref_name": ref_name, "sets": sets, "rest": rest};
  factory Plan_Exercises.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["sets"] as List;
    List<Sets> setList = list.map((i) => Sets.fromJson(i)).toList();
    return Plan_Exercises(
        name: parsedJson["name"],
        ref_name: parsedJson["ref_name"],
        sets: setList,
        rest: parsedJson["rest"]);
  }
}

class Exercises {
  final String name;
  final List<Sets> sets;
  int rest;
  Exercises({required this.name, required this.sets, required this.rest});

  Map toJson() => {"name": name, "sets": sets, "rest": rest};
  factory Exercises.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["sets"] as List;
    List<Sets> setList = list.map((i) => Sets.fromJson(i)).toList();
    return Exercises(
        name: parsedJson["name"], sets: setList, rest: parsedJson["rest"]);
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
  Map toJson() =>
      {"index": index, "weight": weight, "reps": reps, "ischecked": ischecked};
  factory Sets.fromJson(Map<String, dynamic> parsedJson) {
    return Sets(
      index: parsedJson["index"],
      weight: parsedJson["weight"].toDouble(),
      reps: parsedJson["reps"],
      ischecked: parsedJson["ischecked"],
    );
  }
}

class Setslist {
  List<Sets> setslist = [
    Sets(index: 0, weight: 0.0, reps: 1, ischecked: false),
    Sets(index: 1, weight: 0.0, reps: 1, ischecked: false),
    Sets(index: 2, weight: 0.0, reps: 1, ischecked: false)
  ];
}

class Controllerlist {
  List<TextEditingController> controllerlist = [];
}

class FamousControllerlist {
  List<JustTheController> controllerlist = [];
}
