
import 'package:flutter/cupertino.dart';

class BodyStater extends ChangeNotifier{
  int _bodystate = 0;
  int get bodystate => _bodystate;
  void change(state) {
    _bodystate = state;
    notifyListeners();
  }

}