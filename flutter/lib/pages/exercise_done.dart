import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
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
  ExerciseDone(
      {Key? key, required this.exerciseList, required this.routinetime})
      : super(key: key);

  @override
  _ExerciseDoneState createState() => _ExerciseDoneState();
}

class _ExerciseDoneState extends State<ExerciseDone> {
  var _userdataProvider;
  var _historydataProvider;
  var _workoutdataProvider;
  var _routinetimeProvider;
  var _btnDisabled;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImg() async {
    final XFile? selectImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (selectImage != null) {
      dynamic sendData = selectImage.path;
      UserImageEdit(file: sendData).patchUserImage().then((data) {
        _userdataProvider.setUserdata(data);
      });
    }
  }

  PreferredSizeWidget _appbarWidget() {
    _btnDisabled = false;
    return AppBar(
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
      backgroundColor: Colors.black,
    );
  }

  Widget _exerciseDoneWidget() {
    print(_workoutdataProvider.workoutdata.routinedatas[0].exercises[0].sets[0]
        .toJson());
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
        child: Column(children: [
      Container(
        height: 180,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Color(0xFF717171),
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
                          child: Text("${time_hour}시 ${time_min}분 ${time_sec}초",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(
                          width: 60,
                          child: Center(
                              child: Text("0",
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
        height: 240,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Color(0xFF717171),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                child: Icon(Icons.add_photo_alternate,
                    color: Colors.white, size: 120)),
          ),
        ),
      ),
      _exercise_Done_Button()
    ]));
  }

  Widget _exercise_Done_Button() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FlatButton(
              color: Color.fromRGBO(246, 58, 64, 20),
              textColor: Colors.white,
              disabledColor: Color.fromRGBO(246, 58, 64, 20),
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("운동 완료",
                  style: TextStyle(fontSize: 20.0, color: Colors.white)))),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _historydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appbarWidget(),
        body: _exerciseDoneWidget(),
        backgroundColor: Colors.black);
  }
}
