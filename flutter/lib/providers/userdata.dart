import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/userdata.dart';

class UserdataProvider extends ChangeNotifier {
  var _userdata;
  var _userKakaoEmail;
  var _userKakaoName;
  var _userKakaoImage;
  var _userKakaoGender;
  var _userFriends;
  var _userFriendsAll;
  var _userFeedData;
  var _userFontSize;
  get userdata => _userdata;
  get userKakaoEmail => _userKakaoEmail;
  get userKakaoName => _userKakaoName;
  get userKakaoImage => _userKakaoImage;
  get userKakaoGender => _userKakaoGender;
  get userFriends => _userFriends;
  get userFriendsAll => _userFriendsAll;
  get userFeedData => _userFeedData;
  get userFontSize => _userFontSize;

  getdata(token) async {
    try {
      await UserService(token: token).loadUserdata().then((value) {
        _userdata = value;
        notifyListeners();
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  setUserdata(user) {
    _userdata = user;
    notifyListeners();
  }

  getFriendsdata() {
    UserLikeFriends().getUserLikeFriends().then((value) {
      _userFriends = value;
      notifyListeners();
    });
  }

  getUsersFriendsAll() async {
    await UserAll().getUsers().then((value) {
      _userFriendsAll = value;

      notifyListeners();
    });
    return _userFriendsAll;
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

  setUserWeightAdd(date, weight, weightGoal) {
    _userdata.bodyStats.add(BodyStat(
        date: date,
        weight: weight,
        weight_goal: weightGoal,
        height: _userdata.bodyStats.last.height,
        height_goal: _userdata.bodyStats.last.height_goal));
    UserBodyStatEdit(bodyStat: _userdata.bodyStats).patchUserBodyStat();
    notifyListeners();
  }

  setUserWeightEdit(index, weight, weightGoal) {
    _userdata.bodyStats[index].weight = weight;
    _userdata.bodyStats[index].weight_goal = weightGoal;
    UserBodyStatEdit(bodyStat: _userdata.bodyStats).patchUserBodyStat();
    notifyListeners();
  }

  setUserWeightDelete(index) {
    _userdata.bodyStats.removeAt(index);
    UserBodyStatEdit(bodyStat: _userdata.bodyStats).patchUserBodyStat();
    notifyListeners();
  }

  setUserKakaoGender(state) {
    if (state.toString() == "Gender.male") {
      _userKakaoGender = true;
    } else if (state == null) {
      _userKakaoGender = null;
    } else if (state == true) {
      _userKakaoGender = true;
    } else if (state == false) {
      _userKakaoGender = false;
    } else {
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
      _userFriendsAll
          .userdatas[_userFriendsAll.userdatas.indexWhere((userdata) {
        if (userdata.email == User.email) {
          return true;
        } else {
          return false;
        }
      })]
          .liked
          .remove(userdata.email);

      notifyListeners();
    } else if (status == "append") {
      _userdata.like.add(User.email);
      notifyListeners();
      _userFriends.userdatas.add(User);
      _userFriendsAll
          .userdatas[_userFriendsAll.userdatas.indexWhere((userdata) {
        if (userdata.email == User.email) {
          return true;
        } else {
          return false;
        }
      })]
          .liked
          .add(userdata.email);

      notifyListeners();
    }
  }

  patchUserDislikedata(email, status) {
    if (status == "remove") {
      _userdata.dislike.remove(email);
      notifyListeners();
    } else if (status == "append") {
      _userdata.dislike.add(email);
      notifyListeners();
    }
  }

  Future<double> getUserFontsize() async {
    final storage = new FlutterSecureStorage();
    _userFontSize = 1.0;
    try {
      var _fontsize = await storage.read(key: "sdb_fontSize");
      if (_fontsize != null && _fontsize != "") {
        _userFontSize = double.parse(_fontsize);
        print(_fontsize);
        notifyListeners();
        return double.parse(_fontsize);
      } else {
        _userFontSize = 1.0;
        notifyListeners();
        return 1.0;
      }
    } catch (e) {
      _userFontSize = 1.0;
      notifyListeners();
      return 1.0;
    }
  }

  setUserFontsize(double fontSize) async {
    final storage = new FlutterSecureStorage();
    try {
      var _userFontsize = await storage.write(
          key: "sdb_fontSize", value: fontSize.toStringAsFixed(1));
      _userFontSize = fontSize;
    } catch (e) {
      _userFontSize = fontSize;
    }
    notifyListeners();
  }
}
