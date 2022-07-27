import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsProvider extends ChangeNotifier {

  bool? _eachworkouttutor = false;
  bool? get eachworkouttutor => _eachworkouttutor;
  bool? _isprostacking = false;
  bool? get isprostacking => _isprostacking;
  var _prefs;

  getprefs() async{
    _prefs = await SharedPreferences.getInstance();
    _prefs.getBool('eachworkouttutor') == null
        ? [_prefs.setBool('eachworkouttutor', true), _eachworkouttutor = _prefs.getBool('eachworkouttutor')]
        : _eachworkouttutor = _prefs.getBool('eachworkouttutor');

    notifyListeners();
  }

  tutordone() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.getBool('eachworkouttutor') == null
        ? [prefs.setBool('eachworkouttutor', true), _eachworkouttutor = prefs.getBool('eachworkouttutor')]
        : _eachworkouttutor = prefs.getBool('eachworkouttutor');

    notifyListeners();
  }
}