import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  var _userFontSize;
  get userFontSize => _userFontSize;

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
}
