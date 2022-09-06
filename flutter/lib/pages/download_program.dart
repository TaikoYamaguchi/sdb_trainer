import 'package:flutter/material.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
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
  var _exercisesdataProvider;
  var _routinetimeProvider;
  var _btnDisabled;
  List<TextEditingController> _onermController = [];
  TextEditingController _famousimageCtrl = TextEditingController(text: "");
  TextEditingController _programtitleCtrl = TextEditingController(text: "");
  TextEditingController _programcommentCtrl = TextEditingController(text: "");
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");

  var _selectImage;
  List ref_exercise =[];
  List ref_exercise_index =[];

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
                        Expanded(
                          child: Text(widget.program.routinedata.name,
                              style: TextStyle(fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),

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
                for (int p = 0; p < widget.program.routinedata.exercises[0].plans.length; p++) {

                  for (int e = 0; e < widget.program.routinedata.exercises[0].plans[p].exercises.length; e++) {
                    ref_exercise.add(widget.program.routinedata.exercises[0].plans[p].exercises[e].ref_name);

                  }
                }
                ref_exercise= ref_exercise.toSet().toList();
                for (int i = 0; i < ref_exercise.length; i++) {
                  ref_exercise_index.add(_exercisesdataProvider.exercisesdata.exercises.indexWhere((element) => element.name == ref_exercise[i])) ;
                }
                ref_exercise_index= ref_exercise_index.toSet().toList();

                _displayStartAlert();
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

  void _displayStartAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            buttonPadding: EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.all(12.0),
            title: Text(
              '운동을 시작 할 수 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('운동을 시작 할까요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('외부를 터치하면 취소 할 수 있어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            actions: <Widget>[
              _StartConfirmButton(),
            ],
          );
        });
  }

  Widget _StartConfirmButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              setSetting();


            },
            padding: EdgeInsets.all(12.0),
            splashColor: Theme.of(context).primaryColor,
            child: Text("운동 시작 하기",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void setSetting() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(12.0),
          height: MediaQuery.of(context).size.height * 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            children: [
              Container(
                child: Text(
                  '본인의 1rm이 맞나요? ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              Container(
                child: Text('아니라면 값을 수정 해주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              Container(
                child: Text('외부를 터치하면 취소 할 수 있어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                        width: MediaQuery.of(context).size.width*2/4,
                        child: Center(
                          child: Text(
                            "운동",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,fontWeight: FontWeight.bold
                            ),
                          ),
                        )),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: MediaQuery.of(context).size.width*1/4,
                        child: Center(
                          child: Text("1rm",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18, fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.center),
                        )),
                  ],
                ),
              ),
              _neededlist(),
              _1rmConfirmButton()

            ],
          ),
        );
      },
    );
  }




  Widget _neededlist(){
    return Expanded(
      child: ListView.builder(
        itemBuilder: (BuildContext _context, int index) {
          return Center(
              child: _exerciseWidget(_exercisesdataProvider.exercisesdata.exercises[ref_exercise_index[index]], index));
        },

        itemCount: ref_exercise_index.length,
        shrinkWrap: true,
      ),
    );
  }

  Widget _exerciseWidget(Exercises, index) {
    _onermController.add(new TextEditingController(text: Exercises.onerm.toStringAsFixed(1)));
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width*2/4,
                child: Center(
                  child: Text(
                    Exercises.name,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width*1/4,
                child: Center(
                  child: TextFormField(
                      controller: _onermController[index],
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,

                      decoration: InputDecoration(
                          filled: true,
                          enabledBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor, width: 3),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor, width: 3),
                          ),
                          hintText: Exercises.onerm.toStringAsFixed(1),
                          hintStyle: TextStyle(fontSize: 18, color: Colors.white)),
                      onChanged: (text) {
                        double changeweight;
                        if (text == "") {
                          changeweight = 0.0;
                        } else {
                          changeweight = double.parse(text);
                        }
                        setState(() {
                          _exercisesdataProvider.exercisesdata.exercises[ref_exercise_index[index]].onerm = changeweight;
                        });
                      }),
                ),
              ),

            ],
          ),
          Container(
            alignment: Alignment.center,
            height: 1,
            color: Colors.black,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 1,
              color: Color(0xFF717171),
            ),
          )
        ],
      ),
    );
  }

  Widget _1rmConfirmButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: () {
              _workoutdataProvider.addroutine(widget.program.routinedata);
              _editWorkoutCheck();
              Navigator.of(context).popUntil((route) => route.isFirst);
              ProgramSubscribe(id: widget.program.id).subscribeProgram()
                  .then((data) => data["user_email"] != null
                  ? [showToast("done!"), _famousdataProvider.getdata()]
                  : showToast("입력을 확인해주세요"));

            },
            padding: EdgeInsets.all(12.0),
            splashColor: Theme.of(context).primaryColor,
            child: Text("1rm 확인",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _editWorkoutCheck() async {
    WorkoutEdit(
        user_email: _userdataProvider.userdata.email,
        id: _workoutdataProvider.workoutdata.id,
        routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
        ? [showToast("done!"), _workoutdataProvider.getdata()]
        : showToast("입력을 확인해주세요"));
  }



  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appbarWidget(),
        body: _programDownloadWidget(),
        backgroundColor: Colors.black);
  }
}
