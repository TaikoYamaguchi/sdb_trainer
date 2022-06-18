import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/history_repository.dart';

class HistorydataProvider extends ChangeNotifier {
  var _historydata;
  var _historydataAll;
  var _historydataFriends;
  get historydata => _historydata;
  get historydataAll => _historydataAll;
  get historydataFriends => _historydataFriends;

  getdata() {
    ExerciseService.loadSDBdata().then((value) {
      _historydata = value;

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
      _historydataFriends = value;
      notifyListeners();
    });
  }

  patchHistoryLikedata(SDBdata, email, status) {
    if (status == "remove") {
      _historydata.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.remove(email);
          return true;
        } else {
          return false;
        }
      });
      _historydataFriends.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.remove(email);
          return true;
        } else {
          return false;
        }
      });
      _historydataAll.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.remove(email);
          return true;
        } else {
          return false;
        }
      });
      notifyListeners();
    } else if (status == "append") {
      _historydata.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.add(email);
          return true;
        } else {
          return false;
        }
      });
      _historydataFriends.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.add(email);
          return true;
        } else {
          return false;
        }
      });
      _historydataAll.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.add(email);
          return true;
        } else {
          return false;
        }
      });
      notifyListeners();
    }
  }

  patchHistoryCommentdata(SDBdata, comment) {
    _historydata.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == SDBdata.id) {
        sdbdata.comment = comment;
        return true;
      } else {
        return false;
      }
    });
    _historydataFriends.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == SDBdata.id) {
        sdbdata.comment = comment;
        return true;
      } else {
        return false;
      }
    });
    _historydataAll.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == SDBdata.id) {
        sdbdata.comment = comment;
        return true;
      } else {
        return false;
      }
    });
    notifyListeners();
  }
}
