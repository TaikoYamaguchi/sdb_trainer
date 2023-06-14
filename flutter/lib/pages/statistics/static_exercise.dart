import 'dart:async';
import 'package:flutter/cupertino.dart';
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
import 'package:sdb_trainer/providers/themeMode.dart';

// ignore: must_be_immutable
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
  var _userProvider;
  var _hisProvider;
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
  var _themeProvider;
  Duration initialTimer = const Duration();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: _appbarWidget(),
      body: _exercisedetailWidget(),
    );
  }

  Widget _buildContainer(Widget picker) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: CupertinoColors.white,
      ),
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Container(
              height: 6.0,
              width: 80.0,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            ),
          ),
          DefaultTextStyle(
            style: const TextStyle(
              color: CupertinoColors.black,
              fontSize: 22.0,
            ),
            child: GestureDetector(
              onTap: () {},
              child: SafeArea(
                top: false,
                child: picker,
              ),
            ),
          ),
        ],
      ),
    );
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("",
                  style: TextStyle(color: Theme.of(context).primaryColorLight)),
              GestureDetector(
                  onTap: () {
                    _deleteExerciseCheck();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text("운동 삭제",
                        textScaleFactor: 1.3,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight)),
                  )),
            ],
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _exercisedetailWidget() {
    bool btnDisabled = false;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onPanUpdate: (details) {
        if (details.delta.dx > 20 && btnDisabled == false) {
          btnDisabled = true;
          Navigator.of(context).pop();
          print("Dragging in +X direction");
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        height: MediaQuery.of(context).size.height,
        child:
            Consumer<HistorydataProvider>(builder: (builder, provider, child) {
          _exampleex = provider
              .historydata
              .sdbdatas[provider.historydata.sdbdatas.indexWhere((sdbdata) {
            if (sdbdata.id == widget.history_id) {
              return true;
            } else {
              return false;
            }
          })]
              .exercises[widget.index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                  height: 130,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _exampleex.name.length < 8
                          ? Text(
                              _exampleex.name,
                              textScaleFactor: 4.0,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight),
                            )
                          : Text(
                              _exampleex.name,
                              textScaleFactor: 2.7,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight),
                            ),
                      Text(
                        "Best 1RM: ${widget.exercise.onerm!.toStringAsFixed(1)}/${widget.exercise.goal!.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                        textScaleFactor: 1.7,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                      )
                    ],
                  )),
              Expanded(
                  child: widget.exercise.isCardio!
                      ? _cardioExerciseDetailBodyWidget()
                      : _exerciseDetailBodyWidget()),
              Container(
                  padding: const EdgeInsets.only(bottom: 10),
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
                            child: const Text("운동 수정 하기"),
                          )),
                        ],
                      ),
                    ],
                  )),
            ],
          );
        }),
      ),
    );
  }

  Widget _exerciseDetailBodyWidget() {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Container(
          padding: const EdgeInsets.only(right: 10),
          height: 25,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 80,
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    "Set",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  )),
              SizedBox(
                  width: 70,
                  child: Text(
                    "Weight(${_userProvider.userdata.weight_unit})",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )),
              Container(width: 35),
              SizedBox(
                  width: 40,
                  child: Text(
                    "Reps",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(
                  width: 70,
                  child: Text(
                    "1RM",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
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
                  weightController.add(TextEditingController());
                  repsController.add(TextEditingController());
                  return Container(
                      padding: const EdgeInsets.only(right: 10),
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
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor:
                                    Theme.of(context).primaryColorLight,
                                icon: Icons.delete,
                                label: 'Delete',
                              )
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 80,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Transform.scale(
                                      scale: 1.2,
                                      child: Checkbox(
                                          checkColor:
                                              Theme.of(context).highlightColor,
                                          activeColor:
                                              Theme.of(context).primaryColor,
                                          value: widget
                                              .exercise.sets[index].ischecked,
                                          onChanged: (newvalue) {
                                            setState(() {
                                              widget.exercise.sets[index]
                                                  .ischecked = newvalue;
                                            });
                                          })),
                                  SizedBox(
                                    width: 25,
                                    child: Text(
                                      "${index + 1}",
                                      textScaleFactor: 1.7,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                controller: weightController[index],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        signed: false, decimal: true),
                                style: TextStyle(
                                  fontSize:
                                      21 * _themeProvider.userFontSize / 0.8,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      "${widget.exercise.sets[index].weight}",
                                  hintStyle: TextStyle(
                                    fontSize:
                                        21 * _themeProvider.userFontSize / 0.8,
                                    color: Theme.of(context).primaryColorLight,
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
                            SizedBox(
                                width: 35,
                                child: SvgPicture.asset(
                                    "assets/svg/multiply.svg",
                                    color: Theme.of(context).primaryColorLight,
                                    height: 19 *
                                        _themeProvider.userFontSize /
                                        0.8)),
                            SizedBox(
                              width: 40,
                              child: TextField(
                                controller: repsController[index],
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize:
                                      21 * _themeProvider.userFontSize / 0.8,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      "${widget.exercise.sets[index].reps}",
                                  hintStyle: TextStyle(
                                    fontSize:
                                        21 * _themeProvider.userFontSize / 0.8,
                                    color: Theme.of(context).primaryColorLight,
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
                            SizedBox(
                                width: 70,
                                child: (widget.exercise.sets[index].reps != 1)
                                    ? Text(
                                        "${(widget.exercise.sets[index].weight * (1 + widget.exercise.sets[index].reps / 30)).toStringAsFixed(1)}",
                                        textScaleFactor: 1.7,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                        textAlign: TextAlign.center,
                                      )
                                    : Text(
                                        "${widget.exercise.sets[index].weight}",
                                        textScaleFactor: 1.7,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                        textAlign: TextAlign.center,
                                      )),
                          ],
                        ),
                      ));
                },
                separatorBuilder: (BuildContext _context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 0.5,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 0.5,
                      color: Theme.of(context).primaryColorDark,
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
                    color: Theme.of(context).primaryColorLight,
                    size: 24,
                  )),
              IconButton(
                  onPressed: () {
                    setState(() {
                      widget.exercise.sets.add(wod.Sets(
                          index: 0, weight: 0.0, reps: 1, ischecked: true));
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColorLight,
                    size: 24,
                  )),
            ],
          ),
        ],
      ))
    ]);
  }

  Widget _cardioExerciseDetailBodyWidget() {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Container(
          padding: const EdgeInsets.only(right: 10),
          height: 25,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 85,
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    "Set",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  )),
              SizedBox(
                  width: 80,
                  child: Text(
                    "거리(Km)",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(
                  width: 140,
                  child: Text(
                    "시간(시:분:초)",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
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
                  weightController.add(TextEditingController());
                  repsController.add(TextEditingController());
                  Duration _time =
                      Duration(seconds: widget.exercise.sets[index].reps);
                  return Container(
                      padding: const EdgeInsets.only(right: 10),
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
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Theme.of(context).cardColor,
                                icon: Icons.delete,
                                label: 'Delete',
                              )
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 80,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Transform.scale(
                                      scale: 1.1,
                                      child: Checkbox(
                                          checkColor:
                                              Theme.of(context).highlightColor,
                                          activeColor:
                                              Theme.of(context).primaryColor,
                                          value: widget
                                              .exercise.sets[index].ischecked,
                                          onChanged: (newvalue) {
                                            setState(() {
                                              widget.exercise.sets[index]
                                                  .ischecked = newvalue;
                                            });
                                          })),
                                  SizedBox(
                                    width: 25,
                                    child: Text(
                                      "${index + 1}",
                                      textScaleFactor: 1.7,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: weightController[index],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        signed: false, decimal: true),
                                style: TextStyle(
                                  fontSize:
                                      21 * _themeProvider.userFontSize / 0.8,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      "${widget.exercise.sets[index].weight}",
                                  hintStyle: TextStyle(
                                    fontSize:
                                        21 * _themeProvider.userFontSize / 0.8,
                                    color: Theme.of(context).primaryColorLight,
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
                            SizedBox(
                              width: 140,
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    showCupertinoModalPopup<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return _buildContainer(
                                              _timerPicker(_time, index));
                                        });
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 8, bottom: 8),
                                        child: Text(
                                          "${_time.inHours.toString().length == 1 ? "0" + _time.inHours.toString() : _time.inHours}:${_time.inMinutes.remainder(60).toString().length == 1 ? "0" + _time.inMinutes.remainder(60).toString() : _time.inMinutes.remainder(60)}:${_time.inSeconds.remainder(60).toString().length == 1 ? "0" + _time.inSeconds.remainder(60).toString() : _time.inSeconds.remainder(60)}",
                                          style: TextStyle(
                                            fontSize:
                                                _themeProvider.userFontSize *
                                                    21 /
                                                    0.8,
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ));
                },
                separatorBuilder: (BuildContext _context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 0.5,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 0.5,
                      color: Theme.of(context).primaryColorDark,
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
                    color: Theme.of(context).primaryColorLight,
                    size: 24,
                  )),
              IconButton(
                  onPressed: () {
                    setState(() {
                      widget.exercise.sets.add(wod.Sets(
                          index: 0, weight: 0.0, reps: 1, ischecked: true));
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColorLight,
                    size: 24,
                  )),
            ],
          ),
        ],
      ))
    ]);
  }

  Widget _timerPicker(time, index) {
    return CupertinoTimerPicker(
      mode: CupertinoTimerPickerMode.hms,
      minuteInterval: 1,
      secondInterval: 1,
      initialTimerDuration: time,
      onTimerDurationChanged: (Duration changeTimer) {
        initialTimer = changeTimer;
        setState(() {
          widget.exercise.sets[index].reps = changeTimer.inSeconds;
        });
      },
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
    if (recordedsets.isNotEmpty) {
      widget.origin_exercises[widget.index] = (hisdata.Exercises(
          name: _exampleex.name,
          sets: recordedsets,
          onerm: monerm,
          goal: widget.exercise.goal,
          date: widget.exercise.date,
          isCardio: widget.exercise.isCardio ?? false));
    }
  }

  void _editHistoryCheck() async {
    if (widget.exercise.sets
        .where((sets) {
          return (sets.ischecked as bool && sets.weight != 0);
        })
        .toList()
        .isNotEmpty) {
      HistoryExercisesEdit(
              history_id: widget.history_id,
              user_email: _userProvider.userdata.email,
              exercises: widget.origin_exercises)
          .patchHistoryExercises()
          .then((data) => data["user_email"] != null
              ? {
                  showToast("수정 완료"),
                  Navigator.of(context).pop(),
                  _hisProvider.patchHistoryExdata(
                      widget.history_id, widget.origin_exercises)
                }
              : showToast("입력을 확인해주세요"));
    } else {
      _deleteExerciseCheck();
    }
  }

  void _deleteExerciseCheck() async {
    _hisProvider.deleteExercisedata(widget.history_id, widget.index);
    if (widget.origin_exercises.isNotEmpty) {
      HistoryExercisesEdit(
              history_id: widget.history_id,
              user_email: _userProvider.userdata.email,
              exercises: widget.origin_exercises)
          .patchHistoryExercises()
          .then((data) => data["user_email"] != null
              ? {showToast("수정 완료"), Navigator.of(context).pop()}
              : showToast("입력을 확인해주세요"));
    } else {
      _hisProvider.deleteHistorydata(widget.history_id);
      HistoryDelete(history_id: widget.history_id).deleteHistory().then(
          (data) => data["user_email"] != null
              ? {
                  showToast("수정 완료"),
                  Navigator.of(context).popUntil((route) => route.isFirst)
                }
              : showToast("입력을 확인해주세요"));
    }
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
