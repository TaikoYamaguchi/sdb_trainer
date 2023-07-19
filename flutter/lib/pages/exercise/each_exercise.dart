import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sdb_trainer/pages/exercise/exercise_done.dart';
import 'package:sdb_trainer/pages/search/exercise_guide.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
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
import 'package:sdb_trainer/providers/themeMode.dart';

// ignore: must_be_immutable
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

class _EachExerciseDetailsState extends State<EachExerciseDetails>
    with TickerProviderStateMixin {
  var _userProvider;
  var _hisProvider;
  var _exProvider;
  var _themeProvider;
  var _workoutProvider;
  var _routinetimeProvider;
  var _prefsProvider;
  var _exercise;
  var _exercises;
  var _currentExindex;
  Duration initialTimer = const Duration();
  List exControllerlist = [];
  final List<CountDownController> _countcontroller = [];
  JustTheController tooltipController = JustTheController();
  bool _isSetChanged = false;
  double top = 0;
  double bottom = 0;
  double? weight;
  int? reps;
  List<Controllerlist> weightController = [];
  List<Controllerlist> repsController = [];
  PageController? controller;
  var btnDisabled;
  final ScrollController _controller = ScrollController();
  late FlutterGifController controller1;

  var runtime = 0;
  Timer? timer1;

  late List<hisdata.Exercises> exerciseList = [];

  @override
  void initState() {
    controller1 = FlutterGifController(vsync: this);
    super.initState();
  }

  Widget timerPicker(time, pindex, index) {
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
        mode: CupertinoTimerPickerMode.hms,
        minuteInterval: 1,
        secondInterval: 1,
        initialTimerDuration: time,
        onTimerDurationChanged: (Duration changeTimer) {
          initialTimer = changeTimer;
          _workoutProvider.repscheck(
              widget.rindex, pindex, index, changeTimer.inSeconds);
        },
      ),
    );
  }

  Widget repsPicker(reps, pindex, index) {
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
      child: CupertinoPicker(
        itemExtent: 40.0,
        scrollController: FixedExtentScrollController(initialItem: reps),
        onSelectedItemChanged: (int repindex) {
          _workoutProvider.repscheck(
              widget.rindex, pindex, index, repindex + 1);
        },
        children: List.generate(
          100,
          (index) => Center(
              child: Text("${index + 1}",
                  style: const TextStyle(
                    fontSize: 22,
                  ))),
        ),
      ),
    );
  }

  Widget timerPicker2(time, pindex) {
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

          _workoutProvider.resttimecheck(
              widget.rindex, pindex, _routinetimeProvider.changetime);
          _editWorkoutwCheck();
        },
      ),
    );
  }

  Widget _buildContainer(Widget picker) {
    return Container(
      height: 305,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        children: [
          /*
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
          */
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
                              Theme.of(context).cardColor)),
                      child: Text('Done',
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)))),
              Container(width: 10)
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 215,
                child: picker,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
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
            textScaleFactor: 2.7,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                _routinetimeProvider.restcheck();
                _routinetimeProvider.resttimecheck(_workoutProvider
                    .workoutdata
                    .routinedatas[widget.rindex]
                    .exercises[_currentExindex]
                    .rest);
              },
              child: Consumer<RoutineTimeProvider>(
                  builder: (builder, provider, child) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      provider.userest ? 'Rest Timer on' : 'Rest Timer off',
                      textScaleFactor: 1.7,
                      style: TextStyle(
                        color: provider.userest
                            ? Theme.of(context).primaryColorLight
                            : Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  void _editWorkoutCheck() async {
    var routinedatas = _workoutProvider.workoutdata.routinedatas;
    if (_routinetimeProvider.isstarted) {
      WorkoutEdit(
        id: _workoutProvider.workoutdata.id,
        user_email: _userProvider.userdata.email,
        routinedatas: routinedatas,
      ).editWorkout().then((data) {
        if (data["user_email"] == null) {
          showToast("입력을 확인해주세요");
        }
      });
    } else {
      for (int n = 0; n < routinedatas[widget.rindex].exercises.length; n++) {
        for (int i = 0;
            i < routinedatas[widget.rindex].exercises[n].sets.length;
            i++) {
          routinedatas[widget.rindex].exercises[n].sets[i].ischecked = false;
        }
      }
      WorkoutEdit(
              id: _workoutProvider.workoutdata.id,
              user_email: _userProvider.userdata.email,
              routinedatas: routinedatas)
          .editWorkout()
          .then((data) {
        if (data["user_email"] == null) {
          showToast("입력을 확인해주세요");
        }
      });
    }
  }

  void _editWorkoutwCheck() async {
    var routinedatas = _workoutProvider.workoutdata.routinedatas;
    WorkoutEdit(
      id: _workoutProvider.workoutdata.id,
      user_email: _userProvider.userdata.email,
      routinedatas: routinedatas,
    ).editWorkout().then((data) {
      if (data["user_email"] == null) {
        showToast("입력을 확인해주세요");
      }
    });
  }

  void _editWorkoutwoCheck() async {
    var routinedatas = _workoutProvider.workoutdata.routinedatas;
    for (int n = 0; n < routinedatas[widget.rindex].exercises.length; n++) {
      for (int i = 0;
          i < routinedatas[widget.rindex].exercises[n].sets.length;
          i++) {
        routinedatas[widget.rindex].exercises[n].sets[i].ischecked = false;
      }
    }
    WorkoutEdit(
      id: _workoutProvider.workoutdata.id,
      user_email: _userProvider.userdata.email,
      routinedatas: routinedatas,
    ).editWorkout().then((data) {
      if (data["user_email"] == null) {
        showToast("입력을 확인해주세요");
      }
    });
  }

  Widget _exercisedetailPage() {
    controller = PageController(initialPage: widget.eindex);
    if (_routinetimeProvider.nowonrindex == widget.rindex) {
      _routinetimeProvider.nowoneindexupdate(widget.eindex);
    }
    int numEx = _workoutProvider
        .workoutdata.routinedatas[widget.rindex].exercises.length;
    var routine = _workoutProvider.workoutdata.routinedatas[widget.rindex];
    bool btnDisabled = false;
    for (int i = 0; i < numEx; i++) {
      weightController.add(Controllerlist());
      repsController.add(Controllerlist());
      for (int s = 0; s < routine.exercises[i].sets.length; s++) {
        weightController[i].controllerlist.add(TextEditingController(
            text: routine.exercises[i].sets[s].weight == 0
                ? null
                : (routine.exercises[i].sets[s].weight % 1) == 0
                    ? routine.exercises[i].sets[s].weight.toStringAsFixed(0)
                    : routine.exercises[i].sets[s].weight.toStringAsFixed(1)));
        repsController[i].controllerlist.add(TextEditingController(
            text: routine.exercises[i].sets[s].reps == 1
                ? null
                : routine.exercises[i].sets[s].reps.toStringAsFixed(0)));
      }
    }
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onPanUpdate: (details) {
          if (details.delta.dx > 10 && btnDisabled == false) {
            btnDisabled = true;
            Navigator.of(context).pop();
            print("Dragging in +X direction");
          }
        },
        child: PageView.builder(
          onPageChanged: (value) {
            if (_routinetimeProvider.nowonrindex == widget.rindex) {
              _routinetimeProvider.nowoneindexupdate(value);
            }
          },
          controller: controller,
          itemBuilder: (context, pindex) {
            _currentExindex = pindex;
            final exercise = _exProvider.exercisesdata.exercises.firstWhere(
                (element) => element.name == routine.exercises[pindex].name);
            if (exercise == null) {
              return Container(); // 예외 처리 필요한 경우 적절히 처리
            }

            if (exercise.category == '맨몸') {
              return _bodyexercisedetailWidget(pindex);
            } else if (exercise.category == '유산소') {
              return _cardioexercisedetailWidget(pindex);
            } else {
              return _exercisedetailWidget(pindex);
            }
          },
          itemCount: numEx,
        ));
  }

  Widget _exercisedetailWidget(pindex) {
    int ueindex = _exProvider.exercisesdata.exercises.indexWhere((element) =>
        element.name ==
        _workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[pindex].name);

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            isKeyboardVisible
                ? Consumer<RoutineTimeProvider>(
                    builder: (context, provider, child) {
                    final userest = provider.userest;
                    final timeron = provider.timeron;
                    final routineTime = provider.routineTime;
                    final isNegativeTimer = userest && timeron < 0;
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userest ? ' 휴식 시간 : ' : " 운동 시간 :",
                            textScaleFactor: 1.7,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                              userest
                                  ? isNegativeTimer
                                      ? '-${(-timeron / 60).floor()}:${((-timeron % 60) / 10).floor()}${((-timeron % 60) % 10)}'
                                      : '${(timeron / 60).floor()}:${((timeron % 60) / 10).floor()}${((timeron % 60) % 10)}'
                                  : '${(routineTime / 60).floor()}:${((routineTime % 60) / 10).floor()}${((routineTime % 60) % 10)}',
                              textScaleFactor: 1.7,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (userest && isNegativeTimer)
                                      ? Colors.red
                                      : Theme.of(context).primaryColorLight))
                        ]);
                  })
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Consumer<RoutineTimeProvider>(
                          builder: (context, provider, child) {
                        final userest = provider.userest;
                        final timeron = provider.timeron;
                        final routineTime = provider.routineTime;
                        final isNegativeTimer = userest && timeron < 0;
                        return Row(children: [
                          Text(
                            userest ? ' 휴식 시간 : ' : " 운동 시간 : ",
                            textScaleFactor: 1.4,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                              userest
                                  ? isNegativeTimer
                                      ? '-${(-timeron / 60).floor()}:${((-timeron % 60) / 10).floor()}${((-timeron % 60) % 10)}'
                                      : '${(timeron / 60).floor()}:${((timeron % 60) / 10).floor()}${((timeron % 60) % 10)}'
                                  : '${(routineTime / 60).floor()}:${((routineTime % 60) / 10).floor()}${((routineTime % 60) % 10)}',
                              textScaleFactor: 1.4,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (userest && timeron < 0)
                                      ? Colors.red
                                      : Theme.of(context).primaryColorLight))
                        ]);
                      }),
                      Consumer<WorkoutdataProvider>(
                          builder: (builder, provider, child) {
                        final exercise = provider.workoutdata
                            .routinedatas[widget.rindex].exercises[pindex];
                        final restDuration = Duration(seconds: exercise.rest);
                        return GestureDetector(
                          onTap: () {
                            showCupertinoModalPopup<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return _buildContainer(timerPicker2(
                                    restDuration,
                                    pindex,
                                  ));
                                });
                          },
                          child: Text(
                            "Rest: ${exercise.rest}초",
                            textScaleFactor: 1.4,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              exguide(ueindex);
                            },
                            child: Consumer<WorkoutdataProvider>(
                                builder: (builder, provider, child) {
                              var exercise = provider
                                  .workoutdata
                                  .routinedatas[widget.rindex]
                                  .exercises[pindex];
                              var exImage = "";
                              try {
                                final index =
                                    extra_completely_new_Ex.indexWhere(
                                  (element) => element.name == exercise.name,
                                );
                                if (index != -1) {
                                  exImage =
                                      extra_completely_new_Ex[index].image ??
                                          "";
                                }
                              } catch (e) {
                                exImage = "";
                              }
                              return Column(
                                children: [
                                  if (!isKeyboardVisible && exImage != "")
                                    Image.asset(
                                      exImage,
                                      height: 160,
                                      width: 160,
                                      fit: BoxFit.cover,
                                    ),
                                  if (!isKeyboardVisible && exImage == "")
                                    const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (exercise.name.length < 10)
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: Theme.of(context).canvasColor,
                                        ),
                                      if (isKeyboardVisible)
                                        Text(
                                          exercise.name,
                                          textScaleFactor: 2.0,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                        )
                                      else if (exercise.name.length < 8)
                                        Text(
                                          exercise.name,
                                          textScaleFactor: 3.2,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                        )
                                      else
                                        Flexible(
                                          child: Text(
                                            exercise.name,
                                            textScaleFactor: 2.4,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                            ),
                                          ),
                                        ),
                                      Column(
                                        children: [
                                          Container(height: 7),
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                          ),
                          Consumer<ExercisesdataProvider>(
                              builder: (builder, provider, child) {
                            final info =
                                provider.exercisesdata.exercises[ueindex];
                            return isKeyboardVisible
                                ? Container()
                                : GestureDetector(
                                    onTap: () {
                                      exGoalEditAlert(context, info);
                                    },
                                    child: Text(
                                        "1RM/목표: ${info.onerm.toStringAsFixed(1)}/${info.goal.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                                        textScaleFactor: 1.3,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark)));
                          })
                        ]),
                    const SizedBox(height: 16),
                    Container(
                        padding: const EdgeInsets.only(right: 10, bottom: 0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  width: 60,
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text("완료",
                                      textScaleFactor: 1.1,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                    Container(
                                        width: 40,
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: Text("세트",
                                            textScaleFactor: 1.1,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center)),
                                    SizedBox(
                                        width: 70,
                                        child: Text(
                                            "무게(${_userProvider.userdata.weight_unit})",
                                            textScaleFactor: 1.1,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center)),
                                    Container(width: 30),
                                    SizedBox(
                                        width: 40,
                                        child: Text("회",
                                            textScaleFactor: 1.1,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center)),
                                    SizedBox(
                                        width: 70,
                                        child: Text("1RM",
                                            textScaleFactor: 1.1,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center))
                                  ]))
                            ])),
                    Consumer<WorkoutdataProvider>(
                        builder: (builder, provider, child) {
                      final sets = provider.workoutdata
                          .routinedatas[widget.rindex].exercises[pindex].sets;
                      if (_isSetChanged == true) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          _controller.animateTo(
                              _controller.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut);
                        });
                        _isSetChanged = false;
                      }
                      return Column(
                        children: [
                          ListView.separated(
                              shrinkWrap: true,
                              controller: _controller,
                              itemBuilder: (BuildContext context, int index) {
                                final set = sets[index];
                                return Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
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
                                                checkColor: Theme.of(context)
                                                    .highlightColor,
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                side: BorderSide(
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .primaryColorDark),
                                                value: sets[index].ischecked,
                                                onChanged: (newvalue) {
                                                  if (_routinetimeProvider
                                                      .isstarted) {
                                                    _workoutProvider.boolcheck(
                                                        widget.rindex,
                                                        pindex,
                                                        index,
                                                        newvalue);
                                                    if (newvalue == true) {
                                                      _routinetimeProvider
                                                          .resettimer(provider
                                                              .workoutdata
                                                              .routinedatas[
                                                                  widget.rindex]
                                                              .exercises[pindex]
                                                              .rest);
                                                      _workoutOnermCheck(
                                                          set, ueindex);
                                                      if (index ==
                                                          sets.length - 1) {
                                                        _workoutProvider
                                                            .setsplus(
                                                                widget.rindex,
                                                                pindex,
                                                                sets.last);
                                                        _isSetChanged = true;
                                                        weightController[pindex]
                                                            .controllerlist
                                                            .add(
                                                                TextEditingController(
                                                                    text:
                                                                        null));
                                                        repsController[pindex]
                                                            .controllerlist
                                                            .add(
                                                                TextEditingController(
                                                                    text:
                                                                        null));
                                                        showToast(
                                                            "세트를 추가했어요 필요없으면 다음으로 넘어가보세요");
                                                      }
                                                    }
                                                    _editWorkoutwCheck();
                                                  } else {
                                                    _showMyDialog(pindex, index,
                                                        newvalue);
                                                  }
                                                },
                                              ),
                                            )),
                                      ),
                                      Expanded(
                                        child: Slidable(
                                          startActionPane: ActionPane(
                                              extentRatio: 1.0,
                                              motion: CustomMotion(
                                                  onOpen: () {
                                                    if (_routinetimeProvider
                                                        .isstarted) {
                                                      _workoutProvider
                                                          .boolcheck(
                                                              widget.rindex,
                                                              pindex,
                                                              index,
                                                              true);
                                                      _routinetimeProvider
                                                          .resettimer(provider
                                                              .workoutdata
                                                              .routinedatas[
                                                                  widget.rindex]
                                                              .exercises[pindex]
                                                              .rest);
                                                      _workoutOnermCheck(
                                                          set, ueindex);
                                                      if (index ==
                                                          sets.length - 1) {
                                                        _workoutProvider
                                                            .setsplus(
                                                                widget.rindex,
                                                                pindex,
                                                                sets.last);
                                                        _isSetChanged = true;
                                                        weightController[pindex]
                                                            .controllerlist
                                                            .add(
                                                                TextEditingController(
                                                                    text:
                                                                        null));
                                                        repsController[pindex]
                                                            .controllerlist
                                                            .add(
                                                                TextEditingController(
                                                                    text:
                                                                        null));
                                                        showToast(
                                                            "세트를 추가했어요! 다음으로 넘어갈 수도 있어요");
                                                      }
                                                      _editWorkoutwCheck();
                                                    } else {
                                                      _showMyDialog(
                                                          pindex, index, true);
                                                    }
                                                  },
                                                  onClose: () {},
                                                  motionWidget:
                                                      const StretchMotion()),
                                              children: [
                                                SlidableAction(
                                                    autoClose: true,
                                                    onPressed: (_) {},
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    foregroundColor:
                                                        Theme.of(context)
                                                            .highlightColor,
                                                    icon: Icons.check,
                                                    label: '밀어서 check')
                                              ]),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: 40,
                                                child: Text(
                                                  "${index + 1}",
                                                  textScaleFactor: 1.7,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 70,
                                                child: TextField(
                                                  controller: weightController[
                                                          pindex]
                                                      .controllerlist[index],
                                                  keyboardType:
                                                      const TextInputType
                                                              .numberWithOptions(
                                                          signed: false,
                                                          decimal: true),
                                                  style: TextStyle(
                                                    fontSize: _themeProvider
                                                            .userFontSize *
                                                        21 /
                                                        0.8,
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText:
                                                        "${sets[index].weight}",
                                                    hintStyle: TextStyle(
                                                      fontSize: _themeProvider
                                                              .userFontSize *
                                                          21 /
                                                          0.8,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
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
                                                    _workoutProvider
                                                        .weightcheck(
                                                            widget.rindex,
                                                            pindex,
                                                            index,
                                                            changeweight);
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                  width: 30,
                                                  child: SvgPicture.asset(
                                                      "assets/svg/multiply.svg",
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      height: 16 *
                                                          _themeProvider
                                                              .userFontSize /
                                                          0.8)),
                                              SizedBox(
                                                width: 40,
                                                child: TextField(
                                                  controller: repsController[
                                                          pindex]
                                                      .controllerlist[index],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  style: TextStyle(
                                                    fontSize: _themeProvider
                                                            .userFontSize *
                                                        21 /
                                                        0.8,
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText:
                                                        "${sets[index].reps}",
                                                    hintStyle: TextStyle(
                                                      fontSize: 21 *
                                                          _themeProvider
                                                              .userFontSize /
                                                          0.8,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                  ),
                                                  onChanged: (text) {
                                                    final changereps =
                                                        text.isEmpty
                                                            ? 1
                                                            : int.parse(text);
                                                    _workoutProvider.repscheck(
                                                        widget.rindex,
                                                        pindex,
                                                        index,
                                                        changereps);
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                  width: 70,
                                                  child: Text(
                                                    (sets[index].reps != 1)
                                                        ? "${(sets[index].weight * (1 + sets[index].reps / 30)).toStringAsFixed(1)}"
                                                        : "${sets[index].weight}",
                                                    textScaleFactor: 1.7,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColorLight),
                                                    textAlign: TextAlign.center,
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
                                  (BuildContext context, int index) {
                                return Container(
                                    alignment: Alignment.center,
                                    height: 0.5,
                                    child: Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        height: 0.5,
                                        color: Theme.of(context)
                                            .primaryColorDark));
                              },
                              itemCount: sets.length),
                          SizedBox(
                            height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _workoutProvider.setsminus(
                                          widget.rindex, pindex);
                                      weightController[pindex]
                                          .controllerlist
                                          .removeLast();
                                      repsController[pindex]
                                          .controllerlist
                                          .removeLast();
                                    },
                                    icon: Icon(Icons.remove,
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        size: 24)),
                                IconButton(
                                    onPressed: () {
                                      _isSetChanged = true;
                                      _workoutProvider.setsplus(
                                          widget.rindex, pindex, sets.last);
                                      weightController[pindex]
                                          .controllerlist
                                          .add(TextEditingController(
                                              text: null));
                                      repsController[pindex].controllerlist.add(
                                          TextEditingController(text: null));
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      size: 24,
                                    )),
                              ],
                            ),
                          )
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 16),
                child: Consumer2<WorkoutdataProvider, RoutineTimeProvider>(
                    builder: (builder, provider, provider2, child) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 48,
                          width: provider2.nowonrindex == widget.rindex &&
                                  _routinetimeProvider.isstarted
                              ? MediaQuery.of(context).size.width / 3 + 8
                              : MediaQuery.of(context).size.width / 2 - 16,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 1,
                                primary:
                                    (provider2.nowonrindex != widget.rindex) &&
                                            _routinetimeProvider.isstarted
                                        ? const Color(0xFF212121)
                                        : provider2.buttoncolor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if ((provider2.nowonrindex != widget.rindex) &&
                                  _routinetimeProvider.isstarted) {
                                return null;
                              } else {
                                if (_routinetimeProvider.isstarted) {
                                  _showMyDialog_finish();
                                } else {
                                  _routinetimeProvider.resettimer(
                                      _workoutProvider
                                          .workoutdata
                                          .routinedatas[widget.rindex]
                                          .exercises[pindex]
                                          .rest);
                                  provider2.routinecheck(widget.rindex);
                                }
                              }
                            },
                            child: Text(
                                (provider2.nowonrindex != widget.rindex) &&
                                        _routinetimeProvider.isstarted
                                    ? '다른 루틴 수행중'
                                    : provider2.routineButton),
                          ),
                        ),
                        if (provider2.nowonrindex == widget.rindex &&
                            _routinetimeProvider.isstarted)
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 4 - 32,
                              height: 48,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 1,
                                    primary: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: btnDisabled
                                      ? null
                                      : () {
                                          btnDisabled = true;
                                          Navigator.of(context).pop();
                                          _editWorkoutCheck();
                                        },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "목록",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .indicatorColor),
                                        )
                                      ]))),
                        SizedBox(
                            width: provider2.nowonrindex == widget.rindex &&
                                    _routinetimeProvider.isstarted
                                ? MediaQuery.of(context).size.width / 3 + 8
                                : MediaQuery.of(context).size.width / 2 - 16,
                            height: 48,
                            child: pindex !=
                                    _workoutProvider
                                            .workoutdata
                                            .routinedatas[widget.rindex]
                                            .exercises
                                            .length -
                                        1
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 1,
                                      primary: provider2.nowonrindex ==
                                                  widget.rindex &&
                                              provider2.isstarted
                                          ? const Color(0xffceec97)
                                          : Theme.of(context).primaryColorDark,
                                    ),
                                    onPressed: () {
                                      controller!.nextPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut);
                                    },
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16.0),
                                                    child: Text("다음 운동",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Theme.of(
                                                                    context)
                                                                .shadowColor))),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_outlined,
                                                  color: Theme.of(context)
                                                      .shadowColor,
                                                  size: 24,
                                                )
                                              ]),
                                          Text(
                                              provider
                                                  .workoutdata
                                                  .routinedatas[widget.rindex]
                                                  .exercises[pindex + 1]
                                                  .name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .shadowColor))
                                        ]))
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 1,
                                      primary:
                                          Theme.of(context).primaryColorDark,
                                    ),
                                    onPressed: () {
                                      showToast("운동을 종료해주세요");
                                    },
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("운동 완료",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .shadowColor))
                                              ])
                                        ])))
                      ]);
                }))
          ]));
    });
  }

  Future<void> _showMyDialog(pindex, index, newvalue, [init_duration]) async {
    final sets = _workoutProvider
        .workoutdata.routinedatas[widget.rindex].exercises[pindex].sets;
    final ueindex = _exProvider.exercisesdata.exercises.indexWhere((element) =>
        element.name ==
        _workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[pindex].name);

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
      _routinetimeProvider.resettimer(_workoutProvider
          .workoutdata.routinedatas[widget.rindex].exercises[pindex].rest);
      _routinetimeProvider.routinecheck(widget.rindex);

      _workoutProvider.boolcheck(widget.rindex, pindex, index, newvalue);
      _editWorkoutwCheck();
      _workoutOnermCheck(sets[index], ueindex);

      if (_exProvider
              .exercisesdata
              .exercises[_exProvider.exercisesdata.exercises.indexWhere(
                  (element) =>
                      element.name ==
                      _workoutProvider.workoutdata.routinedatas[widget.rindex]
                          .exercises[pindex].name)]
              .category ==
          '유산소') {
        _countcontroller[index].restart(duration: init_duration);
      }
    }
  }

  Future<void> _showMyDialog_finish() async {
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

  void _workoutOnermCheck(Sets sets, ueindex) {
    final exercise = _exProvider.exercisesdata.exercises[ueindex];
    final onerm =
        (sets.reps != 1) ? (sets.weight * (1 + sets.reps / 30)) : sets.weight;

    if (onerm > exercise.onerm) {
      final exerciseIndex = _exProvider.exercisesdata.exercises
          .indexWhere((element) => element.name == exercise.name);
      _exProvider.putOnermValue(exerciseIndex, onerm);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return newOnermAlerts(onerm: onerm, sets: sets, exercise: exercise);
          });
      _routinetimeProvider.newRoutineUpdate();
    }
  }

  Widget _bodyexercisedetailWidget(pindex) {
    int ueindex = _exProvider.exercisesdata.exercises.indexWhere((element) =>
        element.name ==
        _workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[pindex].name);

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              isKeyboardVisible
                  ? Container(child: Consumer<RoutineTimeProvider>(
                      builder: (context, provider, child) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.userest ? ' 휴식 시간 : ' : " 운동 시간 : ",
                              textScaleFactor: 1.4,
                              style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                                provider.userest
                                    ? provider.timeron < 0
                                        ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                        : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                    : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                textScaleFactor: 1.4,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (provider.userest &&
                                            provider.timeron < 0)
                                        ? Colors.red
                                        : Theme.of(context).primaryColorLight))
                          ]);
                    }))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<RoutineTimeProvider>(
                                builder: (context, provider, child) {
                              return Row(children: [
                                Text(
                                  provider.userest ? ' 휴식 시간 : ' : " 운동 시간 : ",
                                  textScaleFactor: 1.4,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    provider.userest
                                        ? provider.timeron < 0
                                            ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                            : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                        : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                    textScaleFactor: 1.4,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (provider.userest &&
                                                provider.timeron < 0)
                                            ? Colors.red
                                            : Theme.of(context)
                                                .primaryColorLight))
                              ]);
                            }),
                            Consumer<WorkoutdataProvider>(
                                builder: (builder, provider, child) {
                              _exercise = provider
                                  .workoutdata
                                  .routinedatas[widget.rindex]
                                  .exercises[pindex];
                              Duration time = Duration(seconds: _exercise.rest);
                              return GestureDetector(
                                onTap: () {
                                  showCupertinoModalPopup<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return _buildContainer(timerPicker2(
                                          time,
                                          pindex,
                                        ));
                                      });
                                },
                                child: Text(
                                  "Rest: ${_exercise.rest}초",
                                  textScaleFactor: 1.4,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              exguide(ueindex);
                            },
                            child: Consumer<WorkoutdataProvider>(
                                builder: (builder, provider, child) {
                              var exercise = provider
                                  .workoutdata
                                  .routinedatas[widget.rindex]
                                  .exercises[pindex];
                              var exImage;
                              try {
                                exImage = extra_completely_new_Ex[
                                        extra_completely_new_Ex.indexWhere(
                                            (element) =>
                                                element.name == exercise.name)]
                                    .image;
                                exImage ??= "";
                              } catch (e) {
                                exImage = "";
                              }
                              return Column(
                                children: [
                                  isKeyboardVisible
                                      ? Container()
                                      : exImage != ""
                                          ? Image.asset(
                                              exImage,
                                              height: 160,
                                              width: 160,
                                              fit: BoxFit.cover,
                                            )
                                          : const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      exercise.name.length < 10
                                          ? Icon(
                                              Icons.info_outline_rounded,
                                              color:
                                                  Theme.of(context).canvasColor,
                                            )
                                          : Container(),
                                      isKeyboardVisible
                                          ? Text(
                                              exercise.name,
                                              textScaleFactor: 2.0,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorLight),
                                            )
                                          : exercise.name.length < 8
                                              ? Text(
                                                  exercise.name,
                                                  textScaleFactor: 3.2,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  ),
                                                )
                                              : Flexible(
                                                  child: Text(
                                                    exercise.name,
                                                    textScaleFactor: 2.4,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                  ),
                                                ),
                                      Column(
                                        children: [
                                          Container(
                                            height: 7,
                                          ),
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                          ),
                          Consumer<ExercisesdataProvider>(
                              builder: (builder, provider, child) {
                            var info =
                                provider.exercisesdata.exercises[ueindex];
                            return isKeyboardVisible
                                ? Container()
                                : Text(
                                    "1RM/목표: ${info.onerm.toStringAsFixed(1)}/${info.goal.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                                    textScaleFactor: 1.7,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  width: 60,
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    "완료",
                                    textScaleFactor: 1.1,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        width: 40,
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: Text(
                                          "세트",
                                          textScaleFactor: 1.1,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                        width: 70,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "무게",
                                              textScaleFactor: 1.1,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                tooltipController.showTooltip();
                                              },
                                              child: JustTheTooltip(
                                                controller: tooltipController,
                                                content: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '맨몸 카테고리의 운동은 기본 무게가 체중으로 세팅되고,\n무게를 누르면 체중에 추가/제거가 가능해요. 피드에는 몸무게를 제외한 추가 중량만 기록되요',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColorLight),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.zero,
                                                  child: Icon(
                                                    Icons.info_outline_rounded,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Container(width: 30),
                                    SizedBox(
                                        width: 40,
                                        child: Text(
                                          "회",
                                          textScaleFactor: 1.1,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
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
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Consumer2<WorkoutdataProvider, UserdataProvider>(
                          builder: (builder, provider, provider2, child) {
                        var sets = provider.workoutdata
                            .routinedatas[widget.rindex].exercises[pindex].sets;
                        if (_isSetChanged == true) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            _controller.animateTo(
                              _controller.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            );
                          });
                          _isSetChanged = false;
                        } else {
                          null;
                        }

                        return Column(
                          children: [
                            ListView.separated(
                                shrinkWrap: true,
                                controller: _controller,
                                itemBuilder: (BuildContext context, int index) {
                                  weightController[pindex]
                                          .controllerlist[index]
                                          .text =
                                      provider2.userdata.bodyStats.last.weight
                                          .toString();
                                  provider
                                          .workoutdata
                                          .routinedatas[widget.rindex]
                                          .exercises[pindex]
                                          .sets[index]
                                          .index =
                                      provider2.userdata.bodyStats.last.weight;
                                  return Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
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
                                                    checkColor:
                                                        Theme.of(context)
                                                            .highlightColor,
                                                    activeColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: Theme.of(context)
                                                            .primaryColorDark),
                                                    value:
                                                        sets[index].ischecked,
                                                    onChanged: (newvalue) {
                                                      _routinetimeProvider
                                                              .isstarted
                                                          ? [
                                                              _workoutProvider
                                                                  .boolcheck(
                                                                      widget
                                                                          .rindex,
                                                                      pindex,
                                                                      index,
                                                                      newvalue),
                                                              newvalue == true
                                                                  ? [
                                                                      _routinetimeProvider.resettimer(provider
                                                                          .workoutdata
                                                                          .routinedatas[widget
                                                                              .rindex]
                                                                          .exercises[
                                                                              pindex]
                                                                          .rest),
                                                                      _workoutOnermCheck(
                                                                          sets[
                                                                              index],
                                                                          ueindex),
                                                                      index ==
                                                                              sets.length - 1
                                                                          ? [
                                                                              _workoutProvider.setsplus(widget.rindex, pindex, sets.last),
                                                                              _isSetChanged = true,
                                                                              print("jjjjjjjjjjjjjj"),
                                                                              weightController[pindex].controllerlist.add(TextEditingController(text: provider2.userdata.bodyStats.last.weight.toString())),
                                                                              repsController[pindex].controllerlist.add(TextEditingController(text: null)),
                                                                              showToast("세트를 추가했어요 필요없으면 다음으로 넘어가보세요"),
                                                                            ]
                                                                          : null,
                                                                    ]
                                                                  : null,
                                                              _editWorkoutwCheck()
                                                            ]
                                                          : _showMyDialog(
                                                              pindex,
                                                              index,
                                                              newvalue);
                                                    }),
                                              )),
                                        ),
                                        Expanded(
                                          child: Slidable(
                                            startActionPane: ActionPane(
                                                extentRatio: 1.0,
                                                motion: CustomMotion(
                                                  onOpen: () {
                                                    _routinetimeProvider
                                                            .isstarted
                                                        ? [
                                                            _workoutProvider
                                                                .boolcheck(
                                                                    widget
                                                                        .rindex,
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
                                                            _workoutOnermCheck(
                                                                sets[index],
                                                                ueindex),
                                                            index ==
                                                                    sets.length -
                                                                        1
                                                                ? [
                                                                    _workoutProvider.setsplus(
                                                                        widget
                                                                            .rindex,
                                                                        pindex,
                                                                        sets.last),
                                                                    _isSetChanged =
                                                                        true,
                                                                    weightController[pindex].controllerlist.add(TextEditingController(
                                                                        text: provider2
                                                                            .userdata
                                                                            .bodyStats
                                                                            .last
                                                                            .weight
                                                                            .toString())),
                                                                    repsController[
                                                                            pindex]
                                                                        .controllerlist
                                                                        .add(TextEditingController(
                                                                            text:
                                                                                null)),
                                                                    showToast(
                                                                        "세트를 추가했어요! 다음으로 넘어갈 수도 있어요")
                                                                  ]
                                                                : null,
                                                            _editWorkoutwCheck()
                                                          ]
                                                        : _showMyDialog(pindex,
                                                            index, true);
                                                  },
                                                  onClose: () {},
                                                  motionWidget:
                                                      const StretchMotion(),
                                                ),
                                                children: [
                                                  SlidableAction(
                                                    autoClose: true,
                                                    onPressed: (_) {},
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    foregroundColor:
                                                        Theme.of(context)
                                                            .highlightColor,
                                                    icon: Icons.check,
                                                    label: '밀어서 check',
                                                  )
                                                ]),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 40,
                                                  child: Text(
                                                    "${index + 1}",
                                                    textScaleFactor: 1.7,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 70,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return setWeightAlert(
                                                                eindex: index,
                                                                pindex: pindex,
                                                                rindex: widget
                                                                    .rindex,
                                                              );
                                                            });
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                            "${sets[index].index + sets[index].weight}",
                                                            textScaleFactor:
                                                                1.7,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorLight,
                                                            )),
                                                      ),
                                                    )),
                                                SizedBox(
                                                    width: 30,
                                                    child: SvgPicture.asset(
                                                        "assets/svg/multiply.svg",
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        height: 16 *
                                                            _themeProvider
                                                                .userFontSize /
                                                            0.8)),
                                                SizedBox(
                                                  width: 40,
                                                  child: TextField(
                                                    controller: repsController[
                                                            pindex]
                                                        .controllerlist[index],
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: TextStyle(
                                                      fontSize: _themeProvider
                                                              .userFontSize *
                                                          21 /
                                                          0.8,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText:
                                                          "${sets[index].reps}",
                                                      hintStyle: TextStyle(
                                                        fontSize: 21 *
                                                            _themeProvider
                                                                .userFontSize /
                                                            0.8,
                                                        color: Theme.of(context)
                                                            .primaryColorLight,
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
                                                      _workoutProvider
                                                          .repscheck(
                                                              widget.rindex,
                                                              pindex,
                                                              index,
                                                              changereps);
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 70,
                                                    child: (sets[index].reps !=
                                                            1)
                                                        ? Text(
                                                            "${((sets[index].weight + sets[index].index) * (1 + sets[index].reps / 30)).toStringAsFixed(1)}",
                                                            textScaleFactor:
                                                                1.8,
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorLight),
                                                            textAlign: TextAlign
                                                                .center,
                                                          )
                                                        : Text(
                                                            "${sets[index].weight + sets[index].index}",
                                                            textScaleFactor:
                                                                1.8,
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorLight),
                                                            textAlign: TextAlign
                                                                .center,
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
                                    (BuildContext context, int index) {
                                  return Container(
                                      alignment: Alignment.center,
                                      height: 0.5,
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        height: 0.5,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ));
                                },
                                itemCount: sets.length),
                            SizedBox(
                              height: 50,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _workoutProvider.setsminus(
                                            widget.rindex, pindex);
                                        weightController[pindex]
                                            .controllerlist
                                            .removeLast();
                                        repsController[pindex]
                                            .controllerlist
                                            .removeLast();
                                      },
                                      icon: Icon(
                                        Icons.remove,
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        size: 24,
                                      )),
                                  IconButton(
                                      onPressed: () {
                                        _isSetChanged = true;
                                        _workoutProvider.setsplus(
                                            widget.rindex, pindex, sets.last);
                                        weightController[pindex]
                                            .controllerlist
                                            .add(TextEditingController(
                                                text: provider2.userdata
                                                    .bodyStats.last.weight
                                                    .toString()));
                                        repsController[pindex]
                                            .controllerlist
                                            .add(TextEditingController(
                                                text: null));
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        size: 24,
                                      )),
                                ],
                              ),
                            )
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                child: Consumer2<WorkoutdataProvider, RoutineTimeProvider>(
                    builder: (builder, provider, provider2, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 48,
                        width: provider2.nowonrindex == widget.rindex &&
                                _routinetimeProvider.isstarted
                            ? MediaQuery.of(context).size.width / 3 + 8
                            : MediaQuery.of(context).size.width / 2 - 16,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 1,
                              primary:
                                  (provider2.nowonrindex != widget.rindex) &&
                                          _routinetimeProvider.isstarted
                                      ? const Color(0xFF212121)
                                      : provider2.buttoncolor,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          onPressed: () {
                            (provider2.nowonrindex != widget.rindex) &&
                                    _routinetimeProvider.isstarted
                                ? null
                                : [
                                    if (_routinetimeProvider.isstarted)
                                      {_showMyDialog_finish()}
                                    else
                                      {
                                        _routinetimeProvider.resettimer(
                                            _workoutProvider
                                                .workoutdata
                                                .routinedatas[widget.rindex]
                                                .exercises[pindex]
                                                .rest),
                                        provider2.routinecheck(widget.rindex)
                                      }
                                  ];
                          },
                          child: Text(
                              (provider2.nowonrindex != widget.rindex) &&
                                      _routinetimeProvider.isstarted
                                  ? '다른 루틴 수행중'
                                  : provider2.routineButton),
                        ),
                      ),
                      provider2.nowonrindex == widget.rindex &&
                              _routinetimeProvider.isstarted
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width / 4 - 32,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 1,
                                  primary: Theme.of(context).primaryColorDark,
                                ),
                                onPressed: () {
                                  btnDisabled == true
                                      ? null
                                      : [
                                          btnDisabled = true,
                                          Navigator.of(context).pop(),
                                          _editWorkoutCheck()
                                        ];
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "목록",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).indicatorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          : Container(),
                      SizedBox(
                        width: provider2.nowonrindex == widget.rindex &&
                                _routinetimeProvider.isstarted
                            ? MediaQuery.of(context).size.width / 3 + 8
                            : MediaQuery.of(context).size.width / 2 - 16,
                        height: 48,
                        child: pindex !=
                                _workoutProvider
                                        .workoutdata
                                        .routinedatas[widget.rindex]
                                        .exercises
                                        .length -
                                    1
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 1,
                                  primary:
                                      provider2.nowonrindex == widget.rindex &&
                                              provider2.isstarted
                                          ? const Color(0xffceec97)
                                          : Theme.of(context).primaryColorDark,
                                ),
                                onPressed: () {
                                  controller!.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            "다음 운동",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Theme.of(context).shadowColor,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Theme.of(context).shadowColor,
                                          size: 24,
                                        )
                                      ],
                                    ),
                                    Text(
                                        provider
                                            .workoutdata
                                            .routinedatas[widget.rindex]
                                            .exercises[pindex + 1]
                                            .name,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).shadowColor,
                                        ))
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 1,
                                  primary: Theme.of(context).primaryColorDark,
                                ),
                                onPressed: () {
                                  showToast("운동을 종료해주세요");
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "운동 완료",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).shadowColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      )
                    ],
                  );
                }),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _cardioexercisedetailWidget(pindex) {
    int ueindex = _exProvider.exercisesdata.exercises.indexWhere((element) =>
        element.name ==
        _workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[pindex].name);

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              isKeyboardVisible
                  ? Consumer<RoutineTimeProvider>(
                      builder: (context, provider, child) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.userest ? ' 휴식 시간 : ' : ' 운동 시간 : ',
                              textScaleFactor: 1.4,
                              style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                                provider.userest
                                    ? provider.timeron < 0
                                        ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                        : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                    : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                textScaleFactor: 1.4,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (provider.userest &&
                                            provider.timeron < 0)
                                        ? Colors.red
                                        : Theme.of(context).primaryColorLight))
                          ]);
                    })
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<RoutineTimeProvider>(
                                builder: (context, provider, child) {
                              return Row(children: [
                                Text(
                                  provider.userest ? ' 휴식 시간 : ' : ' 운동 시간 : ',
                                  textScaleFactor: 1.4,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    provider.userest
                                        ? provider.timeron < 0
                                            ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                            : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                        : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                    textScaleFactor: 1.4,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (provider.userest &&
                                                provider.timeron < 0)
                                            ? Colors.red
                                            : Theme.of(context)
                                                .primaryColorLight))
                              ]);
                            }),
                          ],
                        ),
                        Consumer<WorkoutdataProvider>(
                            builder: (builder, provider, child) {
                          _exercise = provider.workoutdata
                              .routinedatas[widget.rindex].exercises[pindex];
                          Duration time = Duration(seconds: _exercise.rest);
                          return GestureDetector(
                            onTap: () {
                              showCupertinoModalPopup<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return _buildContainer(timerPicker2(
                                      time,
                                      pindex,
                                    ));
                                  });
                            },
                            child: Text(
                              "Rest: ${_exercise.rest}초",
                              textScaleFactor: 1.4,
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer<WorkoutdataProvider>(
                              builder: (builder, provider, child) {
                            var exercise = provider.workoutdata
                                .routinedatas[widget.rindex].exercises[pindex];
                            var exImage;
                            try {
                              exImage = extra_completely_new_Ex[
                                      extra_completely_new_Ex.indexWhere(
                                          (element) =>
                                              element.name == exercise.name)]
                                  .image;

                              exImage ??= "";
                            } catch (e) {
                              exImage = "";
                            }
                            return GestureDetector(
                                onTap: () {
                                  exguide(ueindex);
                                },
                                child: Column(children: [
                                  isKeyboardVisible
                                      ? Container()
                                      : exImage != ""
                                          ? Image.asset(
                                              exImage,
                                              height: 160,
                                              width: 160,
                                              fit: BoxFit.cover,
                                            )
                                          : const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      exercise.name.length < 10
                                          ? Icon(
                                              Icons.info_outline_rounded,
                                              color:
                                                  Theme.of(context).canvasColor,
                                            )
                                          : Container(),
                                      isKeyboardVisible
                                          ? Text(
                                              exercise.name,
                                              textScaleFactor: 2.0,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorLight),
                                            )
                                          : exercise.name.length < 8
                                              ? Text(
                                                  exercise.name,
                                                  textScaleFactor: 3.2,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  ),
                                                )
                                              : Flexible(
                                                  child: Text(
                                                    exercise.name,
                                                    textScaleFactor: 2.4,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColorLight),
                                                  ),
                                                ),
                                      Column(
                                        children: [
                                          Container(
                                            height: 7,
                                          ),
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ]));
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  width: 60,
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    "완료",
                                    textScaleFactor: 1.1,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        width: 40,
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: Text(
                                          "세트",
                                          textScaleFactor: 1.1,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                        width: 80,
                                        child: Text(
                                          "거리(Km)",
                                          textScaleFactor: 1.1,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                        width: 110,
                                        child: Text(
                                          "시간(시:분:초)",
                                          textScaleFactor: 1.1,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Consumer2<WorkoutdataProvider, UserdataProvider>(
                          builder: (builder, provider, provider2, child) {
                        var sets = provider.workoutdata
                            .routinedatas[widget.rindex].exercises[pindex].sets;
                        if (_isSetChanged == true) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            _controller.animateTo(
                              _controller.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            );
                          });
                          _isSetChanged = false;
                        } else {
                          null;
                        }

                        return Column(
                          children: [
                            ListView.separated(
                                shrinkWrap: true,
                                controller: _controller,
                                itemBuilder: (BuildContext context, int index) {
                                  Duration time =
                                      Duration(seconds: sets[index].reps);
                                  provider
                                          .workoutdata
                                          .routinedatas[widget.rindex]
                                          .exercises[pindex]
                                          .sets[index]
                                          .index =
                                      provider2.userdata.bodyStats.last.weight;
                                  return Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
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
                                                    checkColor:
                                                        Theme.of(context)
                                                            .highlightColor,
                                                    activeColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    side: BorderSide(
                                                        width: 1,
                                                        color: Theme.of(context)
                                                            .primaryColorDark),
                                                    value:
                                                        sets[index].ischecked,
                                                    onChanged: (newvalue) {
                                                      _routinetimeProvider
                                                              .isstarted
                                                          ? [
                                                              _workoutProvider
                                                                  .boolcheck(
                                                                      widget
                                                                          .rindex,
                                                                      pindex,
                                                                      index,
                                                                      newvalue),
                                                              newvalue == true
                                                                  ? [
                                                                      _routinetimeProvider.resettimer(provider
                                                                          .workoutdata
                                                                          .routinedatas[widget
                                                                              .rindex]
                                                                          .exercises[
                                                                              pindex]
                                                                          .rest),
                                                                      _workoutOnermCheck(
                                                                          sets[
                                                                              index],
                                                                          ueindex),
                                                                      index ==
                                                                              sets.length - 1
                                                                          ? [
                                                                              _workoutProvider.setsplus(widget.rindex, pindex, sets.last),
                                                                              _isSetChanged = true,
                                                                              print("jjjjjjjjjjjjjj"),
                                                                              weightController[pindex].controllerlist.add(TextEditingController(text: provider2.userdata.bodyStats.last.weight.toString())),
                                                                              repsController[pindex].controllerlist.add(TextEditingController(text: null)),
                                                                              showToast("세트를 추가했어요 필요없으면 다음으로 넘어가보세요"),
                                                                            ]
                                                                          : null,
                                                                    ]
                                                                  : null,
                                                              _editWorkoutwCheck()
                                                            ]
                                                          : _showMyDialog(
                                                              pindex,
                                                              index,
                                                              newvalue,
                                                            );
                                                    }),
                                              )),
                                        ),
                                        Expanded(
                                          child: Slidable(
                                            startActionPane: ActionPane(
                                                extentRatio: 1.0,
                                                motion: CustomMotion(
                                                  onOpen: () {
                                                    _routinetimeProvider
                                                            .isstarted
                                                        ? [
                                                            _workoutProvider
                                                                .boolcheck(
                                                                    widget
                                                                        .rindex,
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
                                                            _workoutOnermCheck(
                                                                sets[index],
                                                                ueindex),
                                                            index ==
                                                                    sets.length -
                                                                        1
                                                                ? [
                                                                    _workoutProvider.setsplus(
                                                                        widget
                                                                            .rindex,
                                                                        pindex,
                                                                        sets.last),
                                                                    _isSetChanged =
                                                                        true,
                                                                    showToast(
                                                                        "세트를 추가했어요! 다음으로 넘어갈 수도 있어요")
                                                                  ]
                                                                : null,
                                                            _editWorkoutwCheck()
                                                          ]
                                                        : _showMyDialog(
                                                            pindex,
                                                            index,
                                                            true,
                                                          );
                                                  },
                                                  onClose: () {},
                                                  motionWidget:
                                                      const StretchMotion(),
                                                ),
                                                children: [
                                                  SlidableAction(
                                                    autoClose: true,
                                                    onPressed: (_) {},
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    foregroundColor:
                                                        Theme.of(context)
                                                            .highlightColor,
                                                    icon: Icons.check,
                                                    label: '밀어서 check',
                                                  )
                                                ]),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 40,
                                                  child: Text(
                                                    "${index + 1}",
                                                    textScaleFactor: 1.7,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  child: TextField(
                                                    controller:
                                                        weightController[pindex]
                                                                .controllerlist[
                                                            index],
                                                    keyboardType:
                                                        const TextInputType
                                                                .numberWithOptions(
                                                            signed: false,
                                                            decimal: true),
                                                    style: TextStyle(
                                                      fontSize: _themeProvider
                                                              .userFontSize *
                                                          21 /
                                                          0.8,
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText:
                                                          "${sets[index].weight}",
                                                      hintStyle: TextStyle(
                                                        fontSize: _themeProvider
                                                                .userFontSize *
                                                            21 /
                                                            0.8,
                                                        color: Theme.of(context)
                                                            .primaryColorLight,
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
                                                      _workoutProvider
                                                          .weightcheck(
                                                              widget.rindex,
                                                              pindex,
                                                              index,
                                                              changeweight);
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 110,
                                                    child: Center(
                                                      child: InkWell(
                                                        onTap: () {
                                                          showCupertinoModalPopup<
                                                                  void>(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return _buildContainer(
                                                                    timerPicker(
                                                                        time,
                                                                        pindex,
                                                                        index));
                                                              });
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 8,
                                                                      bottom:
                                                                          8),
                                                              child: Text(
                                                                "${time.inHours.toString().length == 1 ? "0" + time.inHours.toString() : time.inHours}:${time.inMinutes.remainder(60).toString().length == 1 ? "0" + time.inMinutes.remainder(60).toString() : time.inMinutes.remainder(60)}:${time.inSeconds.remainder(60).toString().length == 1 ? "0" + time.inSeconds.remainder(60).toString() : time.inSeconds.remainder(60)}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      _themeProvider
                                                                              .userFontSize *
                                                                          21 /
                                                                          0.8,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorLight,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
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
                                    (BuildContext context, int index) {
                                  return Container(
                                    alignment: Alignment.center,
                                    height: 0.5,
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      height: 0.5,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  );
                                },
                                itemCount: sets.length),
                            SizedBox(
                              height: 50,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _workoutProvider.setsminus(
                                            widget.rindex, pindex);
                                        weightController[pindex]
                                            .controllerlist
                                            .removeLast();
                                        repsController[pindex]
                                            .controllerlist
                                            .removeLast();
                                      },
                                      icon: Icon(
                                        Icons.remove,
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        size: 24,
                                      )),
                                  IconButton(
                                      onPressed: () {
                                        _isSetChanged = true;
                                        _workoutProvider.setsplus(
                                            widget.rindex, pindex, sets.last);
                                        weightController[pindex]
                                            .controllerlist
                                            .add(TextEditingController(
                                                text: provider2.userdata
                                                    .bodyStats.last.weight
                                                    .toString()));
                                        repsController[pindex]
                                            .controllerlist
                                            .add(TextEditingController(
                                                text: null));
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        size: 24,
                                      )),
                                ],
                              ),
                            )
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                child: Consumer2<WorkoutdataProvider, RoutineTimeProvider>(
                    builder: (builder, provider, provider2, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 48,
                        width: provider2.nowonrindex == widget.rindex &&
                                _routinetimeProvider.isstarted
                            ? MediaQuery.of(context).size.width / 3 + 8
                            : MediaQuery.of(context).size.width / 2 - 16,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 1,
                              primary:
                                  (provider2.nowonrindex != widget.rindex) &&
                                          _routinetimeProvider.isstarted
                                      ? const Color(0xFF212121)
                                      : provider2.buttoncolor,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          onPressed: () {
                            (provider2.nowonrindex != widget.rindex) &&
                                    _routinetimeProvider.isstarted
                                ? null
                                : [
                                    if (_routinetimeProvider.isstarted)
                                      {_showMyDialog_finish()}
                                    else
                                      {
                                        _routinetimeProvider.resettimer(
                                            _workoutProvider
                                                .workoutdata
                                                .routinedatas[widget.rindex]
                                                .exercises[pindex]
                                                .rest),
                                        provider2.routinecheck(widget.rindex)
                                      }
                                  ];
                          },
                          child: Text(
                              (provider2.nowonrindex != widget.rindex) &&
                                      _routinetimeProvider.isstarted
                                  ? '다른 루틴 수행중'
                                  : provider2.routineButton),
                        ),
                      ),
                      provider2.nowonrindex == widget.rindex &&
                              _routinetimeProvider.isstarted
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width / 4 - 32,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 1,
                                  primary: Theme.of(context).primaryColorDark,
                                ),
                                onPressed: () {
                                  btnDisabled == true
                                      ? null
                                      : [
                                          btnDisabled = true,
                                          Navigator.of(context).pop(),
                                          _editWorkoutCheck()
                                        ];
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "목록",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).indicatorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          : Container(),
                      SizedBox(
                          width: provider2.nowonrindex == widget.rindex &&
                                  _routinetimeProvider.isstarted
                              ? MediaQuery.of(context).size.width / 3 + 8
                              : MediaQuery.of(context).size.width / 2 - 16,
                          height: 48,
                          child: pindex !=
                                  _workoutProvider
                                          .workoutdata
                                          .routinedatas[widget.rindex]
                                          .exercises
                                          .length -
                                      1
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 1,
                                    primary: provider2.nowonrindex ==
                                                widget.rindex &&
                                            provider2.isstarted
                                        ? const Color(0xffceec97)
                                        : Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () {
                                    controller!.nextPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: Text(
                                              "다음 운동",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .shadowColor,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            color:
                                                Theme.of(context).shadowColor,
                                            size: 24,
                                          )
                                        ],
                                      ),
                                      Text(
                                          provider
                                              .workoutdata
                                              .routinedatas[widget.rindex]
                                              .exercises[pindex + 1]
                                              .name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Theme.of(context).shadowColor,
                                          ))
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 1,
                                    primary: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () {
                                    showToast("운동을 종료해주세요");
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "운동 완료",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Theme.of(context).shadowColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ))
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  void exguide(int eindex) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).canvasColor,
            ),
            child: Column(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    color: Theme.of(context).canvasColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Container(
                    height: 6.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0))),
                  ),
                ),
                Expanded(
                  child: ExerciseGuide(
                    eindex: eindex,
                    isroutine: true,
                  ),
                ),
              ],
            ));
      },
    );
  }

  void recordExercise() {
    var exerciseData =
        _workoutProvider.workoutdata.routinedatas[widget.rindex].exercises;
    for (int n = 0; n < exerciseData.length; n++) {
      var recordedSets =
          exerciseData[n].sets.where((sets) => sets.ischecked as bool).toList();
      double maxOnerm = 0;
      for (int i = 0; i < recordedSets.length; i++) {
        final set = recordedSets[i];
        final oneRM =
            (set.reps != 1) ? (set.weight * (1 + set.reps / 30)) : set.weight;
        if (oneRM > maxOnerm) {
          maxOnerm = oneRM;
        }
      }
      final exerciseIndex = _exercises
          .indexWhere((element) => element.name == exerciseData[n].name);
      final exercise = _exercises[exerciseIndex];
      if (recordedSets.isNotEmpty) {
        final isCardio = (exercise.category == "유산소");
        final date = DateTime.now().toString().substring(0, 10);
        exerciseList.add(hisdata.Exercises(
            name: exerciseData[n].name,
            sets: recordedSets,
            onerm: maxOnerm,
            goal: exercise.goal,
            date: date,
            isCardio: isCardio));
      }

      if (maxOnerm > exercise.onerm) {
        modifyExercise(maxOnerm, exerciseData[n].name);
      }
    }
    _postExerciseCheck();
  }

  void _editHistoryCheck() async {
    if (exerciseList.isNotEmpty) {
      final historyPost = HistoryPost(
          user_email: _userProvider.userdata.email,
          exercises: exerciseList,
          new_record: _routinetimeProvider.routineNewRecord,
          workout_time: _routinetimeProvider.routineTime,
          nickname: _userProvider.userdata.nickname);

      final data = await historyPost.postHistory();

      if (data["user_email"] != null) {
        _hisProvider.getdata();
        _hisProvider.getHistorydataAll();
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.push(
            context,
            Transition(
                child: ExerciseDone(
                    exerciseList: exerciseList,
                    routinetime: _routinetimeProvider.routineTime,
                    sdbdata: hisdata.SDBdata.fromJson(data)),
                transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
        _editWorkoutwoCheck();
        _routinetimeProvider.routinecheck(widget.rindex);
        _prefsProvider.lastplan(
            _workoutProvider.workoutdata.routinedatas[widget.rindex].name);
        _hisProvider.getdata();
        _hisProvider.getHistorydataAll();
        exerciseList = [];
      } else {
        showToast("입력을 확인해주세요");
      }
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
            ? showToast("수정 완료")
            : showToast("입력을 확인해주세요"));
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercises = _exProvider.exercisesdata.exercises;
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _prefsProvider = Provider.of<PrefsProvider>(context, listen: false);

    return Scaffold(
      appBar: _appbarWidget(),
      body: _exercisedetailPage(),
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
