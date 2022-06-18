import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/user_repository.dart';

class UserdataProvider extends ChangeNotifier {
  var _userdata;
  var _userKakaoEmail;
  var _userKakaoName;
  var _userKakaoImage;
  var _userKakaoGender;
  var _userFriends;
  var _userFriendsAll;
  var _userFeedData;
  get userdata => _userdata;
  get userKakaoEmail => _userKakaoEmail;
  get userKakaoName => _userKakaoName;
  get userKakaoImage => _userKakaoImage;
  get userKakaoGender => _userKakaoGender;
  get userFriends => _userFriends;
  get userFriendsAll => _userFriendsAll;
  get userFeedData => _userFeedData;

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

  getUsersFriendsAll() {
    print("caclacla");
    UserAll().getUsers().then((value) {
      _userFriendsAll = value;
      notifyListeners();
    });
  }

  getUserdata(email) {
    UserInfo(userEmail: email).getUserByEmail().then((value) {
      _userFeedData = value;
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

  patchUserLikedata(User, status) {
    if (status == "remove") {
      _userdata.like.remove(User.email);
      _userFriends.userdatas
          .removeAt(_userFriends.userdatas.indexWhere((userdata) {
        if (userdata.email == User.email) {
          return true;
        } else {
          return false;
        }
      }));
      notifyListeners();
    } else if (status == "append") {
      _userdata.like.add(User.email);
      notifyListeners();
      _userFriends.userdatas.add(User);
      notifyListeners();
    }
  }
}
