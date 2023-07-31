import 'package:expandable/expandable.dart';
import 'package:sdb_trainer/pages/exercise/exercise_done.dart';
import 'package:sdb_trainer/pages/exercise/upload_program.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:sdb_trainer/src/utils/change_name.dart';
import 'package:sdb_trainer/src/utils/exercise_util.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:transition/transition.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';

// ignore: must_be_immutable
class EachPlanDetails extends StatefulWidget {
  int rindex;
  EachPlanDetails({Key? key, required this.rindex}) : super(key: key);

  @override
  State<EachPlanDetails> createState() => _EachPlanDetailsState();
}

class _EachPlanDetailsState extends State<EachPlanDetails> {
  final TextEditingController _weightctrl = TextEditingController(text: "");
  final TextEditingController _weightRatioctrl =
      TextEditingController(text: "");
  final TextEditingController _repsctrl = TextEditingController(text: "");
  var _workoutProvider;
  var _FamousedataProvider;
  var _hisProvider;
  var _routinetimeProvider;
  var _PopProvider;
  var _userProvider;
  var _prefsProvider;
  var _exProvider;
  var _testdata0;
  late var _testdata = _testdata0;
  String _addexinput = '';
  late List<hisdata.Exercises> exerciseList = [];
  var _exercises;

  final List<CountDownController> _countcontroller = [];

  Plans sample = Plans(exercises: []);
  Plan_Exercises exsample = Plan_Exercises(
      name: '벤치프레스',
      ref_name: '벤치프레스',
      sets: [Sets(index: 0, weight: 100, reps: 10, ischecked: false)],
      rest: 0);

  ExpandableController Controller = ExpandableController(
    initialExpanded: true,
  );
  List<ExpandableController> Controllerlist = [];

