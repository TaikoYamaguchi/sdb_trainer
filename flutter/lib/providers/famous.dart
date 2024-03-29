import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';

class FamousdataProvider extends ChangeNotifier {
  var _famousdata;
  get famousdata => _famousdata;
  var _download;
  get download => _download;
  var _week = 0;
  get week => _week;
  List<String> _tags = ['기타'];
  get tags => _tags;
  var _plantempweight;
  get plantempweight => _plantempweight;
  var _plantempweightRatio;
  get plantempweightRatio => _plantempweightRatio;
  var _plantempreps;
  get plantempreps => _plantempreps;

  weekchangepre(index) {
    _week = index;
    _download.routinedata.exercises[0].progress = index * 7;
  }

  settags(item) {
    _tags = item;
    notifyListeners();
  }

  emptytags() {
    _tags = [];
  }

  weekchange(index) {
    _week = index;
    _download.routinedata.exercises[0].progress = index * 7;
    notifyListeners();
  }

  downloadset(program) {
    _download = program;
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
