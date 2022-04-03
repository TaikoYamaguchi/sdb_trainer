import 'package:flutter/cupertino.dart';

class LoginPageProvider extends ChangeNotifier {
  bool _isLogin = false;
  bool get isLogin => _isLogin;
  change(state) {
    _isLogin = state;
    notifyListeners();
  }
}