  PreferredSizeWidget _appbarWidget() {
    bool isBtnDisabled = false;
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              _editWorkoutCheck();
              if (!isBtnDisabled) {
                isBtnDisabled = true;
                Navigator.of(context).pop();
              }
            },
          ),
          title: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NameInputDialog(rindex: widget.rindex);
                  });
            },
            child: SizedBox(
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
          actions: [
            IconButton(
              onPressed: () {
                if (_workoutProvider
                        .workoutdata.routinedatas[widget.rindex].mode ==
                    3) {
                  showToast("다운받은 루틴은 업로드 할 수 없어요");
                } else {
                  Navigator.push(
                    context,
                    Transition(
                      child: ProgramUpload(
                        program: _workoutProvider
                            .workoutdata.routinedatas[widget.rindex],
                      ),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT,
                    ),
                  );
                }
              },
              icon: Icon(Icons.cloud_upload_rounded,
                  color: Theme.of(context).primaryColorLight),
            ),
          ],
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  void _showMyDialog_finish() async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return showsimpleAlerts(
            layer: 5,
            rindex: -1,
            eindex: -1,
          );
        });
    if (result == true) {
      recordExercise();
      _editHistoryCheck();
      _editWorkoutCheck();

      if (exerciseList.isNotEmpty) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return showsimpleAlerts(
                layer: 5,
                rindex: -1,
                eindex: 1,
              );
            });
      }
    }
  }

  _showMyDialog(pindex, index, newvalue, [initDuration]) async {
    final plandata =
        _workoutProvider.workoutdata.routinedatas[widget.rindex].exercises[0];
    final plan_each_ex = plandata.plans[plandata.progress].exercises[pindex];
    final exerciseIndex = _exProvider.exercisesdata.exercises.indexWhere(
        (element) =>
            element.name ==
            _workoutProvider.workoutdata.routinedatas[widget.rindex]
                .exercises[0].plans[plandata.progress].exercises[pindex].name);

    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return showsimpleAlerts(
            layer: 3,
            rindex: widget.rindex,
            eindex: 0,
          );
        });

    if (result == true) {
      _routinetimeProvider.resettimer(plan_each_ex.rest);
      _routinetimeProvider.routinecheck(widget.rindex);
      _workoutProvider.boolplancheck(
          widget.rindex, pindex, index, plandata.progress, newvalue);
      _editWorkoutwCheck();
      _workoutOnermCheck(plan_each_ex.sets[index], exerciseIndex);
      if (_exProvider.exercisesdata.exercises[exerciseIndex].category ==
          '유산소') {
        _countcontroller[index].restart(duration: initDuration);
      }
    }
  }

  Future<void> _editWorkoutwCheck() async {
    final data = await WorkoutEdit(
      id: _workoutProvider.workoutdata.id,
      user_email: _userProvider.userdata.email,
      routinedatas: _workoutProvider.workoutdata.routinedatas,
    ).editWorkout();

    if (data["user_email"] == null) {
      showToast("입력을 확인해주세요");
    }
  }

  void _workoutOnermCheck(Sets sets_, exerciseIndex_) {
    final onerm = (sets_.reps != 1)
        ? (sets_.weight * (1 + sets_.reps / 30))
        : sets_.weight;
    final exercise = _exProvider.exercisesdata.exercises[exerciseIndex_];

    if (onerm > exercise.onerm) {
      _exProvider.putOnermValue(exerciseIndex_, onerm);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return newOnermAlerts(
                onerm: onerm, sets: sets_, exercise: exercise);
          });
      _routinetimeProvider.newRoutineUpdate();
    } else {}
  }

  List<Widget> techChips() {
    final plandata =
        _workoutProvider.workoutdata.routinedatas[widget.rindex].exercises[0];
    List<Widget> chips = [];
    for (int i = 0; i < plandata.plans.length; i++) {
      var inplandata = plandata.plans[i].exercises;
      var planLength = inplandata.length != 0
          ? inplandata.length.toStringAsFixed(0) + " 운동"
          : "휴식";
      Widget item = Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: ChoiceChip(
            label: Text('${i + 1}일\n' + planLength,
                textAlign: TextAlign.center,
                textScaleFactor: 1.4,
                maxLines: 10,
                softWrap: true),
            labelStyle: TextStyle(
                color: plandata.progress == i
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColorLight),
            selected: plandata.progress == i,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onSelected: (bool value) {
              _workoutProvider.setplanprogress(widget.rindex, i);
              _editWorkoutCheck();
            }),
      );
      chips.add(item);
    }
    return chips;
  }

  Widget _Nday_RoutineWidget() {
    return Consumer2<WorkoutdataProvider, ExercisesdataProvider>(
        builder: (builder, workout_provider, ex_provider, child) {
      var plandata =
          workout_provider.workoutdata.routinedatas[widget.rindex].exercises[0];
      var planExercises = plandata.plans[plandata.progress].exercises;
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: techChips().length,
                        itemBuilder: (context, index) {
                          return techChips()[index];
                        },
                      )),
                  SizedBox(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                        Transform.scale(
                            scale: 1.2,
                            child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  if (plandata.plans.length != 1) {
                                    _workoutProvider
                                        .removeplanAt(widget.rindex);
                                    _editWorkoutCheck();
                                  }
                                },
                                icon: Icon(
                                  Icons.remove_circle_outlined,
                                  color: Theme.of(context).primaryColorLight,
                                  size: 20,
                                ))),
                        Text(' /',
                            textScaleFactor: 1.7,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Transform.scale(
                            scale: 1.2,
                            child: IconButton(
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _workoutProvider.addplanAt(
                                      widget.rindex, sample);
                                  _editWorkoutCheck();
                                },
                                icon: Icon(
                                  Icons.add_circle_outlined,
                                  color: Theme.of(context).primaryColorLight,
                                  size: 20,
                                )))
                      ]))
                ])),
            const Divider(indent: 10, thickness: 1.3, color: Colors.grey),
            Expanded(
                child: ListView(children: [
              if (planExercises.isEmpty)
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(height: 30),
                      Text('오늘은 휴식데이!',
                          textScaleFactor: 2.0,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontWeight: FontWeight.bold)),
                      Container(height: 20),
                      Text('운동을 추가 하지 않으면 휴식일입니다.',
                          textScaleFactor: 1.2,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontWeight: FontWeight.bold)),
                      Container(height: 30),
                    ])
              else
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context_, int index_) {
                      final planEachExercise = planExercises[index_];
                      final exerciseIndex = _exProvider.exercisesdata.exercises
                          .indexWhere((element) =>
                              element.name == planEachExercise.name);
                      Controllerlist.add(
                          ExpandableController(initialExpanded: true));
                      var _exImage;
                      try {
                        _exImage = extra_completely_new_Ex[
                                extra_completely_new_Ex.indexWhere((element) =>
                                    element.name == planEachExercise.name)]
                            .image;
                        _exImage ??= "";
                      } catch (e) {
                        _exImage = "";
                      }
                      return Column(children: [
                        ExpandablePanel(
                            key: UniqueKey(),
                            controller: Controllerlist[index_],
                            theme: ExpandableThemeData(
                                headerAlignment:
                                    ExpandablePanelHeaderAlignment.center,
                                hasIcon: true,
                                iconColor: Theme.of(context).primaryColorLight),
                            header: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CustomIconButton(
                                            onPressed: () {
                                              exselect(false, true, index_);
                                            },
                                            backgroundColor: Theme.of(context)
                                                .primaryColorDark,
                                            icon: Icon(Icons.swap_horiz,
                                                color: Colors.white, size: 16),
                                          ),
                                          SizedBox(width: 6),
                                          GestureDetector(
                                              child: Row(
                                                children: [
                                                  Text(planEachExercise.name,
                                                      textScaleFactor: 1.8,
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorLight)),
                                                  SizedBox(width: 4),
                                                  Column(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .info_outline_rounded,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                ExerciseGuideBottomModal()
                                                    .exguide(
                                                        exerciseIndex, context);
                                              }),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      GestureDetector(
                                          child: Text(
                                            '기준: ${planEachExercise.ref_name}',
                                            textScaleFactor: 1.1,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onTap: () {
                                            exselect(false, false, index_);
                                          })
                                    ])),
                            collapsed: Container(),
                            expanded: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _exImage != ""
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(_exImage,
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover))
                                        : Container(
                                            height: 80,
                                            width: 80,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle),
                                            child: Icon(
                                                Icons.image_not_supported,
                                                color: Theme.of(context)
                                                    .primaryColorDark)),
                                    Expanded(
                                        child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (BuildContext context_,
                                          int setIndex_) {
                                        final set =
                                            planEachExercise.sets[setIndex_];
                                        final eachSetWeight = (planEachExercise
                                            .sets[setIndex_].weight);
                                        return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                  child: Text(
                                                      '${(eachSetWeight).toStringAsFixed(1)}kg  X  ${planEachExercise.sets[setIndex_].reps}',
                                                      textScaleFactor: 1.6,
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorLight)),
                                                  onTap: () {
                                                    setSetting(
                                                        index_, setIndex_);
                                                  }),
                                              SizedBox(
                                                  width: 60,
                                                  child: Transform.scale(
                                                      scale: 1.3,
                                                      child: Theme(
                                                          data: ThemeData(
                                                              unselectedWidgetColor:
                                                                  Theme.of(context)
                                                                      .primaryColorLight),
                                                          child: Checkbox(
                                                              materialTapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .shrinkWrap,
                                                              activeColor:
                                                                  Theme.of(context)
                                                                      .primaryColor,
                                                              checkColor:
                                                                  Theme.of(context)
                                                                      .highlightColor,
                                                              side: BorderSide(
                                                                  width: 1,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark),
                                                              value: planEachExercise
                                                                  .sets[
                                                                      setIndex_]
                                                                  .ischecked,
                                                              onChanged: (newvalue) {
                                                                _routinetimeProvider
                                                                        .isstarted
                                                                    ? [
                                                                        workout_provider.planboolcheck(
                                                                            widget.rindex,
                                                                            index_,
                                                                            setIndex_,
                                                                            newvalue),
                                                                        _workoutOnermCheck(
                                                                            set,
                                                                            exerciseIndex)
                                                                      ]
                                                                    : [
                                                                        _showMyDialog(
                                                                            index_,
                                                                            setIndex_,
                                                                            newvalue)
                                                                      ];
                                                              }))))
                                            ]);
                                      },
                                      shrinkWrap: true,
                                      itemCount: planEachExercise.sets.length,
                                    ))
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(width: 10),
                                    Container(width: 10),
                                    Transform.scale(
                                      scale: 1.2,
                                      child: IconButton(
                                          padding: const EdgeInsets.all(5),
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            workout_provider.plansetsminus(
                                                widget.rindex, index_);
                                            _editWorkoutCheck();
                                          },
                                          icon: Icon(
                                            Icons.remove_circle_outlined,
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                            size: 20,
                                          )),
                                    ),
                                    Text(
                                      ' /',
                                      textScaleFactor: 1.7,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight),
                                    ),
                                    Transform.scale(
                                        scale: 1.2,
                                        child: IconButton(
                                            padding: const EdgeInsets.all(5),
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              workout_provider.plansetsplus(
                                                  widget.rindex, index_);
                                              _editWorkoutCheck();
                                            },
                                            icon: Icon(
                                              Icons.add_circle_outlined,
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                              size: 20,
                                            )))
                                  ])
                            ]) // body when the widget is Expanded
                            ),
                        const Divider(
                          indent: 10,
                          thickness: 1.3,
                          color: Colors.grey,
                        )
                      ]);
                    },
                    shrinkWrap: true,
                    itemCount: planExercises.length),
              Container(height: 10),
              SizedBox(
                  height: 30,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: IconButton(
                              padding: const EdgeInsets.all(5),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                workout_provider.planremoveexAt(widget.rindex);
                                _editWorkoutCheck();
                              },
                              icon: Icon(Icons.remove_circle_outlined,
                                  color: Theme.of(context).primaryColorLight,
                                  size: 20)),
                        ),
                        Container(width: 10),
                        Text('/',
                            textScaleFactor: 1.7,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Container(width: 10),
                        Transform.scale(
                            scale: 1.2,
                            child: IconButton(
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  exselect(true, false);
                                  exselect(true, true);
                                },
                                icon: Icon(
                                  Icons.add_circle_outlined,
                                  color: Theme.of(context).primaryColorLight,
                                  size: 20,
                                )))
                      ])),
              const Center(
                  child: Text(
                '운동 제거/추가',
                textScaleFactor: 1.2,
                style: TextStyle(color: Colors.grey),
              ))
            ])),
            Consumer<RoutineTimeProvider>(builder: (context, provider_, child) {
              return Center(
                  child: Text(
                      '${(provider_.routineTime / 60).floor().toString()}:${((provider_.routineTime % 60) / 10).floor().toString()}${((provider_.routineTime % 60) % 10).toString()}',
                      textScaleFactor: 2.0,
                      style: TextStyle(
                          color: (provider_.userest && provider_.timeron < 0)
                              ? Colors.red
                              : Theme.of(context).primaryColorLight)));
            }),
            Consumer2<RoutineTimeProvider, PrefsProvider>(
                builder: (builder, provider_, provider2_, child) {
              return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: (provider_.nowonrindex != widget.rindex) &&
                              _routinetimeProvider.isstarted
                          ? const Color(0xFF212121)
                          : provider_.buttoncolor,
                      textStyle: const TextStyle(fontSize: 20)),
                  onPressed: () {
                    if (provider_.nowonrindex != widget.rindex &&
                        _routinetimeProvider.isstarted) {
                      return null;
                    } else {
                      if (_routinetimeProvider.isstarted) {
                        _showMyDialog_finish();
                      } else {
                        provider_.routinecheck(widget.rindex);
                        provider2_.setplan(_workoutProvider
                            .workoutdata.routinedatas[widget.rindex].name);
                      }
                    }
                  },
                  child: Text((provider_.nowonrindex != widget.rindex) &&
                          _routinetimeProvider.isstarted
                      ? '다른 루틴 수행중'
                      : provider_.routineButton));
            })
          ]));
    });
  }

  void setSetting(int exIndex_, int setIndex_) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: _setinfo(exIndex_, setIndex_));
      },
    );
  }

  Widget _setinfo(int exIndex_, int setIndex_) {
    return Consumer2<WorkoutdataProvider, ExercisesdataProvider>(
        builder: (builder, workout, exinfo, child) {
      var plandata =
          workout.workoutdata.routinedatas[widget.rindex].exercises[0];
      var planEachExercise =
          plandata.plans[plandata.progress].exercises[exIndex_];
      var setdata = planEachExercise.sets[setIndex_];
      var eachExInfo = exinfo.exercisesdata.exercises[exinfo
          .exercisesdata.exercises
          .indexWhere((element) => element.name == planEachExercise.ref_name)];
      if (setdata.ischecked) {
        _weightRatioctrl.text = setdata.index.toString();
        _weightctrl.text = setdata.weight.toString();
        _repsctrl.text = setdata.reps.toString();
      } else {
        _weightRatioctrl.text = setdata.index.toString();
        _weightctrl.text =
            ((setdata.index * eachExInfo.onerm / 100 / 2.5).floor() * 2.5)
                .toString();
        _repsctrl.text = setdata.reps.toString();
      }

      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Column(children: [
          Container(height: 12),
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Container(
                height: 6.0,
                width: 80.0,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0))),
              )),
          Container(height: 8),
          Text('기준 운동: ${eachExInfo.name}',
              textScaleFactor: 1.5,
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.bold)),
          Container(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Center(
                    child: Text('기준 1rm',
                        textScaleFactor: 1.5,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                        )))),
            SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Center(
                    child: Text(
                  '중량비(%)',
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ))),
            SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Center(
                    child: Text(
                  '무게',
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ))),
            SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Center(
                    child: Text(
                  '횟수',
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                )))
          ]),
          Container(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Center(
                    child: Text(
                  eachExInfo.onerm.toStringAsFixed(1),
                  textScaleFactor: 1.7,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                  ),
                ))),
            SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Center(
                    child: TextField(
                        controller: _weightRatioctrl,
                        autofocus: false,
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: false, decimal: true),
                        style: TextStyle(
                          fontSize: 21,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10.0),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3,
                                    color: Theme.of(context).primaryColorDark),
                                borderRadius: BorderRadius.circular(5.0)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3,
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(5.0)),
                            hintText: "${setdata.index}",
                            hintStyle: TextStyle(
                              fontSize: 21,
                              color: Theme.of(context).primaryColorDark,
                            )),
                        onChanged: (text) {
                          setState(() {
                            if (eachExInfo.onerm == 0) {
                              showToast("1RM이 0입니다. 무게를 설정해주세요");
                              _weightctrl.text = "20.0";
                            } else {
                              _weightctrl.text =
                                  "${(double.parse(text) * eachExInfo.onerm / 100 / 2.5).floor() * 2.5}";
                            }
                          });
                        }))),
            SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: Center(
                    child: TextField(
                        controller: _weightctrl,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: false, decimal: true),
                        style: TextStyle(
                          fontSize: 21,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10.0),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3,
                                    color: Theme.of(context).primaryColorDark),
                                borderRadius: BorderRadius.circular(5.0)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3,
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(5.0)),
                            hintText: "${setdata.weight}",
                            hintStyle: TextStyle(
                              fontSize: 21,
                              color: Theme.of(context).primaryColorDark,
                            )),
                        onChanged: (text) {
                          setState(() {
                            if (eachExInfo.onerm == 0) {
                              _weightRatioctrl.text = "100.0";
                            } else {
                              _weightRatioctrl.text =
                                  "${(double.parse(text) / eachExInfo.onerm * 1000).floor() / 10}";
                            }
                          });
                        }))),
            SizedBox(
                width: MediaQuery.of(context).size.width / 4,
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3,
                                  color: Theme.of(context).primaryColorDark),
                              borderRadius: BorderRadius.circular(5.0)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3,
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(5.0)),
                          hintText: "${setdata.reps}",
                          hintStyle: TextStyle(
                            fontSize: 21,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        onChanged: (text) {
                          setState(() {});
                        })))
          ]),
          Container(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text("최종 1RM: ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColorDark,
                    )),
                Text(
                    (_weightctrl.text != "" && _repsctrl.text != "")
                        ? (int.parse(_repsctrl.text) > 1)
                            ? "${(double.parse(_weightctrl.text) * (1 + int.parse(_repsctrl.text) / 30)).toStringAsFixed(1)}kg"
                            : "${(double.parse(_weightctrl.text)).toStringAsFixed(1)}kg"
                        : "-kg",
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 20,
                    ))
              ])
            ]),
            Container(width: 48),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFffc60a8)),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
                ),
                onPressed: () {
                  try {
                    _workoutProvider.plansetcheck(
                        widget.rindex,
                        exIndex_,
                        setIndex_,
                        double.parse(_weightRatioctrl.text),
                        double.parse(_weightctrl.text),
                        int.parse(_repsctrl.text));
                    _editWorkoutCheck();
                    Navigator.pop(context);
                  } catch (e) {
                    showToast("숫자를 확인해주세요");
                  }
                },
                child: const Text(
                  '완료',
                  textScaleFactor: 1.4,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Container(width: 16)
          ])
        ]);
      });
    });
  }

  void exselect(bool isadd, bool isex, [int where = 0]) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 2,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
        Text(
          isex ? '운동을 선택해주세요' : '1RM 기준 운동을 선택해주세요',
          textScaleFactor: 1.7,
          style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.bold),
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
                hintText: "운동 찾기",
                hintStyle: TextStyle(
                    fontSize: 20.0, color: Theme.of(context).primaryColorDark),
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
    var suggestions;
    if (query == '') {
      suggestions = _exProvider.exercisesdata.exercises;
    } else {
      suggestions = _exProvider.exercisesdata.exercises.where((exercise) {
        var exTitle = exercise.name.toLowerCase().replaceAll(' ', '');
        return (exTitle.contains(query.toLowerCase().replaceAll(' ', '')))
            as bool;
      }).toList();
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                          Plan_Exercises(
                              name: _addexinput,
                              ref_name: exuniq[index].name,
                              sets: [
                                Sets(
                                    index: 1,
                                    weight: 30,
                                    reps: 8,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(top),
                          bottomRight: Radius.circular(bottom),
                          topLeft: Radius.circular(top),
                          bottomLeft: Radius.circular(bottom))),
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        exuniq[index].name,
                        textScaleFactor: 1.7,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight),
                      ),
                      Text(
                          "1RM: ${exuniq[index].onerm.toStringAsFixed(1)}/${exuniq[index].goal.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                          textScaleFactor: 1.0,
                          style: const TextStyle(color: Color(0xFF717171)))
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext _context, int index) {
              return Container(
                alignment: Alignment.center,
                height: 1,
                color: const Color(0xFF212121),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 1,
                  color: const Color(0xFF717171),
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
    var exerciseAll = _workoutProvider
        .workoutdata
        .routinedatas[widget.rindex]
        .exercises[0]
        .plans[_workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[0].progress]
        .exercises;
    for (int n = 0; n < exerciseAll.length; n++) {
      var recordedsets = exerciseAll[n].sets.where((sets) {
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
          .indexWhere((element) => element.name == exerciseAll[n].name)];
      if (!recordedsets.isEmpty) {
        exerciseList.add(hisdata.Exercises(
            name: exerciseAll[n].name,
            sets: recordedsets,
            onerm: monerm,
            goal: _eachex.goal,
            date: DateTime.now().toString().substring(0, 10),
            isCardio: _eachex.category == "유산소" ? true : false));
      }
      if (monerm > _eachex.onerm) {
        modifyExercise(monerm, exerciseAll[n].name);
      }
    }
    _postExerciseCheck();
  }

  void _editHistoryCheck() async {
    if (exerciseList.isNotEmpty) {
      HistoryPost(
              user_email: _userProvider.userdata.email,
              exercises: exerciseList,
              new_record: _routinetimeProvider.routineNewRecord,
              workout_time: _routinetimeProvider.routineTime,
              nickname: _userProvider.userdata.nickname)
          .postHistory()
          .then((data) => data["user_email"] != null
              ? {
                  _hisProvider.getdata(),
                  _hisProvider.getHistorydataAll(),
                  Navigator.of(context, rootNavigator: true).pop(),
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
    _FamousedataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);

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
