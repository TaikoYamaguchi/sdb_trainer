import 'package:flutter/cupertino.dart';

class RoutineMenuStater extends ChangeNotifier {
  int _menustate = 0;
  int get menustate => _menustate;

  change(state) {
    _menustate = state;
    notifyListeners();
  }
}
