import 'dart:convert';

class ExercisesdataList {
  final List<Exercisesdata> exercisedatas;

  ExercisesdataList({
    required this.exercisedatas,
  });
  Map toJson() => {'exercisedatas': exercisedatas};

  factory ExercisesdataList.fromJson(List<dynamic> parsedJson) {
    List<Exercisesdata> exercisedatas = <Exercisesdata>[];
    exercisedatas = parsedJson.map((i) => Exercisesdata.fromJson(i)).toList();

    return ExercisesdataList(exercisedatas: exercisedatas);
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
  Map toJson() => {
        "id": id,
        "user_email": user_email,
        "exercises": exercises,
        "date": date,
        "modified_number": modified_number
      };

  factory Exercisesdata.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'].runtimeType == String
        ? json.decode(parsedJson['exercises']) as List
        : parsedJson['exercises'] as List;
    List<Exercises> exerciseList =
        list.map((i) => Exercises.fromJson(i)).toList();
    return Exercisesdata(
      id: parsedJson['id'],
      user_email: parsedJson['user_email'],
      exercises: exerciseList,
      date: parsedJson["date"],
      modified_number: parsedJson["modified_number"],
    );
  }
}

Map namechange = {
  '스쿼트': '바벨 스쿼트',
  '데드리프트': '바벨 데드리프트',
  '벤치프레스': '바벨 벤치 프레스',
  '밀리터리프레스': '밀리터리 프레스',
  '체스트프레스': '체스트 프레스',
  '오버헤드프레스': '바벨 숄더 프레스',
  '벤트오버바벨로우': '벤트 오버 바벨 로우',
  '풀업': '풀업',
  '바벨컬': '바벨 컬',
  '덤벨컬': '덤벨 컬',
  '카프레이즈': '스탠딩 카프 레이즈',
  '치닝': '친업',
  '딥스': '딥스',
  '디클라인벤치프레스': '디클라인 바벨 벤치 프레스',
  '인클라인벤치프레스': '인클라인 바벨 벤치 프레스',
  '랫풀다운': '랫 풀다운',
  '레그프레스': '레그 프레스',
  '파워레그프레스': '파워 레그 프레스',
  '레그컬': '레그 컬',
  '레그익스텐션': '레그 익스텐션',
  '행잉레그레이즈': '행잉 레그 레이즈',
  '덤벨로우': '벤트 오버 덤벨 로우',
  '사이드래터럴레이즈': '덤벨 사이드 래터럴 레이즈',
  '프론트래터럴레이즈': '덤벨 프론트 래터럴 레이즈',
  '리어델토이드플라이': '리어 델트 플라이',
  '체스트플라이': '체스트 플라이',
  '뎀벨플라이': '뎀벨 플라이',
  '프론트스쿼트': '바벨 프론트 스쿼트',
  '숄더프레스': '덤벨 숄더 프레스',
  '케이블플라이': '케이블 플라이',
  '케이블풀다운': '케이블 스트레이트 암 풀다운',
  '케이블바이셉스컬': '케이블 컬',
  '트라이셉스 다운': '트라이셉스 푸쉬다운',
  '케이블로우': '시티드 케이블 로우',
  '백익스텐션': '백 익스텐션',
  '머슬업': '머슬업',
  '티바로우': 'T바 로우',
  '펜들레이로우': '펜들레이 로우',
  '덤벨프레스': '덤벨 벤치 프레스',
  '인클라인덤벨프레스': '인클라인 덤벨 벤치 프레스',
  '런지': '런지',
  '디클라인덤벨프레스': '디클라인 덤벨 벤치 프레스',
  '인클라인체스트프레스': '인클라인 체스트 프레스',
  '디클라인체스트프레스': '디클라인 체스트 프레스',
  '덤벨킥백': '덤벨 킥 백',
  '러닝': '러닝',
};

class Exercises {
  late String name;
  late double? onerm;
  late double? goal;
  late bool? custom;
  late List? target;
  late String? category;
  late String? image;
  late String? note;

  Exercises({
    required this.name,
    required this.onerm,
    required this.goal,
    required this.custom,
    required this.target,
    required this.category,
    required this.image,
    required this.note,
  });
  Map toJson() => {
        "goal": goal,
        "name": name,
        "onerm": onerm,
        "custom": custom,
        "target": target,
        "category": category,
        "image": image,
        "note": note
      };

  factory Exercises.fromJson(Map<String, dynamic> parsedJson) {
    return Exercises(
      name: parsedJson["name"],
      onerm: parsedJson["onerm"].toDouble(),
      goal: parsedJson["goal"].toDouble(),
      custom: parsedJson["custom"],
      target: parsedJson["target"],
      category: parsedJson["category"],
      image: parsedJson["image"],
      note: parsedJson["note"],
    );
  }
}

class ExImage {
  Map body_part_image = {
    '가슴': 'assets/png/chest.png',
    '삼두': 'assets/png/triceps.png',
    '등': 'assets/png/back.png',
    '이두': 'assets/png/biceps.png',
    '어깨': 'assets/png/shoulder.png',
    '다리': 'assets/png/leg.png',
    '복근': 'assets/png/core.png',
    '전완근': 'assets/png/forearm.png',
    '둔근': 'assets/png/glute.png',
    '유산소': 'assets/png/cardio.png',
    '기타': 'assets/png/etc.png',
    'All': 'assets/png/all.png',
  };
}

class ExImageLight {
  Map body_part_image = {
    '가슴': 'assets/png/chests_light.png',
    '삼두': 'assets/png/triceps_light.png',
    '등': 'assets/png/back_light.png',
    '이두': 'assets/png/biceps_light.png',
    '어깨': 'assets/png/shoulders_light.png',
    '다리': 'assets/png/legs_light.png',
    '복근': 'assets/png/abs_light.png',
    '전완근': 'assets/png/forearms_light.png',
    '둔근': 'assets/png/glutes_light.png',
    '유산소': 'assets/png/cardio.png',
    '기타': 'assets/png/etc.png',
    'All': 'assets/png/all_light.png',
  };
}
