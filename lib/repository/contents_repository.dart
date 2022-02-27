class ContentsRepository {
  Map<String, dynamic> datas2 = {
    "벤치프레스": [
      {
        "1rm": 120,
        "unit": "kg",
        "goal": 130,
        "rest": "1min"
      },
      {
        "weight": 90,
        "reps": 10,
      },
      {
        "weight": 90,
        "reps": 10,
      },
      {
        "weight": 90,
        "reps": 10,
      },
    ],
    "스쿼트": [
      {
        "1rm": 120,
        "unit": "kg",
        "goal": 130,
        "rest": "30sec"
      },
      {
        "weight": 80,
        "reps": 10,
      },
      {
        "weight": 90,
        "reps": 10,
      },
      {
        "weight": 90,
        "reps": 10,
      },
    ],
    "숄더프레스": [
      {
        "1rm": 120,
        "unit": "kg",
        "goal": 130,
        "rest": "1min 30sec"
      },
      {
        "weight": 80,
        "reps": 10,
      }
    ],
    "밀리터리 프레스": [
      {
        "1rm": "no data",
        "unit": "kg",
        "goal": 0,
      },
    ],
    "파워레그프레스": [
      {
        "1rm": "no data",
        "unit": "kg",
        "goal": 0,
      },
    ],
    "레그익스텐션": [
      {
        "1rm": "no data",
        "unit": "kg",
        "goal": 0,
      },
    ],
  };
  Future<Map<String, dynamic >> loadContentsFromLocation() async {
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
    return datas2;
  }
}

