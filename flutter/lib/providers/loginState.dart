import 'package:flutter/cupertino.dart';

class LoginPageProvider extends ChangeNotifier {
  bool _isLogin = true;
  bool get isLogin => _isLogin;
  change(state) {
    _isLogin = state;
    notifyListeners();
  }
}
