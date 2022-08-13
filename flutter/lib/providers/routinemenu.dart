import 'package:flutter/cupertino.dart';

class RoutineMenuStater extends ChangeNotifier {
  int _menustate = 0;
  int get menustate => _menustate;
  bool _ismodechecked = false;
  bool get ismodechecked => _ismodechecked;

  change(state) {
    _menustate = state;
    notifyListeners();
  }

  modecheck() {
    _ismodechecked = !_ismodechecked;
    notifyListeners();
  }
  modereset() {
    _ismodechecked = false;
  }
}
