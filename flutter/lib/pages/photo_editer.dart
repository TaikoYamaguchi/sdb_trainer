import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoEditor extends StatefulWidget {
  PhotoEditor({Key? key}) : super(key: key);

  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  var _selectImage;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future _getImage(ImageSource imageSource) async {
    _selectImage =
        await _picker.pickImage(source: imageSource, imageQuality: 30);
    /*
    var tempImg = img.decodeImage(File(_selectImage!.path).readAsBytesSync());

  var stringimg = img.drawString(tempImg!,
      'Superoasdklfjasdklfjlasdkfjklasjfklasdlkflasdkfklasdklfklasdklfklaskldflkasdklfjklasdjfkljasdklfjaklsdf',
      font: img.arial48, x: 0, y: 0, );
  File waterMarkSaveFile = File(_selectImage!.path);
  final jpg = img.encodeJpg(stringimg);
  waterMarkSaveFile.writeAsBytes(jpg);
  */
    setState(() {
      _image = File(_selectImage!.path); // 가져온 이미지를 _image에 저장
    });
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Row(
            children: [
              Text(
                "운동 찾기",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget photoBox() {
    return Container(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Theme.of(context).cardColor,
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
              child: GestureDetector(
                child: _image == null
                    ? Icon(Icons.add_photo_alternate,
                        color: Theme.of(context).primaryColorLight, size: 120)
                    : Image.file(File(_image!.path)),
                onTap: () {
                  _displayPhotoAlert();
                },
              )),
        ),
      ),
    );
  }

  void _displayPhotoAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                      child: Text("사진을 올릴 방법을 고를 수 있어요",
                          textScaleFactor: 1.3,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).primaryColor,
                                textStyle: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                disabledForegroundColor:
                                    Color.fromRGBO(246, 58, 64, 20),
                                padding: EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                _getImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 24,
                                      color:
                                          Theme.of(context).primaryColorLight),
                                  Text('촬영',
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)),
                                ],
                              ),
                            )),
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).primaryColor,
                                textStyle: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                disabledForegroundColor:
                                    Color.fromRGBO(246, 58, 64, 20),
                                padding: EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                _getImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.collections,
                                      size: 24,
                                      color:
                                          Theme.of(context).primaryColorLight),
                                  Text('갤러리',
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appbarWidget(), body: photoBox());
  }
}
