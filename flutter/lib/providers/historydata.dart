import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/history_repository.dart';

class HistorydataProvider extends ChangeNotifier {
  var _historydata;
  var _historydataAll;
  get historydata => _historydata;
  get historydataAll => _historydataAll;

  getdata() {
    ExerciseService.loadSDBdata().then((value) {
      _historydata = value;
      _historydataAll = value;
      notifyListeners();
    });
  }

  getHistorydataAll() {
    HistorydataAll.loadSDBdataAll().then((value) {
      _historydataAll = value;
      notifyListeners();
    });
  }

  getFriendsHistorydata(email) {
    HistorydataFriends(user_email: email).loadSDBdataFriends().then((value) {
      _historydataAll = value;
      notifyListeners();
    });
  }
}
