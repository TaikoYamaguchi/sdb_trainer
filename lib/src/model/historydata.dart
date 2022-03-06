class SDBdata {
  final int id;
  final String user_email;
  final List<Exercises> exercises;
  final String? date;
  final int new_record;
  final int workout_time;
  SDBdata(
      {required this.id,
      required this.user_email,
      required this.exercises,
      required this.date,
      required this.new_record,
      required this.workout_time});

  factory SDBdata.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'] as List;
    List<Exercises> exerciseList =
        list.map((i) => Exercises.fromJson(i)).toList();
    return SDBdata(
        id: parsedJson['id'],
        user_email: parsedJson['user_email'],
        exercises: exerciseList,
        date: parsedJson["date"],
        new_record: parsedJson["new_record"],
        workout_time: parsedJson["workout_time"]);
  }
}

class Exercises {
  final String name;
  final List<Sets> sets;
  final double onerm;
  final double goal;
  Exercises(
      {required this.name,
      required this.sets,
      required this.onerm,
      required this.goal});

  factory Exercises.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["sets"] as List;
    List<Sets> setList = list.map((i) => Sets.fromJson(i)).toList();
    return Exercises(
        name: parsedJson["name"],
        sets: setList,
        onerm: parsedJson["onerm"],
        goal: parsedJson["goal"]);
  }
}

class SDBdataList {
  final List<SDBdata> sdbdatas;

  SDBdataList({
    required this.sdbdatas,
  });

  factory SDBdataList.fromJson(List<dynamic> parsedJson) {
    List<SDBdata> sdbdatas = <SDBdata>[];
    sdbdatas = parsedJson.map((i) => SDBdata.fromJson(i)).toList();

    return new SDBdataList(sdbdatas: sdbdatas);
  }
}

class Sets {
  final int index;
  final double weight;
  final int reps;
  Sets({required this.index, required this.weight, required this.reps});
  factory Sets.fromJson(Map<String, dynamic> parsedJson) {
    return Sets(
        index: parsedJson["index"],
        weight: parsedJson["weight"],
        reps: parsedJson["reps"]);
  }
}
