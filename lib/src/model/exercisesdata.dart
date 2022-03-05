class Exercisesdata {
  final int id;
  final String user_email;
  final List<Exercises> exercises;
  final String? date;
  final int modified_number;
  Exercisesdata(
      {required this.id,
        required this.user_email,
        required this.exercises,
        required this.date,
        required this.modified_number,
      });

  factory Exercisesdata.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'] as List;
    List<Exercises> exerciseList =
    list.map((i) => Exercises.fromJson(i)).toList();
    return new Exercisesdata(
        id: parsedJson['id'],
        user_email: parsedJson['user_email'],
        exercises: exerciseList,
        date: parsedJson["date"],
        modified_number: parsedJson["modified_number"],);
  }


}

class Exercises {
  final String name;
  final double onerm;
  final double goal;
  Exercises({required this.name, required this.onerm, required this.goal});

  factory Exercises.fromJson(Map<String, dynamic> parsedJson) {
    return Exercises(
        name: parsedJson["name"], onerm: parsedJson["onerm"], goal: parsedJson["goal"]);
  }
}