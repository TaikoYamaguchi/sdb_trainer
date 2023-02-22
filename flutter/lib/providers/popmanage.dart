import 'package:flutter/material.dart';

class PopProvider extends ChangeNotifier {
  bool _goto = false;
  bool get goto => _goto;
  bool _gotolast = false;
  bool get gotolast => _gotolast;
  int _exstack = 0;
  int get exstack => _exstack;
  int _profilestack = 0;
  int get profilestack => _profilestack;
  int _searchstack = 0;
  int get searchstack => _searchstack;

  bool _isstacking = false;
  bool get isstacking => _isstacking;
  bool _isprostacking = false;
  bool get isprostacking => _isprostacking;
  bool _issearchstacking = false;
  bool get issearchstacking => _issearchstacking;

  bool _tutorpop = false;
  bool get tutorpop => _tutorpop;

  gotoon() {
    _goto = true;
    notifyListeners();
  }

  gotoonlast() {
    _gotolast = true;
    notifyListeners();
  }

  gotooff() {
    _goto = false;
    _gotolast = false;
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

  searchpopon() {
    _searchstack == 0 ? null : _issearchstacking = true;
    notifyListeners();
  }

  searchpopoff() {
    _issearchstacking = false;
    notifyListeners();
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

  searchstackup() {
    _searchstack++;
  }

  searchstackdown() {
    _searchstack--;
  }

  propopon() {
    _profilestack == 0 ? null : _isprostacking = true;
    notifyListeners();
  }

  propopoff() {
    _isprostacking = false;
  }
}
