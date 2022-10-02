import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';

class ExercisesdataProvider extends ChangeNotifier {
  var _exercisesdata;
  get exercisesdata => _exercisesdata;
  var _testdata;
  get testdata => _testdata;
  var _testdata_s;
  get testdata_s => _testdata_s;
  var _testdata_f1;
  get testdata_f1 => _testdata_f1;
  var _testdata_f2;
  get testdata_f2 => _testdata_f2;
  int _filtmenu = 1;
  get filtmenu => _filtmenu;
  var _exercisesdatas;
  get exercisesdatas => _exercisesdatas;
  var _homeExList;
  get homeExList => _homeExList;
  List<String> _tags =['All'];
  get tags => _tags;
  List<String> _tags2 = ['All'];
  get tags2 => _tags2;

  List<String> options2 = [
    'All',
    '바벨',
    '덤벨',
    '머신',
  ];
  List<String> options = [
    'All',
    '가슴',
    '삼두',
    '등',
    '이두',
    '어깨',
    '다리',
    '복근',
    '유산소',
    '전완근',
    '둔근',
    '기타',
  ];


  getdata() async {
    await ExercisesRepository.loadExercisesdata().then((value) {
      _exercisesdata = value;
      notifyListeners();
    });
  }

  getdata_all() async {
    await ExercisesRepository.loadExercisesdataAll().then((value) {
      _exercisesdatas = value;
      notifyListeners();
    });
  }

  addExdata(Exercises) {
    _exercisesdata.exercises.add(Exercises);
    notifyListeners();
  }

  putHomeExList(exList) async {
    _homeExList = exList;
    notifyListeners();
  }

  removeHomeExList(index) async {
    _homeExList.removeAt(index);
    notifyListeners();
  }

  insertHomeExList(index, item) async {
    _homeExList.insert(index, item);
    notifyListeners();
  }

  addHomeExList(item) async {
    _homeExList.add(item);
    notifyListeners();
  }

  settags(item) async {
    _tags = item;
    notifyListeners();
  }

  settags2(item) async {
    _tags2 = item;
    notifyListeners();
  }

  inittestdata() async {
    _testdata = _exercisesdata.exercises;
    _testdata_s = _exercisesdata.exercises;
    _testdata_f1 = _exercisesdata.exercises;
    _testdata_f2 = _exercisesdata.exercises;
    notifyListeners();
  }

  settestdata(data) async {
    _testdata = data;
    notifyListeners();
  }

  settestdata_s(data) async {
    _testdata_s = data;
    final commonElements =
        [_testdata_s,_testdata_f1,_testdata_f2].fold<Set>(
            [_testdata_s,_testdata_f1,_testdata_f2].first.toSet(),
                (a, b) => a.intersection(b.toSet()));
    settestdata(commonElements.toList());
  }

  settestdata_f1(data) async {
    _testdata_f1 = data;
    final commonElements =
    [_testdata_s,_testdata_f1,_testdata_f2].fold<Set>(
        [_testdata_s,_testdata_f1,_testdata_f2].first.toSet(),
            (a, b) => a.intersection(b.toSet()));
    settestdata(commonElements.toList());
  }

  settestdata_f2(data) async {
    _testdata_f2 = data;
    final commonElements =
    [_testdata_s,_testdata_f1,_testdata_f2].fold<Set>(
        [_testdata_s,_testdata_f1,_testdata_f2].first.toSet(),
            (a, b) => a.intersection(b.toSet()));
    settestdata(commonElements.toList());
  }

  setfiltmenu(num) async {
    _filtmenu = num;
    notifyListeners();
  }

}
