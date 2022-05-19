import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/history_repository.dart';

class HistorydataProvider extends ChangeNotifier {
  var _historydata;
  get historydata => _historydata;

  getdata() {
    ExerciseService.loadSDBdata().then((value) {
      _historydata = value;
      notifyListeners();
    });
  }
}
