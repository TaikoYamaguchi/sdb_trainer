import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsProvider extends ChangeNotifier {
  bool? _eachworkouttutor = false;
  bool? get eachworkouttutor => _eachworkouttutor;
  bool? _stepone = false;
  bool? get stepone => _stepone;
  bool? _steptwo = false;
  bool? get steptwo => _steptwo;
  bool? _stepthree = false;
  bool? get stepthree => _stepthree;
  var _prefs;
  SharedPreferences get prefs => _prefs;

  getprefs() async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.getBool('eachworkouttutor') == null
        ? [
            await _prefs.setBool('eachworkouttutor', true),
            _eachworkouttutor = _prefs.getBool('eachworkouttutor'),
            _stepone = _eachworkouttutor,
            _steptwo = _eachworkouttutor,
            _stepthree = _eachworkouttutor
          ]
        : [
            _eachworkouttutor = _prefs.getBool('eachworkouttutor'),
            _stepone = _eachworkouttutor,
            _steptwo = _eachworkouttutor,
            _stepthree = _eachworkouttutor
          ];

    notifyListeners();
  }

  steponedone() async {
    _stepone = false;

    notifyListeners();
  }

  steptwodone() async {
    _steptwo = false;

    notifyListeners();
  }

  stepthreedone() async {
    _stepthree = false;

    notifyListeners();
  }

  tutordone() async {
    await _prefs.setBool('eachworkouttutor', false);
    _eachworkouttutor = _prefs.getBool('eachworkouttutor');

    notifyListeners();
  }

  tutorstart() async {
    await _prefs.setBool('eachworkouttutor', true);
    _eachworkouttutor = _prefs.getBool('eachworkouttutor');
    _stepone = _eachworkouttutor;
    _steptwo = _eachworkouttutor;
    _stepthree = _eachworkouttutor;

    notifyListeners();
  }
}
