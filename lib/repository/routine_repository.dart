class RoutineRepository {
  Map<String, dynamic> routine = {
    "id": 1,
    "created_email": "cksdnr1@gmail.com",
    "name": "타격감운동",
    "exercises": [
      {
        "name": "벤치프레스",
        "sets": [
          {"index": 1, "weight": 105, "reps": 1},
          {"index": 2, "weight": 110, "reps": 1},
          {"index": 3, "weight": 85, "reps": 10}
        ],
        "1rm": 115,
        "rest": 180
      },
      {
        "name": "스쿼트",
        "sets": [
          {"index": 1, "weight": 120, "reps": 1},
          {"index": 2, "weight": 130, "reps": 1},
          {"index": 3, "weight": 100, "reps": 6},
          {"index": 4, "weight": 80, "reps": 10},
        ],
        "1rm": 140,
        "rest": 240
      },
      {
        "name": "데드리프트",
        "sets": [
          {"index": 1, "weight": 80, "reps": 1},
          {"index": 2, "weight": 100, "reps": 1},
          {"index": 3, "weight": 120, "reps": 1},
          {"index": 4, "weight": 140, "reps": 1},
          {"index": 5, "weight": 160, "reps": 1},
          {"index": 6, "weight": 130, "reps": 10},
        ],
        "1rm": 180,
        "rest": 240
      },
    ],
    "date": "2022-02-27",
    "routine_time": 60
  };
  Future<Map<String, dynamic>> loadContentsFromLocation() async {
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
    return routine;
  }
}
