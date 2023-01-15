import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  var _userFontSize;
  var _userThemeDark;
  get userFontSize => _userFontSize;
  get userThemeDark => _userThemeDark;

  Future<double> getUserFontsize() async {
    final storage = new FlutterSecureStorage();
    _userFontSize = 0.8;
    try {
      var _fontsize = await storage.read(key: "sdb_fontSize");
      if (_fontsize != null && _fontsize != "") {
        _userFontSize = double.parse(_fontsize);
        print(_fontsize);
        notifyListeners();
        return double.parse(_fontsize);
      } else {
        _userFontSize = 0.8;
        notifyListeners();
        return 0.8;
      }
    } catch (e) {
      _userFontSize = 0.8;
      notifyListeners();
      return 0.8;
    }
  }

  setUserFontsize(double fontSize) async {
    final storage = new FlutterSecureStorage();
    try {
      var _userFontsize = await storage.write(
          key: "sdb_fontSize", value: fontSize.toStringAsFixed(1));
      _userFontSize = fontSize;
    } catch (e) {
      _userFontSize = fontSize;
    }
    notifyListeners();
  }

  Future<String> getUserTheme() async {
    final storage = new FlutterSecureStorage();
    _userThemeDark = "white";
    try {
      var _userThemeStorage = await storage.read(key: "sdb_theme");
      if (_userThemeStorage != null && _userThemeStorage != "") {
        if (_userThemeStorage != "dark" && _userThemeStorage != "white") {
          _userThemeDark = "white";
        } else {
          _userThemeDark = _userThemeStorage;
        }
        notifyListeners();

        return _userThemeStorage;
      } else {
        _userThemeDark = "white";
        notifyListeners();
        return "white";
      }
    } catch (e) {
      _userThemeDark = "white";
      notifyListeners();
      return "white";
    }
  }

  setUserTheme(String theme) async {
    final storage = new FlutterSecureStorage();
    try {
      print(theme);
      var _userThemeStorage =
          await storage.write(key: "sdb_theme", value: theme);
      _userThemeDark = theme;
    } catch (e) {
      _userThemeDark = theme;
    }
    notifyListeners();
  }
}
