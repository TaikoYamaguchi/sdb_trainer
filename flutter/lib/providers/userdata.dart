import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/user_repository.dart';

class UserdataProvider extends ChangeNotifier {
  var _userdata;
  get userdata => _userdata;

  getdata() {
    UserService.loadUserdata().then((value) {
      _userdata = value;
      notifyListeners();
    });

  }

}