import 'package:flutter/cupertino.dart';
import 'package:cross_file/cross_file.dart';

class TempImgStorage extends ChangeNotifier {
  List<XFile> _images = [];
  List<XFile> get images => _images;
  bool _isfeedcapture = false;
  bool get isfeedcapture => _isfeedcapture;

  setimg(imgs) {
    _images.addAll(imgs);
    notifyListeners();
    print('inserted ${_images.length}');
  }

  resetimg() {
    _images = [];
    print('inserted ${_images.length}');
  }

  onCapture(){
    _isfeedcapture = true;
  }

  offCapture(){
    _isfeedcapture = false;
  }

}
