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

}
