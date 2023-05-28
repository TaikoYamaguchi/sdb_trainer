import 'package:flutter/cupertino.dart';

class LoginPageProvider extends ChangeNotifier {
  bool _isLogin = false;
  bool _isSignUp = false;
  bool get isLogin => _isLogin;
  bool get isSignUp => _isSignUp;
  change(state) {
    _isLogin = state;
    notifyListeners();
  }

  changeSignup(state) {
    _isSignUp = state;
    notifyListeners();
  }
}
