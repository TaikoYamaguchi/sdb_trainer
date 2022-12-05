import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/repository/user_repository.dart';

const USER_NICK_NAME = "USER_NICK_NAME";
const STATUS_LOGIN = 'STATUS_LOGIN';
const STATUS_LOGOUT = "STATUS_LOGOUT";

void showToast(String message) {
  Fluttertoast.showToast(
      fontSize: 13,
      msg: ' $message',
      backgroundColor: const Color(0xff7a28cb),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM);
}

void userLogOut(context) {
  print("loggggggout");
  var _loginState = Provider.of<LoginPageProvider>(context, listen: false);
  var _userProvider = Provider.of<UserdataProvider>(context, listen: false);
  _userProvider.setUserKakaoEmail(null);
  _userProvider.setUserKakaoName(null);
  _userProvider.setUserKakaoImageUrl(null);
  _userProvider.setUserKakaoGender(null);
  UserLogOut.logOut();
  _loginState.change(false);
  _loginState.changeSignup(false);
}
