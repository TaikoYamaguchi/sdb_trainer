import 'package:flutter/cupertino.dart';

class ChartIndexProvider extends ChangeNotifier {
  int _chartIndex = 0;
  int get chartIndex => _chartIndex;
  change(state) {
    _chartIndex = state;
    notifyListeners();
  }
}
