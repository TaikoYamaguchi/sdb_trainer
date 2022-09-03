import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
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

class ProgramDownload extends StatefulWidget {
  Famous program;
  ProgramDownload(
      {Key? key,
        required this.program,})
      : super(key: key);

  @override
  _ProgramDownloadState createState() => _ProgramDownloadState();
}

class _ProgramDownloadState extends State<ProgramDownload> {
  var _userdataProvider;
  var _famousdataProvider;
  var _workoutdataProvider;
  var _routinetimeProvider;
  var _btnDisabled;
  TextEditingController _famousimageCtrl = TextEditingController(text: "");
  TextEditingController _programtitleCtrl = TextEditingController(text: "");
  TextEditingController _programcommentCtrl = TextEditingController(text: "");

  var _selectImage;

  @override
  void initState() {
    super.initState();
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
            Navigator.of(context).pop(),
          ];
        },
      ),
      title: Text(
        "나의 Program 공유",
        style: TextStyle(color: Colors.white, fontSize: 30, ),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _programDownloadWidget() {
    return Column(
      children: [
        Container(
            child: Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        widget.program.image != ""
                        ? CircleAvatar(
                          radius: 48,
                          backgroundImage: NetworkImage(widget.program.image),
                          backgroundColor: Colors.transparent)
                        : Icon(
                          Icons.account_circle,
                          color: Colors.grey,
                          size: 100.0,
                          ),
                        Text(widget.program.routinedata.name,
                            style: TextStyle(fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.bold)),

                      ],
                    ),
                  ),

                  Container(
                    height: 100,
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
                                      width: 120,
                                      child: Center(
                                        child: Text("Program 기간",
                                            style: TextStyle(color: Colors.white)),
                                      )),

                                  SizedBox(
                                      width: 120,
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
                                    width: 120,
                                    child: Center(
                                      child: Text('${widget.program.routinedata.exercises[0].plans.length.toString()}days',
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ),

                                  SizedBox(
                                      width: 120,
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
                    padding: const EdgeInsets.all(12.0),
                    alignment: Alignment.centerLeft,
                    child: Text("Program 설명",
                        style: TextStyle(fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),

                  Container(
                    padding: const EdgeInsets.all(12.0),
                    alignment: Alignment.centerLeft,
                    child: Text(widget.program.routinedata.routine_time,
                        style: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    height: 10,
                  ),


                ]),
              ),
            )
        ),
        _exercise_Done_Button()
      ],
    );
  }


  Widget _exercise_Done_Button() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              disabledColor: Color.fromRGBO(246, 58, 64, 20),
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Theme.of(context).primaryColor,
              onPressed: () {

              },
              child: Text("시작하기",
                  style: TextStyle(fontSize: 20.0, color: Colors.white)))),
    );
  }

  Widget _titleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
          controller: _programtitleCtrl,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit, color: Colors.white),
              labelText: 'Program 이름을 바꿀 수 있어요',
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

  Widget _commentWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
          controller: _programcommentCtrl,
          keyboardType: TextInputType.multiline,
          //expands: true,
          maxLines: null,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit, color: Colors.white),
              labelText: 'Program을 설명해주세요',
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
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appbarWidget(),
        body: _programDownloadWidget(),
        backgroundColor: Colors.black);
  }
}
