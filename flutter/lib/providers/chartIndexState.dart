import 'package:flutter/cupertino.dart';

class ChartIndexProvider extends ChangeNotifier {
  int _chartIndex = 0;
  var _isPageController = PageController(initialPage: 1);
  bool _isChartWidget = false;
  int get chartIndex => _chartIndex;

  PageController get isPageController => _isPageController;

  change(state) {
    _chartIndex = state;
    notifyListeners();
  }

  changePageController(state) {
    _isPageController.jumpToPage(state);
    notifyListeners();
  }
}
