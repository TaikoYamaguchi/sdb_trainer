import 'dart:ui';

import 'package:expandable/expandable.dart';
import 'package:sdb_trainer/pages/exercise_done.dart';
import 'package:sdb_trainer/pages/upload_program.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/change_name.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:transition/transition.dart';

class EachPlanDetails extends StatefulWidget {
  int rindex;
  EachPlanDetails({Key? key, required this.rindex}) : super(key: key);

  @override
  State<EachPlanDetails> createState() => _EachPlanDetailsState();
}

class _EachPlanDetailsState extends State<EachPlanDetails> {
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  TextEditingController _weightctrl = TextEditingController(text: "");
  TextEditingController _repsctrl = TextEditingController(text: "");
  var _workoutProvider;
  var _hisProvider;
  var _routinetimeProvider;
  var _PopProvider;
  var _userProvider;
  var _prefsProvider;
  var _exProvider;
  var _testdata0;
  var _customRuUsed = false;
  late var _testdata = _testdata0;
  String _addexinput = '';
  late List<hisdata.Exercises> exerciseList = [];
  var _exercises;
  var btnDisabled;

  Plans sample = new Plans(exercises: []);
  Plan_Exercises exsample = new Plan_Exercises(
      name: '벤치프레스',
      ref_name: '벤치프레스',
      sets: [Sets(index: 0, weight: 100, reps: 10, ischecked: false)],
      rest: 0);

