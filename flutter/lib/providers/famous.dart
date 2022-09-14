import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/comment_repository.dart';

class FamousdataProvider extends ChangeNotifier {
  var _famousdata;
  get famousdata => _famousdata;
  var _download;
  get download => _download;
  var _week=0;
  get week => _week;

  weekchangepre(index) {
    _week = index;
    _download.routinedata.exercises[0].progress = index*7;
  }

  weekchange(index) {
    _week = index;
    _download.routinedata.exercises[0].progress = index*7;
    notifyListeners();
  }

  downloadset(program) {
    _download = program;
    print(download);
    notifyListeners();
  }

  progresschange(progress) {
    _download.routinedata.exercises[0].progress = progress;

    notifyListeners();
  }

  getdata() {
    FamousRepository.loadFamousdata().then((value) {
      _famousdata = value;
      notifyListeners();
    });
  }

  patchFamousLikedata(Fdata, email, status) {
    if (status == "remove") {
      _famousdata.famouss.indexWhere((fdata) {
        if (fdata.id == Fdata.id) {
          fdata.like.remove(email);
          return true;
        } else {
          return false;
        }
      });
      notifyListeners();
    } else if (status == "append") {
      _famousdata.famouss.indexWhere((fdata) {
        if (fdata.id == Fdata.id) {
          fdata.like.add(email);
          return true;
        } else {
          return false;
        }
      });
      notifyListeners();
    }
  }

}
