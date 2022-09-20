import 'dart:convert';

class ExercisesdataList {
  final List<Exercisesdata> exercisedatas;

  ExercisesdataList({
    required this.exercisedatas,
  });
  Map toJson() => {'exercisedatas' :exercisedatas};

  factory ExercisesdataList.fromJson(List<dynamic> parsedJson) {
    List<Exercisesdata> exercisedatas = <Exercisesdata>[];
    exercisedatas = parsedJson.map((i) => Exercisesdata.fromJson(i)).toList();

    return new ExercisesdataList(exercisedatas: exercisedatas);
  }
}

class Exercisesdata {
  late int? id;
  late String user_email;
  late List<Exercises> exercises;
  late String? date;
  late int? modified_number;
  Exercisesdata({
    this.id,
    required this.user_email,
    required this.exercises,
    this.date,
    this.modified_number,
  });
  Map toJson() => {"id": id, "user_email": user_email, "exercises": exercises, "date": date, "modified_number": modified_number};

  factory Exercisesdata.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'].runtimeType == String
        ? json.decode(parsedJson['exercises']) as List
        : parsedJson['exercises'] as List;
    List<Exercises> exerciseList =
        list.map((i) => Exercises.fromJson(i)).toList();
    return new Exercisesdata(
      id: parsedJson['id'],
      user_email: parsedJson['user_email'],
      exercises: exerciseList,
      date: parsedJson["date"],
      modified_number: parsedJson["modified_number"],
    );
  }
}

class Exercises {
  late String name;
  late double onerm;
  late double goal;
  late bool? custom;

  Exercises({
    required this.name,
    required this.onerm,
    required this.goal,
    this.custom
  });
  Map toJson() => {"goal": goal, "name": name, "onerm": onerm, "custom": custom};

  factory Exercises.fromJson(Map<String, dynamic> parsedJson) {

    return Exercises(
        name: parsedJson["name"],
        onerm: parsedJson["onerm"],
        goal: parsedJson["goal"],
        custom: parsedJson["custom"] == null ? false :parsedJson["custom"]
    );
  }
}

