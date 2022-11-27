import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileNickname.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/pages/userProfileBody.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'dart:io';
import 'dart:async';

class ExerciseDone extends StatefulWidget {
  List<hisdata.Exercises> exerciseList = [];
  final int routinetime;
  final hisdata.SDBdata sdbdata;
  ExerciseDone(
      {Key? key,
      required this.exerciseList,
      required this.routinetime,
      required this.sdbdata})
      : super(key: key);

  @override
  _ExerciseDoneState createState() => _ExerciseDoneState();
}

class _ExerciseDoneState extends State<ExerciseDone> {
  var _userProvider;
  var _hisProvider;
  var _workoutProvider;
  var _routinetimeProvider;
  var _btnDisabled;
  TextEditingController _exerciseCommentCtrl = TextEditingController(text: "");
  File? _image;
  final ImagePicker _picker = ImagePicker();
  var _selectImage;
  @override
  void initState() {
    super.initState();
  }

  Future _getImage(ImageSource imageSource) async {
    _selectImage =
        await _picker.pickImage(source: imageSource, imageQuality: 30);

    setState(() {
      _image = File(_selectImage!.path); // 가져온 이미지를 _image에 저장
    });
  }

  Future<void> _pickImg() async {
    final XFile? selectImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (selectImage != null) {
      _image = File(selectImage.path);
      // dynamic sendData = selectImage.path;
      // UserImageEdit(file: sendData).patchUserImage().then((data) {
      //    _userProvider.setUserdata(data);
      // });
    }
  }

  PreferredSizeWidget _appbarWidget() {
    _btnDisabled = false;
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              _btnDisabled == true
                  ? null
                  : [
                      _btnDisabled = true,
                      Navigator.of(context).popUntil((route) => route.isFirst)
                    ];
            },
          ),
          title: Text(
            "운동 기록",
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          backgroundColor: Color(0xFF101012),
        ));
  }

  Widget _exerciseDoneWidget() {
    var time_hour = 0;
    var time_min = 0;
    var time_sec = 0;
    if (widget.routinetime ~/ 3600 > 0) {
      time_hour = widget.routinetime ~/ 3600;
    } else if (widget.routinetime ~/ 60 > 0) {
      time_min = widget.routinetime ~/ 60;
    } else if (widget.routinetime > 0) {
      time_sec = widget.routinetime % 60;
    }
    return Container(
        child: SingleChildScrollView(
      child: Column(children: [
        Container(
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Center(
                              child: Icon(Icons.fitness_center,
                                  color: Colors.white, size: 40)),
                        ),
                        SizedBox(
                          width: 120,
                          child: Center(
                              child: Icon(Icons.access_time,
                                  color: Colors.white, size: 40)),
                        ),
                        SizedBox(
                            width: 60,
                            child: Center(
                                child: Icon(Icons.celebration,
                                    color: Colors.white, size: 40))),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: 60,
                            child: Center(
                              child: Text("운동 갯수",
                                  style: TextStyle(color: Colors.white)),
                            )),
                        SizedBox(
                            width: 120,
                            child: Center(
                              child: Text("운동 시간",
                                  style: TextStyle(color: Colors.white)),
                            )),
                        SizedBox(
                            width: 60,
                            child: Center(
                              child: Text("신기록",
                                  style: TextStyle(color: Colors.white)),
                            ))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(widget.exerciseList.length.toString(),
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Center(
                            child: Text(
                                "${time_hour}시 ${time_min}분 ${time_sec}초",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(
                            width: 60,
                            child: Center(
                                child: Text(
                                    widget.sdbdata.new_record.toString(),
                                    style: TextStyle(color: Colors.white)))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 8.0),
                  child: GestureDetector(
                    child: _image == null
                        ? Icon(Icons.add_photo_alternate,
                            color: Colors.white, size: 120)
                        : Image.file(File(_image!.path)),
                    onTap: () {
                      _displayPhotoAlert();
                    },
                  )),
            ),
          ),
        ),
        _commentWidget(),
        _exercise_Done_Button()
      ]),
    ));
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
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.0)),
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
                                  color: Colors.white,
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
                                      size: 24, color: Colors.white),
                                  Text('촬영',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
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
                                  color: Colors.white,
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
                                      size: 24, color: Colors.white),
                                  Text('갤러리',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
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

  Widget _exercise_Done_Button() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: TextStyle(
                  color: Colors.white,
                ),
                disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                padding: EdgeInsets.all(12.0),
              ),
              onPressed: () {
                if (_selectImage != null) {
                  HistoryImageEdit(
                          history_id: widget.sdbdata.id,
                          file: _selectImage.path)
                      .patchHistoryImage()
                      .then((data) => {
                            _hisProvider.getdata(),
                            _hisProvider.getHistorydataAll()
                          });
                }
                ;
                if (_exerciseCommentCtrl.text != "") {
                  HistoryCommentEdit(
                          history_id: widget.sdbdata.id,
                          user_email: _userProvider.userdata.email,
                          comment: _exerciseCommentCtrl.text)
                      .patchHistoryComment();
                  _hisProvider.patchHistoryCommentdata(
                      widget.sdbdata, _exerciseCommentCtrl.text);
                }
                ;
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("운동 완료",
                  style: TextStyle(fontSize: 20.0, color: Colors.white)))),
    );
  }

  Widget _commentWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
          controller: _exerciseCommentCtrl,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.message, color: Colors.white),
              labelText: "운동에 대해 입력 할 수 있어요",
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: Colors.white),
          style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appbarWidget(),
        body: _exerciseDoneWidget(),
        backgroundColor: Color(0xFF101012));
  }
}
