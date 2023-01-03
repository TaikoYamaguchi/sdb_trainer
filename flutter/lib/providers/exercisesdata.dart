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
  List<String> _tags = ['All'];
  get tags => _tags;
  List<String> _tags2 = ['All'];
  get tags2 => _tags2;

  List<String> options2 = [
    'All',
    '바벨',
    '덤벨',
    '머신',
    '맨몸',
    '유산소',
    '기타',
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

  putOnermValue(int index, double onerm) {
    _exercisesdata.exercises[index].onerm = onerm;
    notifyListeners();
  }

  putOnermGoalValue(int index, double onerm, double goal) {
    _exercisesdata.exercises[index].onerm = onerm;
    _exercisesdata.exercises[index].goal = goal;
    notifyListeners();
  }

  addExdata(Exercises) {
    _exercisesdata.exercises.add(Exercises);
    notifyListeners();
  }

  removeExdata(ueindex) {
    _exercisesdata.exercises.removeAt(ueindex);
    notifyListeners();
  }

  putHomeExList(exList) {
    _homeExList = exList;
    notifyListeners();
  }

  removeHomeExList(index) {
    _homeExList.removeAt(index);
    notifyListeners();
  }

  insertHomeExList(index, item) {
    _homeExList.insert(index, item);
    notifyListeners();
  }

  addHomeExList(item) {
    _homeExList.add(item);
    notifyListeners();
  }

  settags(item) {
    _tags = item;
    notifyListeners();
  }

  resettags() {
    _tags = ['All'];
    _tags2 = ['All'];
    notifyListeners();
  }

  settags2(item) {
    _tags2 = item;
    notifyListeners();
  }

  inittestdata() {
    _testdata = _exercisesdata.exercises;
    _testdata_s = _exercisesdata.exercises;
    _testdata_f1 = _exercisesdata.exercises;
    _testdata_f2 = _exercisesdata.exercises;
    notifyListeners();
  }

  settestdata(data) {
    _testdata = data;
    notifyListeners();
  }

  settestdata_d() {
    _testdata = _testdata
        .toSet()
        .intersection(_exercisesdata.exercises.toSet())
        .toList();
    notifyListeners();
  }

  settestdata_s(data) {
    _testdata_s = data;
    var commonElements = [_testdata_s, _testdata_f1, _testdata_f2].fold<Set>(
        [_testdata_s, _testdata_f1, _testdata_f2].first.toSet(),
        (a, b) => a.intersection(b.toSet()));
    settestdata(commonElements.toList());
  }

  settestdata_f1(data) {
    _testdata_f1 = data;
    var commonElements = [_testdata_s, _testdata_f1, _testdata_f2].fold<Set>(
        [_testdata_s, _testdata_f1, _testdata_f2].first.toSet(),
        (a, b) => a.intersection(b.toSet()));

    print(commonElements);
    settestdata(commonElements.toList());
  }

  settestdata_f2(data) {
    _testdata_f2 = data;
    var commonElements = [_testdata_s, _testdata_f1, _testdata_f2].fold<Set>(
        [_testdata_s, _testdata_f1, _testdata_f2].first.toSet(),
        (a, b) => a.intersection(b.toSet()));
    settestdata(commonElements.toList());
  }

  settesttotal(data, data1, data2) {
    _testdata_s = data;
    _testdata_f1 = data1;
    _testdata_f2 = data2;
    var commonElements = [_testdata_s, _testdata_f1, _testdata_f2].fold<Set>(
        [_testdata_s, _testdata_f1, _testdata_f2].first.toSet(),
        (a, b) => a.intersection(b.toSet()));
    settestdata(commonElements.toList());
  }

  setfiltmenu(num) {
    _filtmenu = num;
    notifyListeners();
  }
}
