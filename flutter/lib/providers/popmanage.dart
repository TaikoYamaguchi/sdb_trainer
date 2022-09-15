import 'package:flutter/material.dart';

class PopProvider extends ChangeNotifier {
  bool _goto = false;
  bool get goto => _goto;
  int _exstack = 0;
  int get exstack => _exstack;
  int _profilestack = 0;
  int get profilestack => _profilestack;
  bool _isstacking = false;
  bool get isstacking => _isstacking;
  bool _isprostacking = false;
  bool get isprostacking => _isprostacking;
  bool _tutorpop = false;
  bool get tutorpop => _tutorpop;

  gotoon() {
    _goto = true;
    notifyListeners();
  }

  gotooff() {
    _goto = false;
    notifyListeners();
  }

  tutorpopon() {
    _tutorpop = true;
    notifyListeners();
  }

  tutorpopoff() {
    _tutorpop = false;
  }

  popon() {
    _exstack == 0 ? null : _isstacking = true;
    notifyListeners();
  }

  popoff() {
    _isstacking = false;
  }

  exstackup(order) {
    _exstack = order;
  }

  exstackdown() {
    _exstack--;
  }

  profilestackup() {
    _profilestack++;
  }

  profilestackdown() {
    _profilestack--;
  }

  propopon() {
    _profilestack == 0 ? null : _isprostacking = true;
    notifyListeners();
  }

  propopoff() {
    _isprostacking = false;
  }
}
