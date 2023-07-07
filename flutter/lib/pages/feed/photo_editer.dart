import 'dart:typed_data';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/tempimagestorage.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;

// ignore: must_be_immutable
class PhotoEditor extends StatefulWidget {
  final hisdata.SDBdata sdbdata;
  ImageSource imageSource;

  PhotoEditor({Key? key, required this.sdbdata, required this.imageSource})
      : super(key: key);

  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  List<GlobalKey> repaintkey = [];
  List<XFile> _image = [];
  final ImagePicker _picker = ImagePicker();
  bool _isabsorb = false;
  int curpage = 0;
  List<Pair> _settings = [];
  var _tempImgStrage;
  PageController controller =
      PageController(viewportFraction: 0.93, keepPage: true);
  List<XFile> _selectedImages = [];
  @override
  void initState() {
    super.initState();
    _initList();
    _getImage(widget.imageSource);
  }

  void _initList() {
    _settings.add(Pair(true, 0));
  }

  Future _getImage(ImageSource imageSource) async {
    if (imageSource == ImageSource.gallery) {
      _selectedImages = await _picker.pickMultiImage(imageQuality: 30);
      print('done');

      if (_selectedImages.isNotEmpty) {
        setState(() {
          _image.addAll(_selectedImages);
          repaintkey = List<GlobalKey>.generate(
              _image.length, (index) => GlobalKey(debugLabel: 'key_$index'),
              growable: false);
// 가져온 이미지를 _image에 저장
        });
      } else {
        Navigator.of(context).pop();
      }
    } else if (imageSource == ImageSource.camera) {
      final XFile? _selectedImage =
          await _picker.pickImage(source: imageSource, imageQuality: 30);
      if (_selectedImage != null) {
        setState(() {
          _image.add(_selectedImage); // 가져온 이미지를 _image에 저장
          repaintkey = List<GlobalKey>.generate(
              1, (index) => GlobalKey(debugLabel: 'key_$index'),
              growable: false);
        });
      }
    }
    for (int i = 0; i < _image.length - _settings.length + 1; ++i) {
      _settings.add(Pair(true, 0));
    }
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.check_rounded),
              color: Theme.of(context).primaryColorLight,
              onPressed: () async {
                setState(() {
                  _isabsorb = true;
                });
                if (_image.isNotEmpty) {
                  for (int i = 0; i < _image.length; i++) {
                    await controller.animateToPage(i,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.linear);

                    RenderObject? renderObject =
                        repaintkey[i].currentContext?.findRenderObject();
                    RenderRepaintBoundary boundary =
                        renderObject as RenderRepaintBoundary;
                    var imageFinal = await boundary.toImage(pixelRatio: 5.0);
                    ByteData? byteData = await imageFinal.toByteData(
                        format: ImageByteFormat.png);
                    final imageBytes = byteData?.buffer.asUint8List();
                    final dir = Platform.isAndroid
                        ? await getExternalStorageDirectory()
                        : await getApplicationDocumentsDirectory();
                    String? path = dir?.path;
                    final file = createFile(
                      '$path/stamp_image_${DateTime.now().toString()}.png',
                      imageBytes,
                    );

                    _image[i] = (XFile(file.path));
                    //_image = [];
                  }
                }

                _tempImgStrage.setimg(_image);

                Navigator.of(context).pop();
              },
            )
          ],
          title: Row(
            children: [
              Text(
                "사진 편집",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _watermarkTitle(index) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Supero",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _settings[index].a ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _watermarkSet(index) {
    List exlist = widget.sdbdata.exercises;
    num _setNumber = 0;
    for (int i = 0; i < exlist.length; i++) {
      _setNumber += exlist[i].sets.length;
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Typicons.input_checked,
            color: _settings[index].a ? Colors.white : Colors.black,
          ),
          Text(
            "${_setNumber}Sets",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _settings[index].a ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _watermarkWorkoutTime(index) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.timer,
            color: _settings[index].a ? Colors.white : Colors.black,
          ),
          Text(
            '${(widget.sdbdata.workout_time / 60).floor().toString()}:${widget.sdbdata.workout_time % 60}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _settings[index].a ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photowidget(rpkey, index) {
    return RepaintBoundary(
        key: rpkey,
        child: _settings[index].b == 0
            ? _photowidget_basic(index)
            : _photowidget_title(index));
  }

  Widget _photowidget_basic(index) {
    return Stack(children: [
      Container(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: FileImage(File(_image[index].path)),
          fit: BoxFit.cover,
        )),
      ),
      Positioned(top: 5, right: 5, child: _watermarkTitle(index)),
      Positioned(bottom: 5, left: 5, child: _watermarkWorkoutTime(index)),
      Positioned(bottom: 5, right: 5, child: _watermarkSet(index))
    ]);
  }

  Widget _photowidget_title(index) {
    return Stack(children: [
      Container(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: FileImage(File(_image[index].path)),
          fit: BoxFit.cover,
        )),
      ),
      Positioned(top: 5, right: 5, child: _watermarkTitle(index)),
    ]);
  }

  Widget photoBox() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AbsorbPointer(
        absorbing: _isabsorb,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _settings[curpage].a = true;
                      });
                    },
                    child: Text('White',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: _settings[curpage].a
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                        )),
                  ),
                  Container(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _settings[curpage].a = false;
                      });
                    },
                    child: Text('Black',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: _settings[curpage].a
                              ? FontWeight.normal
                              : FontWeight.bold,
                          fontSize: 16,
                        )),
                  ),
                ],
              ),
              Container(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.93 - 16,
                child: PageView.builder(
                    controller: controller,
                    onPageChanged: (int page) {
                      setState(() {
                        curpage = page;
                      });
                    },
                    itemCount: _image.length + 1,
                    itemBuilder: (context, int index) {
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: index == _image.length
                              ? GestureDetector(
                                  onTap: () {
                                    _displayPhotoAlert();
                                  },
                                  child: Icon(Icons.add_photo_alternate,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      size: 120),
                                )
                              : KeepAlivePage(
                                  child:
                                      _photowidget(repaintkey[index], index)));
                    }),
              ),
              SizedBox(
                height: 102,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _settings[curpage].b = 0;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: _settings[curpage].b == 0
                                ? Theme.of(context).indicatorColor
                                : Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Card(
                            elevation: 5,
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: EdgeInsets.all(3.0),
                                            child: Text('Supero',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Time',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const Text('Sets',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 22,
                                  child: Center(
                                    child: Text('Basic',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _settings[curpage].b = 1;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: _settings[curpage].b == 1
                                ? Theme.of(context).indicatorColor
                                : Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Card(
                            elevation: 5,
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: const Center(
                                      child: Text('Supero',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))),
                                ),
                                const SizedBox(
                                  height: 22,
                                  child: Center(
                                    child: Text('Title',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ]),
              ),
              Container(height: 15),
            ],
          ),
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
                                    const Color.fromRGBO(246, 58, 64, 20),
                                padding: const EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _getImage(ImageSource.camera);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 24,
                                      color: Theme.of(context).highlightColor),
                                  Text('촬영',
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .highlightColor)),
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
                                    const Color.fromRGBO(246, 58, 64, 20),
                                padding: const EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                //_getImage(ImageSource.gallery);
                                Navigator.pop(context);
                                _getImage(ImageSource.gallery);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.collections,
                                      size: 24,
                                      color: Theme.of(context).highlightColor),
                                  Text('갤러리',
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .highlightColor)),
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

  File createFile(String? path, Uint8List? data) {
    final file = File(path!);
    file.create();
    file.writeAsBytesSync(data!);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    _tempImgStrage = Provider.of<TempImgStorage>(context, listen: false);
    return Scaffold(appBar: _appbarWidget(), body: photoBox());
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }
}

class Pair<T1, T2> {
  T1 a;
  T2 b;

  Pair(this.a, this.b);
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({Key? key, required this.child}) : super(key: key);

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    /// Dont't forget this
    super.build(context);

    return widget.child;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
