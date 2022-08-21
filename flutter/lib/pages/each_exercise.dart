import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/pages/exercise_done.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sdb_trainer/src/utils/customMotion.dart';
import 'package:transition/transition.dart';

class EachExerciseDetails extends StatefulWidget {
  int ueindex;
  int eindex;
  int rindex;
  EachExerciseDetails(
      {Key? key,
      required this.eindex,
      required this.ueindex,
      required this.rindex})
      : super(key: key);

  @override
  _EachExerciseDetailsState createState() => _EachExerciseDetailsState();
}

class _EachExerciseDetailsState extends State<EachExerciseDetails> {
  var _userdataProvider;
  var _historydataProvider;
  var _exercisesdataProvider;
  var _workoutdataProvider;
  var _routinetimeProvider;
  var _PopProvider;
  var _exercise;
  var _exercises;
  double top = 0;
  double bottom = 0;
  double? weight;
  int? reps;
  TextEditingController _resttimectrl = TextEditingController(text: "");
  List<Controllerlist> weightController = [];
  List<Controllerlist> repsController = [];
  PageController? controller;
  var btnDisabled;

  var runtime = 0;
  Timer? timer1;

  late List<hisdata.Exercises> exerciseList = [];

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined),
        onPressed: () {
          btnDisabled == true
              ? null
              : [
                  btnDisabled = true,
                  Navigator.of(context).pop(),
                  _editWorkoutCheck()
                ];
        },
      ),
      title: Text(
        "",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }

  void _editWorkoutCheck() async {
    if (_routinetimeProvider.isstarted) {
      WorkoutEdit(
              id: _workoutdataProvider.workoutdata.id,
              user_email: _userdataProvider.userdata.email,
              routinedatas: _workoutdataProvider.workoutdata.routinedatas)
          .editWorkout()
          .then((data) => data["user_email"] != null
              ? showToast("done!")
              : showToast("입력을 확인해주세요"));
    } else {
      var routinedatas_all = _workoutdataProvider.workoutdata.routinedatas;
      for (int n = 0;
          n < routinedatas_all[widget.rindex].exercises.length;
          n++) {
        for (int i = 0;
            i < routinedatas_all[widget.rindex].exercises[n].sets.length;
            i++) {
          routinedatas_all[widget.rindex].exercises[n].sets[i].ischecked =
              false;
        }
      }
      WorkoutEdit(
              id: _workoutdataProvider.workoutdata.id,
              user_email: _userdataProvider.userdata.email,
              routinedatas: routinedatas_all)
          .editWorkout()
          .then((data) => data["user_email"] != null
              ? showToast("done!")
              : showToast("입력을 확인해주세요"));
    }
  }

  void _editWorkoutwCheck() async {
    WorkoutEdit(
            id: _workoutdataProvider.workoutdata.id,
            user_email: _userdataProvider.userdata.email,
            routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? showToast("done!")
            : showToast("입력을 확인해주세요"));
  }

  void _editWorkoutwoCheck() async {
    var routinedatas_all = _workoutdataProvider.workoutdata.routinedatas;
    for (int n = 0; n < routinedatas_all[widget.rindex].exercises.length; n++) {
      for (int i = 0;
          i < routinedatas_all[widget.rindex].exercises[n].sets.length;
          i++) {
        routinedatas_all[widget.rindex].exercises[n].sets[i].ischecked = false;
      }
    }
    WorkoutEdit(
            id: _workoutdataProvider.workoutdata.id,
            user_email: _userdataProvider.userdata.email,
            routinedatas: routinedatas_all)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? showToast("done!")
            : showToast("입력을 확인해주세요"));
  }

  Widget _exercisedetailPage() {
    controller = PageController(initialPage: widget.eindex);
    int numEx = _workoutdataProvider
        .workoutdata.routinedatas[widget.rindex].exercises.length;
    for (int i = 0; i < numEx; i++) {
      weightController.add(new Controllerlist());
      repsController.add(new Controllerlist());
    }
    return PageView.builder(
      controller: controller,
      itemBuilder: (context, pindex) {
        return _exercisedetailWidget(pindex, context);
      },
      itemCount: numEx,
    );
  }

  Widget _exercisedetailWidget(pindex, context) {
    int ueindex = _exercisesdataProvider.exercisesdata.exercises.indexWhere(
        (element) =>
            element.name ==
            _workoutdataProvider.workoutdata.routinedatas[widget.rindex]
                .exercises[pindex].name);
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.white;
    }

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      print(isKeyboardVisible);
      print("teeeeeeeeeeeeeees");
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        color: Colors.black,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              isKeyboardVisible
                  ? SizedBox()
                  : Container(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _routinetimeProvider.restcheck();
                            _routinetimeProvider.resttimecheck(
                                _workoutdataProvider
                                    .workoutdata
                                    .routinedatas[widget.rindex]
                                    .exercises[pindex]
                                    .rest);
                          },
                          child: Consumer<RoutineTimeProvider>(
                              builder: (builder, provider, child) {
                            return Text(
                              provider.restbutton,
                              style: TextStyle(
                                color: provider.restbuttoncolor,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ),
                        GestureDetector(
                          onTap: () {
                            _displaySetRestAlert(pindex);
                          },
                          child: Consumer<WorkoutdataProvider>(
                              builder: (builder, provider, child) {
                            _exercise = provider.workoutdata
                                .routinedatas[widget.rindex].exercises[pindex];
                            return Text(
                              "Rest: ${_exercise.rest}",
                              style: TextStyle(
                                color: Color(0xFF717171),
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ),
                      ],
                    )),
              Container(
                  height: isKeyboardVisible ? 40 : 110,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<WorkoutdataProvider>(
                          builder: (builder, provider, child) {
                        var _exercise = provider.workoutdata
                            .routinedatas[widget.rindex].exercises[pindex];
                        return isKeyboardVisible
                            ? Text(
                                _exercise.name,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                              )
                            : _exercise.name.length < 8
                                ? Text(
                                    _exercise.name,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 48),
                                  )
                                : Text(
                                    _exercise.name,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40),
                                  );
                      }),
                      Consumer<ExercisesdataProvider>(
                          builder: (builder, provider, child) {
                        var _info = provider.exercisesdata.exercises[ueindex];
                        return isKeyboardVisible
                            ? Container()
                            : Text(
                                "Best 1RM: ${_info.onerm.toStringAsFixed(1)}/${_info.goal.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
                                style: TextStyle(
                                    color: Color(0xFF717171), fontSize: 21),
                              );
                      }),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(right: 10),
                  height: 25,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: 85,
                          padding: EdgeInsets.only(right: 4),
                          child: Text(
                            "Set",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          )),
                      Container(
                          width: 70,
                          child: Text(
                            "Weight(${_userdataProvider.userdata.weight_unit})",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                      Container(width: 35),
                      Container(
                          width: 40,
                          child: Text(
                            "Reps",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                      Container(
                          width: 70,
                          child: Text(
                            "1RM",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ],
                  )),
              Consumer<WorkoutdataProvider>(
                  builder: (builder, provider, child) {
                var _sets = provider.workoutdata.routinedatas[widget.rindex]
                    .exercises[pindex].sets;
                return Expanded(
                  child: Column(
                    children: [
                      Flexible(
                        child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (BuildContext _context, int index) {
                              weightController[pindex].controllerlist.add(
                                  new TextEditingController(
                                      text: _sets[index].weight == 0
                                          ? null
                                          : (_sets[index].weight % 1) == 0
                                              ? _sets[index]
                                                  .weight
                                                  .toStringAsFixed(0)
                                              : _sets[index]
                                                  .weight
                                                  .toStringAsFixed(1)));
                              repsController[pindex].controllerlist.add(
                                  new TextEditingController(
                                      text: _sets[index]
                                          .reps
                                          .toStringAsFixed(0)));
                              return Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 60,
                                      child: Transform.scale(
                                          scale: 1.2,
                                          child: Checkbox(
                                              checkColor: Colors.black,
                                              fillColor: MaterialStateProperty
                                                  .resolveWith(getColor),
                                              value: _sets[index].ischecked,
                                              onChanged: (newvalue) {
                                                _routinetimeProvider.isstarted
                                                    ? [
                                                        _workoutdataProvider
                                                            .boolcheck(
                                                                widget.rindex,
                                                                pindex,
                                                                index,
                                                                newvalue),
                                                        newvalue == true
                                                            ? _routinetimeProvider
                                                                .resettimer(provider
                                                                    .workoutdata
                                                                    .routinedatas[
                                                                        widget
                                                                            .rindex]
                                                                    .exercises[
                                                                        pindex]
                                                                    .rest)
                                                            : null,
                                                        _editWorkoutwCheck()
                                                      ]
                                                    : _displayStartAlert(pindex,
                                                        index, newvalue);
                                              })),
                                    ),
                                    Expanded(
                                      child: Slidable(
                                        startActionPane: ActionPane(
                                            extentRatio: 1.0,
                                            motion: CustomMotion(
                                              onOpen: () {
                                                _routinetimeProvider.isstarted
                                                    ? [
                                                        _workoutdataProvider
                                                            .boolcheck(
                                                                widget.rindex,
                                                                pindex,
                                                                index,
                                                                true),
                                                        _routinetimeProvider
                                                            .resettimer(provider
                                                                .workoutdata
                                                                .routinedatas[
                                                                    widget
                                                                        .rindex]
                                                                .exercises[
                                                                    pindex]
                                                                .rest),
                                                        _editWorkoutwCheck()
                                                      ]
                                                    : _displayStartAlert(
                                                        pindex, index, true);
                                              },
                                              onClose: () {
                                                print("onClose!!");
                                              },
                                              motionWidget: DrawerMotion(),
                                            ),
                                            children: [
                                              SlidableAction(
                                                autoClose: true,
                                                onPressed: (_) {},
                                                backgroundColor:
                                                    Color(0xFF29B6F6),
                                                foregroundColor: Colors.white,
                                                icon: Icons.check,
                                                label: '밀어서 check',
                                              )
                                            ]),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 25,
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                  fontSize: 21,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Container(
                                              width: 70,
                                              child: TextField(
                                                controller:
                                                    weightController[pindex]
                                                        .controllerlist[index],
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 21,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "${_sets[index].weight}",
                                                  hintStyle: TextStyle(
                                                    fontSize: 21,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onChanged: (text) {
                                                  double changeweight;
                                                  if (text == "") {
                                                    changeweight = 0.0;
                                                  } else {
                                                    changeweight =
                                                        double.parse(text);
                                                  }
                                                  _workoutdataProvider
                                                      .weightcheck(
                                                          widget.rindex,
                                                          pindex,
                                                          index,
                                                          changeweight);
                                                },
                                              ),
                                            ),
                                            Container(
                                                width: 35,
                                                child: SvgPicture.asset(
                                                    "assets/svg/multiply.svg",
                                                    color: Colors.white,
                                                    height: 19)),
                                            Container(
                                              width: 40,
                                              child: TextField(
                                                controller:
                                                    repsController[pindex]
                                                        .controllerlist[index],
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 21,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "${_sets[index].reps}",
                                                  hintStyle: TextStyle(
                                                    fontSize: 21,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onChanged: (text) {
                                                  int changereps;
                                                  if (text == "") {
                                                    changereps = 1;
                                                  } else {
                                                    changereps =
                                                        int.parse(text);
                                                  }
                                                  _workoutdataProvider
                                                      .repscheck(
                                                          widget.rindex,
                                                          pindex,
                                                          index,
                                                          changereps);
                                                },
                                              ),
                                            ),
                                            Container(
                                                width: 70,
                                                child: (_sets[index].reps != 1)
                                                    ? Text(
                                                        "${(_sets[index].weight * (1 + _sets[index].reps / 30)).toStringAsFixed(1)}",
                                                        style: TextStyle(
                                                            fontSize: 21,
                                                            color:
                                                                Colors.white),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    : Text(
                                                        "${_sets[index].weight}",
                                                        style: TextStyle(
                                                            fontSize: 21,
                                                            color:
                                                                Colors.white),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext _context, int index) {
                              return Container(
                                alignment: Alignment.center,
                                height: 1,
                                color: Colors.black,
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 1,
                                  color: Color(0xFF717171),
                                ),
                              );
                            },
                            itemCount: _sets.length),
                      ),
                      Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  _workoutdataProvider.setsminus(
                                      widget.rindex, pindex);
                                },
                                icon: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 24,
                                )),
                            IconButton(
                                onPressed: () {
                                  _workoutdataProvider.setsplus(
                                      widget.rindex, pindex);
                                  weightController[pindex]
                                      .controllerlist
                                      .clear();
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),
              Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(child: Consumer<RoutineTimeProvider>(
                              builder: (context, provider, child) {
                            return Text(
                                provider.userest
                                    ? provider.timeron < 0
                                        ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                        : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                    : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: (provider.userest &&
                                            provider.timeron < 0)
                                        ? Colors.red
                                        : Colors.white));
                          })),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              child: pindex != 0
                                  ? Container(
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                controller!.previousPage(
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.easeInOut);
                                              },
                                              icon: Icon(
                                                Icons.arrow_back_ios_outlined,
                                                color: Colors.white,
                                                size: 40,
                                              )),
                                          Consumer<WorkoutdataProvider>(builder:
                                              (builder, provider, child) {
                                            return Expanded(
                                                child: Text(
                                              provider
                                                  .workoutdata
                                                  .routinedatas[widget.rindex]
                                                  .exercises[pindex - 1]
                                                  .name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ));
                                          })
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      child: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            null,
                                            color: Colors.white,
                                            size: 40,
                                          )),
                                    )),
                          Container(child: Consumer<RoutineTimeProvider>(
                              builder: (builder, provider, child) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: provider.buttoncolor,
                                  textStyle: const TextStyle(fontSize: 20)),
                              onPressed: () {
                                if (_routinetimeProvider.isstarted) {
                                  recordExercise();
                                  _editHistoryCheck();
                                  _editWorkoutwoCheck();
                                  Navigator.push(
                                      context,
                                      Transition(
                                          child: ExerciseDone(
                                              exerciseList: exerciseList,
                                              routinetime: _routinetimeProvider
                                                  .routineTime),
                                          transitionEffect:
                                              TransitionEffect.RIGHT_TO_LEFT));
                                }
                                provider.routinecheck(widget.rindex);
                              },
                              child: Text(provider.routineButton),
                            );
                          })),
                          Container(
                              child: pindex !=
                                      _workoutdataProvider
                                              .workoutdata
                                              .routinedatas[widget.rindex]
                                              .exercises
                                              .length -
                                          1
                                  ? Container(
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Consumer<WorkoutdataProvider>(builder:
                                              (builder, provider, child) {
                                            return Expanded(
                                                child: Text(
                                              provider
                                                  .workoutdata
                                                  .routinedatas[widget.rindex]
                                                  .exercises[pindex + 1]
                                                  .name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ));
                                          }),
                                          IconButton(
                                              onPressed: () {
                                                controller!.nextPage(
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.easeInOut);
                                              },
                                              icon: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                color: Colors.white,
                                                size: 40,
                                              )),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      child: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            null,
                                            color: Colors.white,
                                            size: 40,
                                          )),
                                    ))
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ),
      );
    });
  }

  void _displaySetRestAlert(pindex) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Set Rest Time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: _resttimectrl,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 21,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Type Resting time",
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              onChanged: (text) {
                int changetime;
                changetime = int.parse(text);
                _routinetimeProvider.resttimecheck(changetime);
              },
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Text('OK'),
                onPressed: () {
                  _workoutdataProvider.resttimecheck(
                      widget.rindex, pindex, _routinetimeProvider.changetime);
                  _editWorkoutwCheck();
                  _resttimectrl.clear();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        });
  }

  void _displayStartAlert(pindex, sindex, newvalue) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Workout Start Alert',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('운동을 시작하시겠습니까?'),
            actions: <Widget>[
              _StartConfirmButton(pindex, sindex, newvalue),
            ],
          );
        });
  }

  Widget _StartConfirmButton(pindex, sindex, newvalue) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: TextButton(
                  onPressed: () {
                    newvalue = !newvalue;
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("Cancel",
                      style: TextStyle(fontSize: 20.0, color: Colors.red)))),
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: TextButton(
                  onPressed: () {
                    _routinetimeProvider.resettimer(_workoutdataProvider
                        .workoutdata
                        .routinedatas[widget.rindex]
                        .exercises[pindex]
                        .rest);
                    _routinetimeProvider.routinecheck(widget.rindex);
                    _workoutdataProvider.boolcheck(
                        widget.rindex, pindex, sindex, newvalue);
                    _editWorkoutwCheck();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("Confirm",
                      style: TextStyle(fontSize: 20.0, color: Colors.blue)))),
        ],
      ),
    );
  }

  void recordExercise() {
    var exercise_all =
        _workoutdataProvider.workoutdata.routinedatas[widget.rindex].exercises;
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
            date: DateTime.now().toString().substring(0, 10)));
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
              user_email: _userdataProvider.userdata.email,
              exercises: exerciseList,
              new_record: 120,
              workout_time: _routinetimeProvider.routineTime,
              nickname: _userdataProvider.userdata.nickname)
          .postHistory()
          .then((data) => data["user_email"] != null
              ? {
                  _historydataProvider.getdata(),
                  _historydataProvider.getHistorydataAll(),
                  exerciseList = []
                }
              : showToast("입력을 확인해주세요"));
    } else {
      print("no exercises");
    }
  }

  void modifyExercise(double newonerm, exname) {
    _exercises[_exercises.indexWhere((element) => element.name == exname)]
        .onerm = newonerm;
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userdataProvider.userdata.email, exercises: _exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exercisesdataProvider.getdata()}
            : showToast("입력을 확인해주세요"));
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

    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercises = _exercisesdataProvider.exercisesdata.exercises;
    _PopProvider = Provider.of<PopProvider>(context, listen: false);

    return Scaffold(
      appBar: _appbarWidget(),
      body: _exercisedetailPage(),
    );
  }
}
