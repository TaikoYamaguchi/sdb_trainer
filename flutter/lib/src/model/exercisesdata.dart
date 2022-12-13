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
    return new Exercisesdata(
      id: parsedJson['id'],
      user_email: parsedJson['user_email'],
      exercises: exerciseList,
      date: parsedJson["date"],
      modified_number: parsedJson["modified_number"],
    );
  }
}

Map extg = {
  '벤치프레스': ['가슴', '삼두'],
  '스쿼트': ['다리'],
  '데드리프트': ['다리', '등', '허리'],
  '밀리터리프레스': ['어깨', '삼두'],
  '체스트프레스': ['가슴', '삼두'],
  '오버헤드프레스': ['어깨', '삼두'],
  '벤트오버바벨로우': ['등', '이두'],
  '풀업': ['등', '이두'],
  '바벨컬': ['이두'],
  '덤벨컬': ['이두'],
  '카프레이즈': ['다리'],
  '치닝': ['등', '이두'],
  '딥스': ['가슴', '삼두'],
  '디클라인벤치프레스': ['가슴', '삼두'],
  '인클라인벤치프레스': ['가슴', '삼두'],
  '랫풀다운': ['등', '이두'],
  '레그프레스': ['다리'],
  '파워레그프레스': ['다리'],
  '레그컬': ['다리'],
  '레그익스텐션': ['다리'],
  '행잉레그레이즈': ['복근'],
  '덤벨로우': ['등', '이두'],
  '사이드래터럴레이즈': ['어깨'],
  '프론트래터럴레이즈': ['어깨'],
  '리어델토이드플라이': ['어깨'],
  '체스트플라이': ['가슴'],
  '뎀벨플라이': ['가슴'],
  '프론트스쿼트': ['다리'],
  '숄더프레스': ['어깨', '삼두'],
  '케이블플라이': ['가슴'],
  '케이블풀다운': ['등'],
  '케이블바이셉스컬': ['이두'],
  '케이블푸시다운': ['삼두'],
  '케이블로우': ['등', '이두'],
  '백익스텐션': ['허리'],
  '머슬업': ['등', '이두'],
  '티바로우': ['등', '이두'],
  '펜들레이로우': ['등', '이두'],
  '덤벨프레스': ['가슴', '삼두'],
  '인클라인덤벨프레스': ['가슴', '삼두'],
  '런지': ['다리'],
  '디클라인덤벨프레스': ['가슴', '삼두'],
  '인클라인체스트프레스': ['가슴', '삼두'],
  '디클라인체스트프레스': ['가슴', '삼두'],
  '덤벨킥백': ['삼두']
};

Map excate = {
  '벤치프레스': '바벨',
  '스쿼트': '바벨',
  '데드리프트': '바벨',
  '밀리터리프레스': '바벨',
  '체스트프레스': '머신',
  '오버헤드프레스': '바벨',
  '벤트오버바벨로우': '바벨',
  '풀업': '맨몸',
  '바벨컬': '바벨',
  '덤벨컬': '덤벨',
  '카프레이즈': '맨몸',
  '치닝': '맨몸',
  '딥스': '맨몸',
  '디클라인벤치프레스': '바벨',
  '인클라인벤치프레스': '바벨',
  '랫풀다운': '머신',
  '레그프레스': '머신',
  '파워레그프레스': '머신',
  '레그컬': '머신',
  '레그익스텐션': '머신',
  '행잉레그레이즈': '맨몸',
  '덤벨로우': '덤벨',
  '사이드래터럴레이즈': '덤벨',
  '프론트래터럴레이즈': '덤벨',
  '리어델토이드플라이': '머신',
  '체스트플라이': '머신',
  '뎀벨플라이': '덤벨',
  '프론트스쿼트': '바벨',
  '숄더프레스': '머신',
  '케이블플라이': '머신',
  '케이블풀다운': '머신',
  '케이블바이셉스컬': '머신',
  '케이블푸시다운': '머신',
  '케이블로우': '머신',
  '백익스텐션': '맨몸',
  '머슬업': '맨몸',
  '티바로우': '머신',
  '펜들레이로우': '바벨',
  '덤벨프레스': '덤벨',
  '인클라인덤벨프레스': '덤벨',
  '런지': '맨몸',
  '디클라인덤벨프레스': '덤벨',
  '인클라인체스트프레스': '머신',
  '디클라인체스트프레스': '머신',
  '덤벨킥백': '덤벨'
};

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
  '케이블푸시다운': '트라이셉스 다운',
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
      name: parsedJson["custom"] == false
          ? namechange[parsedJson["name"]]
          : parsedJson["name"],
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
