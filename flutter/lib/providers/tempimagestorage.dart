import 'package:flutter/cupertino.dart';
import 'package:cross_file/cross_file.dart';

class TempImgStorage extends ChangeNotifier {
  List<XFile> _images = [];
  List<XFile> get images => _images;

  setimg(imgs) {
    _images.addAll(imgs);
    notifyListeners();
    print('inserted ${_images.length}');
  }

  resetimg() {
    _images = [];
    print('inserted ${_images.length}');
  }
}
