import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsProvider extends ChangeNotifier {
  bool? _eachworkouttutor = false;
  bool? get eachworkouttutor => _eachworkouttutor;
  String? _nowonplan = "";
  String? get nowonplan => _nowonplan;
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
    _prefs.getString('lastroutine') == null
        ? await _prefs.setString('lastroutine', '')
        : null;

    _prefs.getBool('userest') == null
        ? await _prefs.setBool('userest', false)
        : null;
    _prefs.getString('nowonplan') == null
        ? [
            await _prefs.setString('nowonplan', ''),
            _nowonplan = _prefs.getString('nowonplan')
          ]
        : _nowonplan = _prefs.getString('nowonplan');

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

  lastplan(value) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('lastroutine', value);
    notifyListeners();
  }

  setplan(name) async {
    await _prefs.setString('nowonplan', name);
    _nowonplan = _prefs.getString('nowonplan');

    notifyListeners();
  }
}
