// ignore_for_file: non_constant_identifier_names

import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sdb_trainer/pages/exercise/exercise_done.dart';
import 'package:sdb_trainer/pages/exercise/upload_program.dart';
import 'package:sdb_trainer/pages/search/exercise_guide.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:sdb_trainer/src/utils/change_name.dart';
import 'package:sdb_trainer/src/utils/exercise_util.dart';
import 'package:sdb_trainer/src/utils/firebaseAnalyticsService.dart';
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
  var _hisProvider;
  var _routinetimeProvider;
  var _PopProvider;
  var _userProvider;
  var _prefsProvider;
  var _exProvider;
  var _testdata0;
  var _themeProvider;

  bool _allExpanded = true; // 모든 패널이 확장된 상태 여부
  bool _isInitialized = false;

  Duration initialTimer = const Duration();
  late var _testdata = _testdata0;
  String _addexinput = '';
  late List<hisdata.Exercises> exerciseList = [];
  var _exercises;
  bool ctrlController = true;

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
  List<ExpandableController> _controllerList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      var workoutProvider =
          Provider.of<WorkoutdataProvider>(context, listen: false);
      var plandata =
          workoutProvider.workoutdata.routinedatas[widget.rindex].exercises[0];
      var planExercises = plandata.plans[plandata.progress].exercises;
      _controllerList = List.generate(
        planExercises.length,
        (index) => ExpandableController(initialExpanded: true),
      );
      _isInitialized = true;
    }
  }

  void _toggleAllPanels() {
    if (_allExpanded == true) {
      setState(() {
        for (var controller in _controllerList) {
          if (controller.expanded == true) {
            controller.value = false;
            _allExpanded = false;
          }
        }
      });
    } else {
      setState(() {
        for (var controller in _controllerList) {
          if (controller.expanded == false) {
            controller.value = true;
            _allExpanded = true;
          }
        }
      });
    }
  }

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
      _eachPlanExerciseStart();

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
              //_editWorkoutCheck();
            }),
      );
      chips.add(item);
    }
    return chips;
  }

  Widget _bodyChipWidget(WorkoutdataProvider workout_provider,
      RoutineTimeProvider routine_time_provider) {
    var plandata =
        workout_provider.workoutdata.routinedatas[widget.rindex].exercises[0];
    return SizedBox(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Transform.scale(
                scale: 1.2,
                child: IconButton(
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (routine_time_provider.isstarted &&
                          routine_time_provider.nowoneindex >=
                              plandata.progress &&
                          routine_time_provider.nowonrindex == widget.rindex) {
                        showToast('운동중인 날 이전의 운동은 제거가 불가능해요');
                      } else {
                        if (plandata.plans.length != 1) {
                          _workoutProvider.removeplanAt(widget.rindex);
                          if (plandata.progress == plandata.plans.length) {
                            _workoutProvider.setplanprogress(
                                widget.rindex, plandata.progress - 1);
                          }
                          _editWorkoutCheck();
                        }
                      }
                    },
                    icon: Icon(
                      Icons.remove_circle_outlined,
                      color: Theme.of(context).primaryColorLight,
                      size: 20,
                    ))),
            Text('/',
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight)),
            Transform.scale(
                scale: 1.2,
                child: IconButton(
                    padding: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (routine_time_provider.isstarted &&
                          routine_time_provider.nowoneindex >
                              plandata.progress &&
                          routine_time_provider.nowonrindex == widget.rindex) {
                        showToast('운동중인 날 전에는 일자 추가가 불가능해요');
                      } else {
                        _workoutProvider.addplanAt(
                            widget.rindex, new Plans(exercises: []));
                        _editWorkoutCheck();
                      }
                    },
                    icon: Icon(
                      Icons.add_circle_outlined,
                      color: Theme.of(context).primaryColorLight,
                      size: 20,
                    )))
          ]),
          InkWell(
              onTap: _toggleAllPanels,
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ExpandableCustomIcon(
                    isExpanded: _allExpanded,
                    icon: Icons.expand_more,
                    color: Theme.of(context).primaryColorLight),
              )),
        ],
      ))
    ]));
  }

  Widget _bodyRoutineWidget(WorkoutdataProvider workout_provider,
      ExercisesdataProvider exercise_provider) {
    var plandata =
        workout_provider.workoutdata.routinedatas[widget.rindex].exercises[0];
    var planExercises = plandata.plans[plandata.progress].exercises;
    return Expanded(
        child: ListView(children: [
      if (planExercises.isEmpty)
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
        ReorderableListView.builder(
            buildDefaultDragHandles: false,
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = planExercises.removeAt(oldIndex);
                planExercises.insert(newIndex, item);
              });
            },
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context_, int index_) {
              final planEachExercise = planExercises[index_];
              var checkedSets = planEachExercise.sets.where((sets) {
                return (sets.ischecked as bool);
              }).toList();
              final exerciseIndex = _exProvider.exercisesdata.exercises
                  .indexWhere(
                      (element) => element.name == planEachExercise.name);
              final eachExRefInfo = _exProvider.exercisesdata.exercises[
                  _exProvider.exercisesdata.exercises.indexWhere(
                      (element) => element.name == planEachExercise.ref_name)];
              var exImage;
              if (!_routinetimeProvider.isstarted) {
                _workoutProvider.planSetsCheck(
                    widget.rindex, index_, eachExRefInfo.onerm);
              }
              try {
                exImage = extra_completely_new_Ex[
                        extra_completely_new_Ex.indexWhere(
                            (element) => element.name == planEachExercise.name)]
                    .image;
                exImage ??= "";
              } catch (e) {
                exImage = "";
              }
              return Column(key: Key('$index_'), children: [
                ExpandablePanel(
                    key: UniqueKey(),
                    controller: _controllerList[index_],
                    theme: ExpandableThemeData(
                        headerAlignment: ExpandablePanelHeaderAlignment.center,
                        hasIcon: true,
                        iconColor: Theme.of(context).primaryColorLight),
                    header: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                Icon(
                                                  Icons.info_outline_rounded,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                ReorderableDragStartListener(
                                                  index: index_,
                                                  child: Text(
                                                      planEachExercise.name,
                                                      textScaleFactor: 1.5,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorLight)),
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
                                  ]),
                            ),
                            Text(
                                checkedSets.length.toString() +
                                    "/" +
                                    planEachExercise.sets.length.toString(),
                                textScaleFactor: 1.0,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.bold))
                          ],
                        )),
                    collapsed: Container(),
                    expanded: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            exImage != ""
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(exImage,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover))
                                : Container(
                                    height: 80,
                                    width: 80,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle),
                                    child: Icon(Icons.image_not_supported,
                                        color: Theme.of(context)
                                            .primaryColorDark)),
                            Expanded(
                                child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder:
                                  (BuildContext context_, int setIndex_) {
                                final set = planEachExercise.sets[setIndex_];
                                final eachSetWeight =
                                    (planEachExercise.sets[setIndex_].weight);

                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                          child: Text(
                                              '${(eachSetWeight).toStringAsFixed(1)}kg  X  ${planEachExercise.sets[setIndex_].reps}',
                                              textScaleFactor: 1.6,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorLight)),
                                          onTap: () {
                                            setSetting(index_, setIndex_);
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
                                                          .sets[setIndex_]
                                                          .ischecked,
                                                      onChanged: (newvalue) {
                                                        _routinetimeProvider
                                                                    .isstarted ||
                                                                planEachExercise
                                                                    .sets[
                                                                        setIndex_]
                                                                    .ischecked
                                                            ? [
                                                                if (newvalue ==
                                                                    true)
                                                                  {
                                                                    _routinetimeProvider.resettimer(plandata
                                                                        .plans[plandata
                                                                            .progress]
                                                                        .exercises[
                                                                            0]
                                                                        .rest),
                                                                    _workoutOnermCheck(
                                                                        set,
                                                                        exerciseIndex)
                                                                  },
                                                                workout_provider
                                                                    .planboolcheck(
                                                                        widget
                                                                            .rindex,
                                                                        index_,
                                                                        setIndex_,
                                                                        newvalue),
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
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                                color: Theme.of(context).primaryColorLight,
                                size: 20,
                              )),
                        ),
                        Text(
                          ' /',
                          textScaleFactor: 1.7,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight),
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
                                  color: Theme.of(context).primaryColorLight,
                                  size: 20,
                                )))
                      ])
                    ]) // body when the widget is Expanded
                    ),
                Divider(
                  indent: 10,
                  thickness: 0.6,
                  color: Theme.of(context).primaryColorDark,
                )
              ]);
            },
            shrinkWrap: true,
            itemCount: planExercises.length),
      Container(height: 10),
      SizedBox(
          height: 30,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Transform.scale(
              scale: 1.2,
              child: IconButton(
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    workout_provider.planremoveexAt(widget.rindex);
                    _controllerList.removeLast();
                    _editWorkoutCheck();
                  },
                  icon: Icon(Icons.remove_circle_outlined,
                      color: Theme.of(context).primaryColorLight, size: 20)),
            ),
            Container(width: 10),
            Text('/',
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight)),
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
    ]));
  }

  Widget _bodyTimerWidget(WorkoutdataProvider workout_provider) {
    var plandata =
        workout_provider.workoutdata.routinedatas[widget.rindex].exercises[0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        plandata.plans[plandata.progress].exercises.isNotEmpty
            ? Consumer<RoutineTimeProvider>(
                builder: (context, provider_, child) {
                var exRest =
                    plandata.plans[plandata.progress].exercises[0].rest;
                return _routinetimeProvider.isstarted
                    ? LinearProgressIndicator(
                        value: _routinetimeProvider.timeron > 0 &&
                                _routinetimeProvider.userest &&
                                exRest != 0
                            ? (exRest - _routinetimeProvider.timeron) / exRest
                            : 1,
                        minHeight: 1.6,
                        backgroundColor: Theme.of(context).primaryColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColorDark),
                      )
                    : const Divider(
                        indent: 0,
                        thickness: 0.3,
                        color: Colors.grey,
                      );
              })
            : Container(),
        Consumer<RoutineTimeProvider>(builder: (context, provider_, child) {
          final userest = provider_.userest;
          final timeron = provider_.timeron;
          final routineTime = provider_.routineTime;
          final isNegativeTimer = userest && timeron < 0;
          return KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
            return isKeyboardVisible ||
                    plandata.plans[plandata.progress].exercises.isEmpty
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(userest ? "휴식 시간 :" : "운동 시간 :",
                                    textScaleFactor: 1.4,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                  userest
                                      ? isNegativeTimer
                                          ? '-${(-timeron / 60).floor()}:${((-timeron % 60) / 10).floor()}${((-timeron % 60) % 10)}'
                                          : '${(timeron / 60).floor()}:${((timeron % 60) / 10).floor()}${((timeron % 60) % 10)}'
                                      : '${(routineTime / 60).floor()}:${((routineTime % 60) / 10).floor()}${((routineTime % 60) % 10)}',
                                  textScaleFactor: 2.0,
                                  style: TextStyle(
                                      color: (provider_.userest &&
                                              provider_.timeron < 0)
                                          ? Colors.red
                                          : Theme.of(context)
                                              .primaryColorLight))
                            ]),
                            Consumer<WorkoutdataProvider>(
                                builder: (builder, provider, child) {
                              final plan = _workoutProvider
                                  .workoutdata
                                  .routinedatas[widget.rindex]
                                  .exercises[0]
                                  .plans[plandata.progress];
                              final restDuration =
                                  Duration(seconds: plan.exercises[0].rest);
                              return GestureDetector(
                                onTap: () {
                                  showCupertinoModalPopup<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return _buildContainer(timerPicker2(
                                          restDuration,
                                          plandata.progress,
                                        ));
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 4.0, right: 4.0),
                                  child: Text(
                                    "휴식 설정 : ${plan.exercises[0].rest}초",
                                    textScaleFactor: 1.2,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _routinetimeProvider.restcheck();
                                _routinetimeProvider.resttimecheck(plandata
                                    .plans[plandata.progress]
                                    .exercises[0]
                                    .rest);
                              },
                              child: Consumer<RoutineTimeProvider>(
                                  builder: (builder, provider, child) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Text(
                                      provider.userest
                                          ? 'Rest Timer on'
                                          : 'Rest Timer off',
                                      textScaleFactor: 1.6,
                                      style: TextStyle(
                                        color: provider.userest
                                            ? Theme.of(context)
                                                .primaryColorLight
                                            : Theme.of(context)
                                                .primaryColorDark,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _routinetimeProvider.addRestTime(-10);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4)),
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 6.0),
                                      child: Text(
                                        "-10초",
                                        textScaleFactor: 1.2,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    _routinetimeProvider.addRestTime(10);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4)),
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 6.0),
                                      child: Text(
                                        "+10초",
                                        textScaleFactor: 1.2,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
          });
        }),
      ],
    );
  }

  Widget _bodyExButton(WorkoutdataProvider workout_provider,
      RoutineTimeProvider routine_time_provider) {
    var plandata =
        workout_provider.workoutdata.routinedatas[widget.rindex].exercises[0];
    return Consumer<PrefsProvider>(builder: (builder, pref_provider, child) {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor:
                  ((routine_time_provider.nowonrindex != widget.rindex &&
                              _routinetimeProvider.isstarted) ||
                          (_routinetimeProvider.isstarted &&
                              routine_time_provider.nowoneindex !=
                                  plandata.progress))
                      ? const Color(0xFF212121)
                      : routine_time_provider.buttoncolor,
              textStyle: const TextStyle(fontSize: 20)),
          onPressed: () async {
            if (routine_time_provider.nowonrindex != widget.rindex &&
                _routinetimeProvider.isstarted) {
              return null;
            } else {
              if (_routinetimeProvider.isstarted) {
                routine_time_provider.nowoneindex != plandata.progress
                    ? showToast(
                        "${routine_time_provider.nowoneindex + 1}일차 운동 탭에서 종료 가능합니다.")
                    : _showMyDialog_finish();
              } else {
                _eachPlanExerciseStart();
              }
            }
          },
          child: Text(
            (routine_time_provider.nowonrindex != widget.rindex) &&
                    _routinetimeProvider.isstarted
                ? '다른 루틴 수행중'
                : (routine_time_provider.nowoneindex != plandata.progress &&
                        routine_time_provider.isstarted)
                    ? '${routine_time_provider.nowoneindex + 1}일차 운동 수행중'
                    : routine_time_provider.routineButton,
            style: TextStyle(color: Colors.white),
          ));
    });
  }

  _eachPlanExerciseStart() async {
    var plandata =
        _workoutProvider.workoutdata.routinedatas[widget.rindex].exercises[0];
    _routinetimeProvider.resettimer(_workoutProvider
        .workoutdata
        .routinedatas[widget.rindex]
        .exercises[0]
        .plans[plandata.progress]
        .exercises[0]
        .rest);
    await _routinetimeProvider.routinecheck(widget.rindex);
    _prefsProvider
        .setplan(_workoutProvider.workoutdata.routinedatas[widget.rindex].name);
    _routinetimeProvider.nowoneindexupdate(plandata.progress);
    FirebaseAnalyticsService.logCustomEvent("Workout Start");
  }

  Widget _eachDayRoutineBodyWidget() {
    return Consumer3<WorkoutdataProvider, ExercisesdataProvider,
            RoutineTimeProvider>(
        builder: (builder, workout_provider, exercise_provider,
            routine_time_provider, child) {
      var plandata =
          workout_provider.workoutdata.routinedatas[widget.rindex].exercises[0];
      var planExercises = plandata.plans[plandata.progress].exercises;
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _bodyChipWidget(workout_provider, routine_time_provider),
            Divider(
                indent: 10,
                thickness: 0.6,
                color: Theme.of(context).primaryColorDark),
            _bodyRoutineWidget(workout_provider, exercise_provider),
            _bodyTimerWidget(workout_provider),
            _bodyExButton(workout_provider, routine_time_provider)
          ]));
    });
  }

  Widget timerPicker2(time, progress) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: _themeProvider.userThemeDark == "dark"
            ? Brightness.dark
            : Brightness.light,
        textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(
                fontSize: 16,
                color: _themeProvider.userThemeDark == "dark"
                    ? Colors.white
                    : Colors.black)),
      ),
      child: CupertinoTimerPicker(
        mode: CupertinoTimerPickerMode.ms,
        minuteInterval: 1,
        secondInterval: 10,
        initialTimerDuration: time,
        onTimerDurationChanged: (Duration changeTimer) {
          initialTimer = changeTimer;
          _routinetimeProvider.resttimecheck(changeTimer.inSeconds);

          _workoutProvider.restPlanTime(
              widget.rindex, progress, _routinetimeProvider.changetime);
          _editWorkoutwCheck();
        },
      ),
    );
  }

  Widget _buildContainer(Widget picker) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Container(
              height: 6.0,
              width: 80.0,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor)),
                      child: Text('완료',
                          textScaleFactor: 1.2,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorLight)))),
              Container(width: 10)
            ],
          ),
          SafeArea(
            top: false,
            child: SizedBox(
              height: 215,
              child: picker,
            ),
          ),
        ],
      ),
    );
  }

  void setSetting(int exIndex_, int setIndex_) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: _setinfo(exIndex_, setIndex_));
      },
    ).then((e) {
      ctrlController = true;
    });
  }

  Widget _setinfo(int exIndex_, int setIndex_) {
    var plandata =
        _workoutProvider.workoutdata.routinedatas[widget.rindex].exercises[0];
    var planEachExercise =
        plandata.plans[plandata.progress].exercises[exIndex_];
    var setdata = planEachExercise.sets[setIndex_];
    var eachExIndex = _exProvider.exercisesdata.exercises
        .indexWhere((element) => element.name == planEachExercise.ref_name);
    var eachExInfo = _exProvider.exercisesdata.exercises[eachExIndex];
    if (ctrlController == true) {
      ctrlController = false;
      _weightRatioctrl.text = setdata.index.toString();
      _weightctrl.text = setdata.weight.toString();
      _repsctrl.text = setdata.reps.toString();
    }

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Container(
                  height: 6.0,
                  width: 80.0,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0))),
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
                    '강도(%)',
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
              GestureDetector(
                onTap: () {
                  exGoalEditAlert(context, eachExInfo);
                },
                child: SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Consumer<ExercisesdataProvider>(
                        builder: (builder, provider, child) {
                      eachExInfo = _exProvider.exercisesdata.exercises[
                          _exProvider.exercisesdata.exercises.indexWhere(
                              (element) =>
                                  element.name == planEachExercise.ref_name)];
                      return Center(
                          child: Text(
                        eachExInfo.onerm.toStringAsFixed(1),
                        textScaleFactor: 1.7,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ));
                    })),
              ),
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
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: Theme.of(context).primaryColor),
                              ),
                              hintText: "${setdata.index}",
                              hintStyle: TextStyle(
                                fontSize: 21,
                                color: Theme.of(context).primaryColorDark,
                              )),
                          onChanged: (text) {
                            setState(() {
                              if (eachExInfo.onerm == 0) {
                                showToast("1RM이 0입니다. 무게를 설정해주세요");
                                _weightctrl.text = setdata.weight.toString();
                              } else {
                                if (text != "") {
                                  if (int.parse(_repsctrl.text) == 1) {
                                    _weightctrl.text =
                                        eachExInfo.onerm.toStringAsFixed(1);
                                  } else if (int.parse(_repsctrl.text) > 1) {
                                    _weightctrl.text =
                                        "${(eachExInfo.onerm / (1 + int.parse(_repsctrl.text) / 30) * double.parse(text) / 100 / 0.5).floor() * 0.5}";
                                  }
                                }
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
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: Theme.of(context).primaryColor),
                              ),
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
                                if (text != "") {
                                  if (int.parse(_repsctrl.text) == 1) {
                                    _weightRatioctrl.text =
                                        ((double.parse(_weightctrl.text)) /
                                                eachExInfo.onerm *
                                                100)
                                            .toStringAsFixed(1);
                                  } else if (int.parse(_repsctrl.text) > 1) {
                                    _weightRatioctrl.text = ((double.parse(
                                                    _weightctrl.text) *
                                                (1 +
                                                    int.parse(_repsctrl.text) /
                                                        30)) /
                                            eachExInfo.onerm *
                                            100)
                                        .toStringAsFixed(1);
                                  }
                                }
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
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10.0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).primaryColorDark),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1.5,
                                  color: Theme.of(context).primaryColor),
                            ),
                            hintText: "${setdata.reps}",
                            hintStyle: TextStyle(
                              fontSize: 21,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          onChanged: (text) {
                            setState(() {
                              if (eachExInfo.onerm == 0) {
                                _weightRatioctrl.text = "100.0";
                              } else {
                                if (text != "") {
                                  if (int.parse(text) == 1) {
                                    _weightRatioctrl.text =
                                        ((double.parse(_weightctrl.text)) /
                                                eachExInfo.onerm *
                                                100)
                                            .toStringAsFixed(1);
                                  } else if (int.parse(_repsctrl.text) > 1) {
                                    _weightRatioctrl.text =
                                        ((double.parse(_weightctrl.text) *
                                                    (1 +
                                                        int.parse(text) / 30)) /
                                                eachExInfo.onerm *
                                                100)
                                            .toStringAsFixed(1);
                                  }
                                }
                              }
                            });
                          })))
            ]),
            Container(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
            ]),
            Container(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColorDark),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 6,
                          vertical: 16)),
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
                        showToast("입력을 확인해주세요");
                      }
                    },
                    child: Text(
                      '저장',
                      textScaleFactor: 1.4,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).highlightColor),
                    )),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFffc60a8)),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 6,
                          vertical: 16)),
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

                        _routinetimeProvider.isstarted ||
                                planEachExercise.sets[setIndex_].ischecked
                            ? [
                                if (planEachExercise
                                        .sets[setIndex_].ischecked ==
                                    false)
                                  {
                                    _routinetimeProvider.resettimer(plandata
                                        .plans[plandata.progress]
                                        .exercises[0]
                                        .rest),
                                    _workoutOnermCheck(
                                        planEachExercise.sets[setIndex_],
                                        eachExIndex),
                                    _workoutProvider.planboolcheck(
                                        widget.rindex,
                                        exIndex_,
                                        setIndex_,
                                        true),
                                  }
                              ]
                            : [_showMyDialog(exIndex_, setIndex_, true)];
                        _editWorkoutCheck();
                        Navigator.pop(context);
                      } catch (e) {
                        showToast("입력을 확인해주세요");
                      }
                    },
                    child: Text(
                      '세트 완료',
                      textScaleFactor: 1.4,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).highlightColor),
                    )),
              ],
            ),
          ]),
        ),
      );
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
            padding: const EdgeInsets.only(top: 12.0),
            height: MediaQuery.of(context).size.height * 3,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).indicatorColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Container(
                    height: 6.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  ),
                ),
                Expanded(
                  child: Center(
                      child:
                          _exercises_searchWidget(isadd, isex, where, state)),
                ),
              ],
            ),
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
      child: Consumer2<WorkoutdataProvider, ExercisesdataProvider>(
          builder: (builder, provider, exProvider, child) {
        provider.workoutdata.routinedatas[widget.rindex].exercises;
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

              var _exImage;
              try {
                _exImage = extra_completely_new_Ex[
                        extra_completely_new_Ex.indexWhere(
                            (element) => element.name == _testdata[index].name)]
                    .image;
                _exImage ??= "";
              } catch (e) {
                _exImage = "";
              }
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
                                    index: 40,
                                    weight: 5,
                                    reps: 12,
                                    ischecked: false)
                              ],
                              rest: 0));
                      _controllerList
                          .add(ExpandableController(initialExpanded: true));

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
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      _exImage != ""
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    Transition(
                                        child: ExerciseGuide(
                                            eindex: _exProvider
                                                .exercisesdata.exercises
                                                .indexWhere((ex) =>
                                                    ex.name ==
                                                    _testdata[index].name)),
                                        transitionEffect:
                                            TransitionEffect.RIGHT_TO_LEFT));
                              },
                              child: Image.asset(
                                _exImage,
                                height: 48,
                                width: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    Transition(
                                        child: ExerciseGuide(
                                            eindex: _exProvider
                                                .exercisesdata.exercises
                                                .indexWhere((ex) =>
                                                    ex.name ==
                                                    _testdata[index].name)),
                                        transitionEffect:
                                            TransitionEffect.RIGHT_TO_LEFT));
                              },
                              child: Container(
                                height: 48,
                                width: 48,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: Icon(Icons.image_not_supported,
                                    color: Theme.of(context).primaryColorDark),
                              ),
                            ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          exuniq[index].name,
                          textScaleFactor: 1.7,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                        ),
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
                height: 0.3,
                color: const Color(0xFF212121),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 0.3,
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
        return (sets.ischecked as bool);
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
            ? [showToast("done!")]
            : showToast("입력을 확인해주세요"));
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);

    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
        body: _eachDayRoutineBodyWidget(),
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
