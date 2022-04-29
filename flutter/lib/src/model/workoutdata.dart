import 'dart:convert';

class Routinedata {
  final int id;
  final String user_email;
  final String name;
  final List<Exercises> exercises;
  final String? date;
  final double? routine_time;
  Routinedata(
      {required this.id,
      required this.user_email,
      required this.name,
      required this.exercises,
      required this.date,
      required this.routine_time});

  factory Routinedata.fromJson(Map<String, dynamic> parsedJson) {

    var list = parsedJson['exercises'].runtimeType == String
        ? json.decode(parsedJson['exercises']) as List
        : parsedJson['exercises'] as List;

    List<Exercises> exerciseList =
        list.map((i) => Exercises.fromJson(i)).toList();
    return Routinedata(
        id: parsedJson['id'],
        user_email: parsedJson['user_email'],
        name: parsedJson['name'],
        exercises: exerciseList,
        date: parsedJson["date"],
        routine_time: parsedJson["routine_time"]);
  }
}

class Exercises {
  final String name;
  final List<Sets> sets;
  final double? onerm;
  final int rest;
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

class RoutinedataList {
  final List<Routinedata> routinedatas;

  RoutinedataList({
    required this.routinedatas,
  });

  factory RoutinedataList.fromJson(List<dynamic> parsedJson) {
    List<Routinedata> routinedatas = <Routinedata>[];
    routinedatas = parsedJson.map((i) => Routinedata.fromJson(i)).toList();

    return new RoutinedataList(routinedatas: routinedatas);
  }
}

class Sets {
  final int index;
  double? weight;
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

