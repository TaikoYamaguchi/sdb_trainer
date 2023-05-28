import 'package:flutter/cupertino.dart';

class ChartIndexProvider extends ChangeNotifier {
  int _chartIndex = 0;
  int _staticIndex = 0;
  var _isPageController = PageController(initialPage: 0);
  int get chartIndex => _chartIndex;
  int get staticIndex => _staticIndex;

  PageController get isPageController => _isPageController;

  change(state) {
    _chartIndex = state;
    notifyListeners();
  }

  changeStaticIndex(state) {
    _staticIndex = state;
    notifyListeners();
  }

  changePageController(state) {
    _isPageController.jumpToPage(state);
    notifyListeners();
  }
}
