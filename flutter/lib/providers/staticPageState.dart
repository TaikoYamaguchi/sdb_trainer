import 'package:flutter/cupertino.dart';

class StaticPageProvider extends ChangeNotifier {
  bool _isChartWidget = false;
  bool get isChartWidget => _isChartWidget;
  change(state) {
    _isChartWidget = state;
    notifyListeners();
  }
}
