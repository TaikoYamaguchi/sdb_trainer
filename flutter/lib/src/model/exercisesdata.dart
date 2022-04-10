import 'dart:convert';

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

  factory Exercisesdata.fromJson(Map<String, dynamic> parsedJson) {
    print(parsedJson);
    print(parsedJson['exercises']);
    var list = parsedJson['exercises'].runtimeType == String
        ? json.decode(parsedJson['exercises']) as List
        : parsedJson['exercises'] as List;
    print(list);
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
  Exercises({required this.name, required this.onerm, required this.goal});
  Map toJson() => {"goal": goal, "name": name, "onerm": onerm};

  factory Exercises.fromJson(Map<String, dynamic> parsedJson) {
    return Exercises(
        name: parsedJson["name"],
        onerm: parsedJson["onerm"],
        goal: parsedJson["goal"]);
  }
}
