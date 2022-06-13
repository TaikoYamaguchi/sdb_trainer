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

class StaticsExerciseDetails extends StatefulWidget {
  hisdata.Exercises exercise;
  int index;
  List<hisdata.Exercises> origin_exercises;
  int history_id;

  StaticsExerciseDetails(
      {Key? key,
      required this.exercise,
      required this.index,
      required this.origin_exercises,
      required this.history_id})
      : super(key: key);

  @override
  _StaticsExerciseDetailsState createState() => _StaticsExerciseDetailsState();
}

class _StaticsExerciseDetailsState extends State<StaticsExerciseDetails> {
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
  var runtime = 0;
  Timer? timer1;
  late List<hisdata.Exercises> exerciseList = [];
  var _exampleex;
  var _sets = wod.Setslist().setslist;

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _exercisedetailWidget() {
    _exampleex = new wod.Exercises(
        name: widget.exercise.name,
        sets: widget.exercise.sets,
        onerm: widget.exercise.onerm,
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
                Text(
                  "Rest Timer off",
                  style: TextStyle(
                    color: Color(0xFF717171),
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Rest: ${_exampleex.rest}",
                  style: TextStyle(
                    color: Color(0xFF717171),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            )),
            Container(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _exampleex.name,
                      style: TextStyle(color: Colors.white, fontSize: 48),
                    ),
                    Text(
                      "Best 1RM: ${widget.exercise.onerm}/${widget.exercise.goal!.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
                      style: TextStyle(color: Color(0xFF717171), fontSize: 21),
                    )
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
                                          value: widget
                                              .exercise.sets[index].ischecked,
                                          onChanged: (newvalue) {
                                            setState(() {
                                              widget.exercise.sets[index]
                                                  .ischecked = newvalue;
                                            });
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
                                  hintText:
                                      "${widget.exercise.sets[index].weight}",
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
                                    widget.exercise.sets[index].weight =
                                        changeweight;
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
                                  hintText:
                                      "${widget.exercise.sets[index].reps}",
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
                                    widget.exercise.sets[index].reps =
                                        changereps;
                                  });
                                },
                              ),
                            ),
                            Container(
                                width: 70,
                                child: (widget.exercise.sets[index].reps != 1)
                                    ? Text(
                                        "${(widget.exercise.sets[index].weight * (1 + widget.exercise.sets[index].reps / 30)).toStringAsFixed(1)}",
                                        style: TextStyle(
                                            fontSize: 21, color: Colors.white),
                                        textAlign: TextAlign.center,
                                      )
                                    : Text(
                                        "${widget.exercise.sets[index].weight}",
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
                    itemCount: widget.exercise.sets.length)),
            Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.exercise.sets.removeLast();
                                });
                              },
                              icon: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 40,
                              )),
                        ),
                        Container(
                            child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20)),
                          onPressed: () {
                            if (true) {
                              recordExercise();
                              _editHistoryCheck();
                            }
                          },
                          child: Text("운동 수정 하기"),
                        )),
                        Container(
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.exercise.sets.add(new wod.Sets(
                                      index: 0,
                                      weight: 0.0,
                                      reps: 1,
                                      ischecked: true));
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
    var recordedsets = widget.exercise.sets.where((sets) {
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
      widget.origin_exercises[widget.index] = (hisdata.Exercises(
          name: _exampleex.name,
          sets: recordedsets,
          onerm: monerm,
          goal: widget.exercise.goal,
          date: widget.exercise.date));
    }
  }

  void _editHistoryCheck() async {
    print(widget.origin_exercises);
    print("this is historyyyyyyyyyyy");
    if (!widget.origin_exercises.isEmpty) {
      HistoryExercisesEdit(
              history_id: widget.history_id,
              user_email: _userdataProvider.userdata.email,
              exercises: widget.origin_exercises)
          .patchHistoryExercises()
          .then((data) => data["user_email"] != null
              ? showToast("수정 완료")
              : showToast("입력을 확인해주세요"));
    } else {
      print("no exercises");
    }
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
