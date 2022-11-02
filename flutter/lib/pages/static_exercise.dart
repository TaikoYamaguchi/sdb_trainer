import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:flutter_slidable/flutter_slidable.dart';

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
  var _originExercise;
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
    _originExercise = widget.exercise;
    _exampleex = wod.Exercises(
        name: widget.exercise.name, sets: widget.exercise.sets, rest: 0);
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("", style: TextStyle(color: Colors.white)),
              GestureDetector(
                  onTap: () {
                    _deleteExerciseCheck();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text("운동 삭제",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  )),
            ],
          ),
          backgroundColor: Color(0xFF101012),
        ));
  }

  Widget _exercisedetailWidget() {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
      };
      if (states.any(interactiveStates.contains)) {
        return Theme.of(context).primaryColor;
      }
      return Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      color: Color(0xFF101012),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                            style: TextStyle(color: Colors.white, fontSize: 32),
                          ),
                    Text(
                      "Best 1RM: ${widget.exercise.onerm!.toStringAsFixed(1)}/${widget.exercise.goal!.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
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
                child: Column(
              children: [
                Flexible(
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (BuildContext _context, int index) {
                        weightController.add(new TextEditingController());
                        repsController.add(new TextEditingController());
                        return Container(
                            padding: EdgeInsets.only(right: 10),
                            child: Slidable(
                              endActionPane: ActionPane(
                                  extentRatio: 0.2,
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) {
                                        setState(() {
                                          widget.exercise.sets.removeAt(index);
                                        });
                                        weightController.clear();
                                        repsController.clear();
                                      },
                                      backgroundColor: Color(0xFFFE4A49),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    )
                                  ]),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                checkColor: Color(0xFF101012),
                                                fillColor: MaterialStateProperty
                                                    .resolveWith(getColor),
                                                value: widget.exercise
                                                    .sets[index].ischecked,
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
                                      child:
                                          (widget.exercise.sets[index].reps !=
                                                  1)
                                              ? Text(
                                                  "${(widget.exercise.sets[index].weight * (1 + widget.exercise.sets[index].reps / 30)).toStringAsFixed(1)}",
                                                  style: TextStyle(
                                                      fontSize: 21,
                                                      color: Colors.white),
                                                  textAlign: TextAlign.center,
                                                )
                                              : Text(
                                                  "${widget.exercise.sets[index].weight}",
                                                  style: TextStyle(
                                                      fontSize: 21,
                                                      color: Colors.white),
                                                  textAlign: TextAlign.center,
                                                )),
                                ],
                              ),
                            ));
                      },
                      separatorBuilder: (BuildContext _context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          height: 1,
                          color: Color(0xFF101012),
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            height: 1,
                            color: Color(0xFF717171),
                          ),
                        );
                      },
                      itemCount: widget.exercise.sets.length),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            widget.exercise.sets.removeLast();
                          });
                        },
                        icon: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 24,
                        )),
                    IconButton(
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
                          size: 24,
                        )),
                  ],
                ),
              ],
            )),
            Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
    if (!widget.exercise.sets
        .where((sets) {
          return (sets.ischecked as bool && sets.weight != 0);
        })
        .toList()
        .isEmpty) {
      HistoryExercisesEdit(
              history_id: widget.history_id,
              user_email: _userdataProvider.userdata.email,
              exercises: widget.origin_exercises)
          .patchHistoryExercises()
          .then((data) => data["user_email"] != null
              ? {showToast("수정 완료"), Navigator.of(context).pop()}
              : showToast("입력을 확인해주세요"));
    } else {
      _deleteExerciseCheck();
    }
  }

  void _deleteExerciseCheck() async {
    _historydataProvider.deleteExercisedata(widget.history_id, widget.index);
    if (!widget.origin_exercises.isEmpty) {
      HistoryExercisesEdit(
              history_id: widget.history_id,
              user_email: _userdataProvider.userdata.email,
              exercises: widget.origin_exercises)
          .patchHistoryExercises()
          .then((data) => data["user_email"] != null
              ? {showToast("수정 완료"), Navigator.of(context).pop()}
              : showToast("입력을 확인해주세요"));
    } else {
      _historydataProvider.deleteHistorydata(widget.history_id);
      HistoryDelete(history_id: widget.history_id).deleteHistory().then(
          (data) => data["user_email"] != null
              ? {showToast("수정 완료"), Navigator.of(context).pop()}
              : showToast("입력을 확인해주세요"));
    }
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _historydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
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
