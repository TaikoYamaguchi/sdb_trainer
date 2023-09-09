import 'package:flutter/cupertino.dart';

class ChartIndexProvider extends ChangeNotifier {
  int _chartIndex = 0;
  int _staticIndex = 0;
  int _staticChartPointIndex = -1;
  var _isPageController = PageController(initialPage: 0);
  int get chartIndex => _chartIndex;
  int get staticIndex => _staticIndex;
  int get staticChartPointIndex => _staticChartPointIndex;

  PageController get isPageController => _isPageController;

  change(state) {
    _chartIndex = state;
    notifyListeners();
  }

  changeStaticIndex(state) {
    _staticIndex = state;
    notifyListeners();
  }

  changeStaticChartPointIndex(state) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _staticChartPointIndex = state;
      notifyListeners();
    });
  }

  initStaticChartPointIndex(state) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _staticChartPointIndex = -1;
      notifyListeners();
    });
  }

  changePageController(state) {
    _isPageController.jumpToPage(state);
    notifyListeners();
  }
}
