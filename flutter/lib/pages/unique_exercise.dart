import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;

class UniqueExerciseDetails extends StatefulWidget {
  int ueindex;

  UniqueExerciseDetails({Key? key, required this.ueindex}) : super(key: key);

  @override
  _UniqueExerciseDetailsState createState() => _UniqueExerciseDetailsState();
}

class _UniqueExerciseDetailsState extends State<UniqueExerciseDetails> {
  var _userdataProvider;
  var _historydataProvider;
  var _exercisesdataProvider;
  var _workoutdataProvider;
  var _routinetimeProvider;
  var _exercise;
  var _uniqinfo;
  bool _isstarted = false;
  bool _isChecked = false;
  double top = 0;
  double bottom = 0;
  double? weight;
  int? reps;
  List<TextEditingController> weightController = [];
  List<TextEditingController> repsController = [];
  TextEditingController _resttimectrl = TextEditingController(text: "");
  var runtime = 0;
  Timer? timer1;
  late List<hisdata.Exercises> exerciseList = [];
  var _exampleex;
  var _sets = wod.Setslist().setslist;
  var btnDisabled;

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
          _routinetimeProvider.isstarted
              ? _displayFinishAlert()
              : btnDisabled == true
                  ? null
                  : [
                      Navigator.of(context).pop(),
                      btnDisabled = true,
                      _routinetimeProvider.resttimecheck(0)
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

  void _displayFinishAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Workout Finish Alert',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('????????? ??????????????????????'),
            actions: <Widget>[
              _FinishConfirmButton(),
            ],
          );
        });
  }

  Widget _FinishConfirmButton() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledColor: Color.fromRGBO(246, 58, 64, 20),
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    _routinetimeProvider.routinecheck(0);
                    recordExercise();
                    _editHistoryCheck();
                    _routinetimeProvider.resttimecheck(0);
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text("Confirm",
                      style: TextStyle(fontSize: 20.0, color: Colors.white)))),
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  disabledColor: Color.fromRGBO(246, 58, 64, 20),
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("Cancel",
                      style: TextStyle(fontSize: 20.0, color: Colors.white))))
        ],
      ),
    );
  }

  Widget _exercisedetailWidget() {
    _exampleex = new wod.Exercises(
        name:
            _exercisesdataProvider.exercisesdata.exercises[widget.ueindex].name,
        sets: _sets,
        onerm: _exercisesdataProvider
            .exercisesdata.exercises[widget.ueindex].onerm,
        rest: 0);
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.white;
    }

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
            Container(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _routinetimeProvider.restcheck();
                    _routinetimeProvider
                        .resttimecheck(int.parse(_resttimectrl.text));
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
                    _displaySetRestAlert();
                  },
                  child: Consumer<RoutineTimeProvider>(
                      builder: (builder, provider, child) {
                    return Text(
                      "Rest: ${provider.changetime}",
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
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _exampleex.name.length < 8
                        ? Text(
                            _exampleex.name,
                            style: TextStyle(color: Colors.white, fontSize: 48),
                          )
                        : Text(
                            _exampleex.name,
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                    Consumer<ExercisesdataProvider>(
                        builder: (builder, provider, child) {
                      var _info =
                          provider.exercisesdata.exercises[widget.ueindex];
                      return Text(
                        "Best 1RM: ${_info.onerm}/${_info.goal.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
                        style:
                            TextStyle(color: Color(0xFF717171), fontSize: 21),
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
                        width: 80,
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
            Expanded(
                child: ListView.separated(
                    itemBuilder: (BuildContext _context, int index) {
                      weightController.add(new TextEditingController());
                      repsController.add(new TextEditingController());
                      return Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Transform.scale(
                                      scale: 1.2,
                                      child: Checkbox(
                                          checkColor: Colors.black,
                                          fillColor:
                                              MaterialStateProperty.resolveWith(
                                                  getColor),
                                          value: _sets[index].ischecked,
                                          onChanged: (newvalue) {
                                            _routinetimeProvider.isstarted
                                                ? [
                                                    setState(() {
                                                      _sets[index].ischecked =
                                                          newvalue;
                                                    }),
                                                    newvalue == true
                                                        ? _routinetimeProvider
                                                            .resettimer(
                                                                _routinetimeProvider
                                                                    .changetime)
                                                        : null,
                                                  ]
                                                : _displayStartAlert(
                                                    index, newvalue);
                                          })),
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
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              child: TextField(
                                controller: weightController[index],
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 21,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "${_sets[index].weight}",
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
                                    changeweight = double.parse(text);
                                  }
                                  setState(() {
                                    _sets[index].weight = changeweight;
                                  });
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
                                controller: repsController[index],
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 21,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "${_sets[index].reps}",
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
                                    changereps = int.parse(text);
                                  }
                                  setState(() {
                                    _sets[index].reps = changereps;
                                  });
                                },
                              ),
                            ),
                            Container(
                                width: 70,
                                child: (_sets[index].reps != 1)
                                    ? Text(
                                        "${(_sets[index].weight * (1 + _sets[index].reps / 30)).toStringAsFixed(1)}",
                                        style: TextStyle(
                                            fontSize: 21, color: Colors.white),
                                        textAlign: TextAlign.center,
                                      )
                                    : Text(
                                        "${_sets[index].weight}",
                                        style: TextStyle(
                                            fontSize: 21, color: Colors.white),
                                        textAlign: TextAlign.center,
                                      )),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext _context, int index) {
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
                    itemCount: _sets.length)),
            Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
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
                              color: (provider.userest && provider.timeron < 0)
                                  ? Colors.red
                                  : Colors.white));
                    })),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _sets.removeLast();
                                });
                              },
                              icon: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 40,
                              )),
                        ),
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
                                _routinetimeProvider.resttimecheck(0);
                                Navigator.pop(context);
                              }
                              provider.resettimer(provider.changetime);
                              provider.routinecheck(0);
                            },
                            child: Text(provider.routineButton),
                          );
                        })),
                        Container(
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _sets.add(new wod.Sets(
                                      index: 0,
                                      weight: 0.0,
                                      reps: 1,
                                      ischecked: false));
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 40,
                              )),
                        )
                      ],
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  void recordExercise() {
    var recordedsets = _sets.where((sets) {
      return (sets.ischecked as bool && sets.weight != 0);
    }).toList();
    double monerm = 0;
    for (int i = 0; i < recordedsets.length; i++) {
      if (recordedsets[i].reps != 1) {
        if (monerm < recordedsets[i].weight * (1 + recordedsets[i].reps / 30)) {
          monerm = recordedsets[i].weight * (1 + recordedsets[i].reps / 30);
        }
      } else if (monerm < recordedsets[i].weight) {
        monerm = recordedsets[i].weight;
      }
    }
    if (!recordedsets.isEmpty) {
      exerciseList.add(hisdata.Exercises(
          name: _exampleex.name,
          sets: recordedsets,
          onerm: monerm,
          goal: _exercise[widget.ueindex].goal,
          date: DateTime.now().toString().substring(0, 10)));
    }

    if (monerm > _exampleex.onerm) {
      modifyExercise(monerm, _exampleex.name);
      _postExerciseCheck();
    }
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
              : showToast("????????? ??????????????????"));
    } else {
      print("no exercises");
    }
  }

  void modifyExercise(double newonerm, exname) {
    _exercise[_exercise.indexWhere((element) => element.name == exname)].onerm =
        newonerm;
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userdataProvider.userdata.email, exercises: _exercise)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("?????? ??????"), _exercisesdataProvider.getdata()}
            : showToast("????????? ??????????????????"));
  }

  void _displayStartAlert(sindex, newvalue) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Workout Start Alert',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('????????? ?????????????????????????'),
            actions: <Widget>[
              _StartConfirmButton(sindex, newvalue),
            ],
          );
        });
  }

  Widget _StartConfirmButton(sindex, newvalue) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledColor: Color.fromRGBO(246, 58, 64, 20),
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    _routinetimeProvider
                        .resettimer(_routinetimeProvider.changetime);
                    _routinetimeProvider.routinecheck(0);
                    setState(() {
                      _sets[sindex].ischecked = newvalue;
                    });
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("Confirm",
                      style: TextStyle(fontSize: 20.0, color: Colors.white)))),
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  disabledColor: Color.fromRGBO(246, 58, 64, 20),
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    newvalue = !newvalue;
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("Cancel",
                      style: TextStyle(fontSize: 20.0, color: Colors.white))))
        ],
      ),
    );
  }

  void _displaySetRestAlert() {
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
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  _resttimectrl.clear();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        });
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
    _exercise = _exercisesdataProvider.exercisesdata.exercises;

    return Scaffold(
      appBar: _appbarWidget(),
      body: _exercisedetailWidget(),
    );
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
