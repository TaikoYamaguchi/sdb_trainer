import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/comment_repository.dart';

class FamousdataProvider extends ChangeNotifier {
  var _famousdata;
  get famousdata => _famousdata;


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
