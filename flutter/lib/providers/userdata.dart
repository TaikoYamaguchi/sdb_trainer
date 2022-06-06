import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/user_repository.dart';

class UserdataProvider extends ChangeNotifier {
  var _userdata;
  var _userKakaoEmail;
  var _userKakaoName;
  var _userKakaoImage;
  var _userKakaoGender;
  var _userFriends;
  get userdata => _userdata;
  get userKakaoEmail => _userKakaoEmail;
  get userKakaoName => _userKakaoName;
  get userKakaoImage => _userKakaoImage;
  get userKakaoGender => _userKakaoGender;
  get userFriends => _userFriends;

  getdata() {
    UserService.loadUserdata().then((value) {
      _userdata = value;
      notifyListeners();
    });
  }

  getFriendsdata(email) {
    UserLikeFriends(user_email: email).getUserLikeFriends().then((value) {
      _userFriends = value;
      notifyListeners();
    });
  }

  setUserKakaoEmail(state) {
    _userKakaoEmail = state;
    notifyListeners();
  }

  setUserKakaoImageUrl(state) {
    _userKakaoImage = state;
    notifyListeners();
  }

  setUserKakaoName(state) {
    _userKakaoName = state;
    notifyListeners();
  }

  setUserKakaoGender(state) {
    if (state.toString() == "Gender.male") {
      print(state);
      print("male");
      _userKakaoGender = true;
    } else {
      print("female");
      _userKakaoGender = false;
    }
    notifyListeners();
  }
}
