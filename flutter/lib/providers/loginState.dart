import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/pages/feed.dart';

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