  ExpandableController Controller = ExpandableController(
    initialExpanded: true,
  );
  List<ExpandableController> Controllerlist = [];

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              _editWorkoutCheck();
              btnDisabled == true
                  ? null
                  : [btnDisabled = true, Navigator.of(context).pop()];
            },
          ),
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NameInputDialog(rindex: widget.rindex);
                      });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 5 / 8,
                  child: Consumer<WorkoutdataProvider>(
                      builder: (builder, provider, child) {
                    return Text(
                      provider.workoutdata.routinedatas[widget.rindex].name,
                      textScaleFactor: 1.5,
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _workoutProvider
                              .workoutdata.routinedatas[widget.rindex].mode ==
                          3
                      ? showToast("다운받은 루틴은 업로드 할 수 없어요")
                      : Navigator.push(
                          context,
                          Transition(
                              child: ProgramUpload(
                                program: _workoutProvider
                                    .workoutdata.routinedatas[widget.rindex],
                              ),
                              transitionEffect:
                                  TransitionEffect.RIGHT_TO_LEFT));
                },
                icon: Icon(
                  Icons.cloud_upload_rounded,
                ))
          ],
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  void _displayFinishAlert() {
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
              '운동을 종료 할 수 있어요',
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('운동을 종료 하시겠나요?',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                Text('외부를 터치하면 취소 할 수 있어요',
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            actions: <Widget>[
              _finishConfirmButton(),
            ],
          );
        });
  }

  Widget _finishConfirmButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
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
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              recordExercise();
              _editHistoryCheck();
              _editWorkoutCheck();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("운동 종료 하기",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  Widget _Nday_RoutineWidget() {
    return Consumer2<WorkoutdataProvider, ExercisesdataProvider>(
        builder: (builder, workout, exinfo, child) {
      var plandata =
          workout.workoutdata.routinedatas[widget.rindex].exercises[0];
      var inplandata = plandata.plans[plandata.progress].exercises;
      var uniqexinfo = exinfo.exercisesdata.exercises;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 36,
              child: Row(
                children: [
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      padding: EdgeInsets.all(3),
                      constraints: BoxConstraints(),
                      onPressed: () {
                        if (plandata.progress == 0) {
                          _workoutProvider.setplanprogress(
                              widget.rindex, plandata.plans.length - 1);
                        } else {
                          _workoutProvider.setplanprogress(
                              widget.rindex, plandata.progress - 1);
                        }
                        _editWorkoutCheck();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_outlined,
                        color: Theme.of(context).primaryColorLight,
                        size: 20,
                      )),
                  Container(
                    width: 10,
                  ),
                  Container(
                    child: Text(
                      '${plandata.progress + 1}/${plandata.plans.length}day',
                      textScaleFactor: 2.0,
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      padding: EdgeInsets.all(3),
                      constraints: BoxConstraints(),
                      onPressed: () {
                        if (plandata.progress == plandata.plans.length - 1) {
                          _workoutProvider.setplanprogress(widget.rindex, 0);
                        } else {
                          _workoutProvider.setplanprogress(
                              widget.rindex, plandata.progress + 1);
                        }
                        _editWorkoutCheck();
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Theme.of(context).primaryColorLight,
                        size: 20,
                      )),
                  Container(
                    width: 10,
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () {
                          if (plandata.plans.length != 1) {
                            _workoutProvider.removeplanAt(widget.rindex);
                            if (plandata.progress != 0) {
                              _workoutProvider.setplanprogress(
                                  widget.rindex, plandata.progress - 1);
                            }
                            _editWorkoutCheck();
                          }
                        },
                        icon: Icon(
                          Icons.remove_circle_outlined,
                          color: Theme.of(context).primaryColorLight,
                          size: 20,
                        )),
                  ),
                  Container(
                    child: Text(
                      ' /',
                      textScaleFactor: 1.7,
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: IconButton(
                        padding: EdgeInsets.all(5),
                        constraints: BoxConstraints(),
                        onPressed: () {
                          _workoutProvider.addplanAt(widget.rindex, sample);
                          _workoutProvider.setplanprogress(
                              widget.rindex, plandata.progress + 1);
                          _editWorkoutCheck();
                        },
                        icon: Icon(
                          Icons.add_circle_outlined,
                          color: Theme.of(context).primaryColorLight,
                          size: 20,
                        )),
                  ),
                ],
              ),
            ),
            Divider(
              indent: 10,
              thickness: 1.3,
              color: Colors.grey,
            ),
            Expanded(
              child: ListView(
                children: [
                  inplandata.isEmpty
                      ? Center(
                          child: Container(
                              child: Column(
                          children: [
                            Container(
                              height: 30,
                            ),
                            Text(
                              '오늘은 휴식데이!',
                              textScaleFactor: 2.0,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              height: 20,
                            ),
                            Text(
                              '운동을 추가 하지 않으면 휴식일입니다.',
                              textScaleFactor: 1.2,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              height: 30,
                            ),
                          ],
                        )))
                      : Container(
                          child: ListView.builder(
                            physics: new NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext _context, int index) {
                              Controllerlist.add(ExpandableController(
                                initialExpanded: true,
                              ));
                              return Container(
                                child: Column(
                                  children: [
                                    ExpandablePanel(
                                        controller: Controllerlist[index],
                                        theme: ExpandableThemeData(
                                          headerAlignment:
                                              ExpandablePanelHeaderAlignment
                                                  .center,
                                          hasIcon: true,
                                          iconColor: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                        header: Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                child: Text(
                                                    inplandata[index].name,
                                                    textScaleFactor: 1.7,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColorLight)),
                                                onTap: () {
                                                  exselect(false, true, index);
                                                },
                                              ),
                                              Container(
                                                width: 10,
                                              ),
                                              inplandata[index].sets.isEmpty
                                                  ? Transform.scale(
                                                      scale: 1.2,
                                                      child: IconButton(
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          constraints:
                                                              BoxConstraints(),
                                                          onPressed: () {
                                                            workout
                                                                .plansetsplus(
                                                                    widget
                                                                        .rindex,
                                                                    index);
                                                            _editWorkoutCheck();
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .add_circle_outlined,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorLight,
                                                            size: 20,
                                                          )),
                                                    )
                                                  : Container(
                                                      child: GestureDetector(
                                                        child: Text(
                                                          '기준: ${inplandata[index].ref_name}',
                                                          textScaleFactor: 1.2,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        onTap: () {
                                                          exselect(false, false,
                                                              index);
                                                        },
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ),
                                        collapsed:
                                            Container(), // body when the widget is Collapsed, I didnt need anything here.
                                        expanded: Container(
                                          child: ListView.builder(
                                            physics:
                                                new NeverScrollableScrollPhysics(),
                                            itemBuilder: (BuildContext _context,
                                                int setindex) {
                                              var refinfo = uniqexinfo[
                                                  uniqexinfo.indexWhere(
                                                      (element) =>
                                                          element.name ==
                                                          inplandata[index]
                                                              .ref_name)];
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(),
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        child: Container(
                                                          child: Text(
                                                            '${((inplandata[index].sets[setindex].weight * refinfo.onerm / 100 / 2.5).floor() * 2.5).toStringAsFixed(1)}kg  X  ${inplandata[index].sets[setindex].reps}',
                                                            textScaleFactor:
                                                                1.7,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorLight,
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setSetting(
                                                              index, setindex);
                                                        },
                                                      ),
                                                      Theme(
                                                        data: ThemeData(
                                                            unselectedWidgetColor:
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColorLight),
                                                        child: Checkbox(
                                                            materialTapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                            activeColor: Theme
                                                                    .of(context)
                                                                .primaryColor,
                                                            checkColor: Theme
                                                                    .of(context)
                                                                .primaryColorLight,
                                                            value: inplandata[
                                                                    index]
                                                                .sets[setindex]
                                                                .ischecked,
                                                            onChanged:
                                                                (newvalue) {
                                                              workout
                                                                  .planboolcheck(
                                                                      widget
                                                                          .rindex,
                                                                      index,
                                                                      setindex,
                                                                      newvalue);
                                                            }),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                            shrinkWrap: true,
                                            itemCount:
                                                inplandata[index].sets.length,
                                          ),
                                        ) // body when the widget is Expanded
                                        ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 10,
                                        ),
                                        Container(
                                          width: 10,
                                        ),
                                        Transform.scale(
                                          scale: 1.2,
                                          child: IconButton(
                                              padding: EdgeInsets.all(5),
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                workout.plansetsminus(
                                                    widget.rindex, index);
                                                _editWorkoutCheck();
                                              },
                                              icon: Icon(
                                                Icons.remove_circle_outlined,
                                                color: Theme.of(context)
                                                    .primaryColorLight,
                                                size: 20,
                                              )),
                                        ),
                                        Container(
                                          width: 10,
                                        ),
                                        Transform.scale(
                                          scale: 1.2,
                                          child: IconButton(
                                              padding: EdgeInsets.all(5),
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                workout.plansetsplus(
                                                    widget.rindex, index);
                                                _editWorkoutCheck();
                                              },
                                              icon: Icon(
                                                Icons.add_circle_outlined,
                                                color: Theme.of(context)
                                                    .primaryColorLight,
                                                size: 20,
                                              )),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      indent: 10,
                                      thickness: 1.3,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              );
                            },
                            shrinkWrap: true,
                            itemCount: inplandata.length,
                          ),
                        ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: IconButton(
                              padding: EdgeInsets.all(5),
                              constraints: BoxConstraints(),
                              onPressed: () {
                                workout.planremoveexAt(widget.rindex);
                                _editWorkoutCheck();
                              },
                              icon: Icon(
                                Icons.remove_circle_outlined,
                                color: Theme.of(context).primaryColorLight,
                                size: 20,
                              )),
                        ),
                        Container(
                          width: 10,
                        ),
                        Container(
                            child: Text(
                          '/',
                          textScaleFactor: 1.7,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                        )),
                        Container(
                          width: 10,
                        ),
                        Transform.scale(
                          scale: 1.2,
                          child: IconButton(
                              padding: EdgeInsets.all(5),
                              constraints: BoxConstraints(),
                              onPressed: () {
                                exselect(true, false);
                                exselect(true, true);
                              },
                              icon: Icon(
                                Icons.add_circle_outlined,
                                color: Theme.of(context).primaryColorLight,
                                size: 20,
                              )),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                        child: Text(
                      '운동 제거/추가',
                      textScaleFactor: 1.2,
                      style: TextStyle(color: Colors.grey),
                    )),
                  )
                ],
              ),
            ),
            Container(child: Consumer<RoutineTimeProvider>(
                builder: (context, provider, child) {
              return Center(
                child: Text(
                    provider.timeron < 0
                        ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                        : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}',
                    textScaleFactor: 2.0,
                    style: TextStyle(
                        color: (provider.userest && provider.timeron < 0)
                            ? Colors.red
                            : Theme.of(context).primaryColorLight)),
              );
            })),
            Container(child: Consumer<RoutineTimeProvider>(
                builder: (builder, provider, child) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: (provider.nowonrindex != widget.rindex) &&
                            _routinetimeProvider.isstarted
                        ? Color(0xFF212121)
                        : provider.buttoncolor,
                    textStyle: const TextStyle(fontSize: 20)),
                onPressed: () {
                  (provider.nowonrindex != widget.rindex) &&
                          _routinetimeProvider.isstarted
                      ? null
                      : [
                          if (_routinetimeProvider.isstarted)
                            {_displayFinishAlert()}
                          else
                            {provider.routinecheck(widget.rindex)}
                        ];
                },
                child: Text((provider.nowonrindex != widget.rindex) &&
                        _routinetimeProvider.isstarted
                    ? '다른 루틴 수행중'
                    : provider.routineButton),
              );
            })),
          ],
        ),
      );
    });
  }

  void setSetting(int eindex, int sindex) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: _setinfo(eindex, sindex));
      },
    );
  }

  Widget _setinfo(int eindex, int sindex) {
    return Consumer2<WorkoutdataProvider, ExercisesdataProvider>(
        builder: (builder, workout, exinfo, child) {
      var plandata =
          workout.workoutdata.routinedatas[widget.rindex].exercises[0];
      var inplandata = plandata.plans[plandata.progress].exercises;
      var exdata = plandata.plans[plandata.progress].exercises[eindex];
      var setdata = exdata.sets[sindex];
      var uniqexinfo = exinfo.exercisesdata.exercises[exinfo
          .exercisesdata.exercises
          .indexWhere((element) => element.name == exdata.ref_name)];
      _weightctrl.text = setdata.weight.toString();
      _repsctrl.text = setdata.reps.toString();
      double changeweight = 0.0;
      int changereps = 1;
      return Container(
        child: Column(
          children: [
            Container(
              height: 15,
            ),
            Container(
              child: Text(
                '기준 운동: ${uniqexinfo.name}',
                textScaleFactor: 1.7,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Center(
                      child: Text(
                    '나의 1rm',
                    textScaleFactor: 1.7,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Center(
                      child: Text(
                    '중량비(%)',
                    textScaleFactor: 1.7,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Center(
                      child: Text(
                    '횟수',
                    textScaleFactor: 1.7,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3 - 10,
                  child: Center(
                      child: Text(
                    uniqexinfo.onerm.toStringAsFixed(1),
                    textScaleFactor: 1.7,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3 - 10,
                  child: Center(
                    child: TextField(
                      controller: _weightctrl,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                      style: TextStyle(
                        fontSize: 21,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 3, color: Colors.grey)),
                        hintText: "${setdata.weight}",
                        hintStyle: TextStyle(
                          fontSize: 21,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      onChanged: (text) {
                        if (text == "") {
                          changeweight = 0.0;
                        } else {
                          changeweight = double.parse(text);
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3 - 10,
                  child: Center(
                    child: TextField(
                      controller: _repsctrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 21,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 3, color: Colors.grey)),
                        hintText: "${setdata.weight}",
                        hintStyle: TextStyle(
                          fontSize: 21,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      onChanged: (text) {
                        if (text == "") {
                          changereps = 1;
                        } else {
                          changereps = int.parse(text);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 50)),
                    ),
                    onPressed: () {
                      workout.plansetcheck(
                          widget.rindex,
                          eindex,
                          sindex,
                          double.parse(_weightctrl.text),
                          int.parse(_repsctrl.text));
                      Navigator.pop(context);
                      _editWorkoutCheck();
                    },
                    child: Text(
                      '완료',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                Container(
                  width: 10,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void exselect(bool isadd, bool isex, [int where = 0]) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: Center(
                child: _exercises_searchWidget(isadd, isex, where, state)),
          );
        });
      },
    );
  }

  Widget _exercises_searchWidget(
      bool isadd, bool isex, int where, StateSetter state) {
    return Column(
      children: [
        Container(
          height: 15,
        ),
        Container(
          child: Text(
            isex ? '운동을 선택해주세요' : '1RM 기준 운동을 선택해주세요',
            textScaleFactor: 1.7,
            style: TextStyle(
                color: Color(0xFF212121), fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: TextField(
              style: TextStyle(color: Theme.of(context).primaryColorLight),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColorLight,
                ),
                hintText: "Exercise Name",
                hintStyle: TextStyle(
                    fontSize: 20.0, color: Theme.of(context).primaryColorLight),
              ),
              onChanged: (text) {
                searchExercise(text.toString(), state);
              }),
        ),
        exercisesWidget(_testdata, true, isadd, isex, where)
      ],
    );
  }

  void searchExercise(String query, StateSetter updateState) {
    final suggestions = _testdata0.where((exercise) {
      final exTitle = exercise.name;
      return (exTitle.contains(query)) as bool;
    }).toList();

    updateState(() => _testdata = suggestions);
  }

  Widget exercisesWidget(
      exuniq, bool shirink, bool isadd, bool isex, int where) {
    double top = 0;
    double bottom = 0;
    return Expanded(
      //color: Colors.black,
      child: Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
        return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 5),
            itemBuilder: (BuildContext _context, int index) {
              if (index == 0) {
                top = 20;
                bottom = 0;
              } else if (index == exuniq.length - 1) {
                top = 0;
                bottom = 20;
              } else {
                top = 0;
                bottom = 0;
              }
              ;
              return GestureDetector(
                onTap: () {
                  if (isadd) {
                    if (isex) {
                      _addexinput = exuniq[index].name;
                      Navigator.pop(context);
                    } else {
                      _workoutProvider.planaddexAt(
                          widget.rindex,
                          new Plan_Exercises(
                              name: _addexinput,
                              ref_name: exuniq[index].name,
                              sets: [
                                Sets(
                                    index: 1,
                                    weight: 0.0,
                                    reps: 1,
                                    ischecked: false)
                              ],
                              rest: 0));

                      Navigator.pop(context);
                      _editWorkoutCheck();
                    }
                  } else if (isex) {
                    _workoutProvider.planchangeexnameAt(
                        widget.rindex, where, exuniq[index].name);
                    Navigator.pop(context);
                    _editWorkoutCheck();
                  } else {
                    _workoutProvider.planchangeexrefnameAt(
                        widget.rindex, where, exuniq[index].name);
                    Navigator.pop(context);
                    _editWorkoutCheck();
                  }
                  ;
                },
                child: Container(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(top),
                            bottomRight: Radius.circular(bottom),
                            topLeft: Radius.circular(top),
                            bottomLeft: Radius.circular(bottom))),
                    height: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exuniq[index].name,
                          textScaleFactor: 1.7,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                        ),
                        Container(
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Rest: need to set",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(color: Color(0xFF717171))),
                              Expanded(child: SizedBox()),
                              Text(
                                  "1RM: ${exuniq[index].onerm.toStringAsFixed(1)}/${exuniq[index].goal.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(color: Color(0xFF717171))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext _context, int index) {
              return Container(
                alignment: Alignment.center,
                height: 1,
                color: Color(0xFF212121),
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 1,
                  color: Color(0xFF717171),
                ),
              );
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: shirink,
            itemCount: exuniq.length);
      }),
    );
  }

  void recordExercise() {
    var exercise_all = _workoutProvider
        .workoutdata
        .routinedatas[widget.rindex]
        .exercises[0]
        .plans[_workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[0].progress]
        .exercises;
    for (int n = 0; n < exercise_all.length; n++) {
      var recordedsets = exercise_all[n].sets.where((sets) {
        return (sets.ischecked as bool && sets.weight != 0);
      }).toList();
      double monerm = 0;
      for (int i = 0; i < recordedsets.length; i++) {
        if (recordedsets[i].reps != 1) {
          if (monerm <
              recordedsets[i].weight * (1 + recordedsets[i].reps / 30)) {
            monerm = recordedsets[i].weight * (1 + recordedsets[i].reps / 30);
          }
        } else if (monerm < recordedsets[i].weight) {
          monerm = recordedsets[i].weight;
        }
      }
      var _eachex = _exercises[_exercises
          .indexWhere((element) => element.name == exercise_all[n].name)];
      if (!recordedsets.isEmpty) {
        exerciseList.add(hisdata.Exercises(
            name: exercise_all[n].name,
            sets: recordedsets,
            onerm: monerm,
            goal: _eachex.goal,
            date: DateTime.now().toString().substring(0, 10),
            isCardio: _eachex.category == "유산소" ? true : false));
      }
      if (monerm > _eachex.onerm) {
        modifyExercise(monerm, exercise_all[n].name);
      }
    }
    _postExerciseCheck();
  }

  void _editHistoryCheck() async {
    if (!exerciseList.isEmpty) {
      HistoryPost(
              user_email: _userProvider.userdata.email,
              exercises: exerciseList,
              new_record: _routinetimeProvider.routineNewRecord,
              workout_time: _routinetimeProvider.routineTime,
              nickname: _userProvider.userdata.nickname)
          .postHistory()
          .then((data) => data["user_email"] != null
              ? {
                  Navigator.push(
                      context,
                      Transition(
                          child: ExerciseDone(
                              exerciseList: exerciseList,
                              routinetime: _routinetimeProvider.routineTime,
                              sdbdata: hisdata.SDBdata.fromJson(data)),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT)),
                  _routinetimeProvider.routinecheck(widget.rindex),
                  _prefsProvider.lastplan(_workoutProvider
                      .workoutdata.routinedatas[widget.rindex].name),
                  _hisProvider.getdata(),
                  _hisProvider.getHistorydataAll(),
                  exerciseList = []
                }
              : showToast("입력을 확인해주세요"));
    } else {
      _routinetimeProvider.routinecheck(widget.rindex);
    }
  }

  void modifyExercise(double newonerm, exname) {
    _exercises[_exercises.indexWhere((element) => element.name == exname)]
        .onerm = newonerm;
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userProvider.userdata.email, exercises: _exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  void _editWorkoutCheck() async {
    WorkoutEdit(
            user_email: _userProvider.userdata.email,
            id: _workoutProvider.workoutdata.id,
            routinedatas: _workoutProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? [showToast("done!"), _workoutProvider.getdata()]
            : showToast("입력을 확인해주세요"));
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercises = _exProvider.exercisesdata.exercises;
    _testdata0 = _exProvider.exercisesdata.exercises;
    _prefsProvider = Provider.of<PrefsProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _PopProvider.tutorpopoff();
    return Consumer<PopProvider>(builder: (Builder, provider, child) {
      bool _popable = provider.isstacking;
      _popable == false
          ? null
          : [
              provider.exstackdown(),
              provider.popoff(),
              Future.delayed(Duration.zero, () async {
                Navigator.of(context).pop();
              })
            ];
      bool _tutorpop = provider.tutorpop;
      _tutorpop == false
          ? null
          : [
              provider.exstackup(0),
              Future.delayed(Duration.zero, () async {
                Navigator.of(context).popUntil((route) => route.isFirst);
                _PopProvider.tutorpopoff();
              })
            ];

      return Scaffold(
        appBar: _appbarWidget(),
        body: _Nday_RoutineWidget(),
      );
    });
  }
}
