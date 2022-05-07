import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/user_repository.dart';

class UserdataProvider extends ChangeNotifier {
  var _userdata;
  var _userKakaoEmail;
  get userdata => _userdata;
  get userKakaoEmail => _userKakaoEmail;

  getdata() {
    UserService.loadUserdata().then((value) {
      _userdata = value;
      notifyListeners();
    });
  }

  setUserKakaoEmail(state) {
    _userKakaoEmail = state;
    notifyListeners();
  }
}
