
import 'package:flutter/material.dart';

class PopProvider extends ChangeNotifier {

  int _exstack = 0;
  int get exstack => _exstack;

  exstackup() {
    _exstack++;
    notifyListeners();
  }

  exstackdown() {
    _exstack--;
  }

}