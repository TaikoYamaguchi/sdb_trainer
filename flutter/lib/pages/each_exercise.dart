import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sdb_trainer/pages/exercise_done.dart';
import 'package:sdb_trainer/pages/exercise_guide.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:sdb_trainer/src/utils/hhmmss.dart';
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
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:confetti/confetti.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
  var _userProvider;
  var _hisProvider;
  var _exProvider;
  var _themeProvider;
  var _workoutProvider;
  var _routinetimeProvider;
  var _routinemenuProvider;
  var _prefsProvider;
  var _exercise;
  var _bodyStater;
  var _exercises;
  var _chartIndex;
  var _staticPageState;
  var _currentExindex;
  List exControllerlist = [];
  List<CountDownController> _countcontroller = [];
  final Map<int, Widget> _menuList = const <int, Widget>{
    0: Padding(
      child: Text("중량 추가",
          textScaleFactor: 1.3, style: TextStyle(color: Colors.white)),
      padding: const EdgeInsets.all(5.0),
    ),
    1: Padding(
        child: Text("중량 제거",
            textScaleFactor: 1.3, style: TextStyle(color: Colors.white)),
        padding: const EdgeInsets.all(5.0)),
  };
  JustTheController tooltipController = new JustTheController();
  bool _isSetChanged = false;
  double top = 0;
  double bottom = 0;
  double? weight;
  int? reps;
  TextEditingController _resttimectrl = TextEditingController(text: "");
  TextEditingController _additionalweightctrl = TextEditingController(text: "");
  TextEditingController _txtTimeController = TextEditingController();
  List<Controllerlist> weightController = [];
  List<Controllerlist> repsController = [];
  PageController? controller;
  var btnDisabled;
  final ScrollController _controller = ScrollController();

  var runtime = 0;
  Timer? timer1;

  late List<hisdata.Exercises> exerciseList = [];

  @override
  void initState() {
    super.initState();
  }

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
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(Icons.equalizer, size: 32),
              ),
              onTap: () {
                _chartIndex.change(
                    _exProvider.exercisesdata.exercises.indexWhere((exercise) {
                  if (exercise.name ==
                      _workoutProvider.workoutdata.routinedatas[widget.rindex]
                          .exercises[_currentExindex].name) {
                    return true;
                  } else {
                    return false;
                  }
                }));
                _chartIndex.changePageController(0);
                _staticPageState.change(true);
                _bodyStater.change(3);
              },
            )
          ],
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  void _editWorkoutCheck() async {
    if (_routinetimeProvider.isstarted) {
      WorkoutEdit(
              id: _workoutProvider.workoutdata.id,
              user_email: _userProvider.userdata.email,
              routinedatas: _workoutProvider.workoutdata.routinedatas)
          .editWorkout()
          .then((data) =>
              data["user_email"] != null ? null : showToast("입력을 확인해주세요"));
    } else {
      var routinedatas_all = _workoutProvider.workoutdata.routinedatas;
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
              id: _workoutProvider.workoutdata.id,
              user_email: _userProvider.userdata.email,
              routinedatas: routinedatas_all)
          .editWorkout()
          .then((data) =>
              data["user_email"] != null ? null : showToast("입력을 확인해주세요"));
    }
  }

  void _editWorkoutwCheck() async {
    WorkoutEdit(
            id: _workoutProvider.workoutdata.id,
            user_email: _userProvider.userdata.email,
            routinedatas: _workoutProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) =>
            data["user_email"] != null ? null : showToast("입력을 확인해주세요"));
  }

  void _editWorkoutwoCheck() async {
    var routinedatas_all = _workoutProvider.workoutdata.routinedatas;
    for (int n = 0; n < routinedatas_all[widget.rindex].exercises.length; n++) {
      for (int i = 0;
          i < routinedatas_all[widget.rindex].exercises[n].sets.length;
          i++) {
        routinedatas_all[widget.rindex].exercises[n].sets[i].ischecked = false;
      }
    }
    WorkoutEdit(
            id: _workoutProvider.workoutdata.id,
            user_email: _userProvider.userdata.email,
            routinedatas: routinedatas_all)
        .editWorkout()
        .then((data) =>
            data["user_email"] != null ? null : showToast("입력을 확인해주세요"));
  }

  Widget _exercisedetailPage() {
    controller = PageController(initialPage: widget.eindex);
    if (_routinetimeProvider.nowonrindex == widget.rindex) {
      _routinetimeProvider.nowoneindexupdate(widget.eindex);
    }
    int numEx = _workoutProvider
        .workoutdata.routinedatas[widget.rindex].exercises.length;
    var _routine = _workoutProvider.workoutdata.routinedatas[widget.rindex];
    for (int i = 0; i < numEx; i++) {
      weightController.add(new Controllerlist());
      repsController.add(new Controllerlist());
      for (int s = 0; s < _routine.exercises[i].sets.length; s++) {
        weightController[i].controllerlist.add(new TextEditingController(
            text: _routine.exercises[i].sets[s].weight == 0
                ? null
                : (_routine.exercises[i].sets[s].weight % 1) == 0
                    ? _routine.exercises[i].sets[s].weight.toStringAsFixed(0)
                    : _routine.exercises[i].sets[s].weight.toStringAsFixed(1)));
        repsController[i].controllerlist.add(new TextEditingController(
            text: _routine.exercises[i].sets[s].reps == 1
                ? null
                : _routine.exercises[i].sets[s].reps.toStringAsFixed(0)));
      }
    }
    bool btnDisabled = false;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onPanUpdate: (details) {
          if (details.delta.dx > 0 && btnDisabled == false) {
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
            return _exProvider
                        .exercisesdata
                        .exercises[_exProvider.exercisesdata.exercises
                            .indexWhere((element) =>
                                element.name ==
                                _workoutProvider
                                    .workoutdata
                                    .routinedatas[widget.rindex]
                                    .exercises[pindex]
                                    .name)]
                        .category ==
                    '맨몸'
                ? _bodyexercisedetailWidget(pindex)
                : _exProvider
                            .exercisesdata
                            .exercises[_exProvider.exercisesdata.exercises
                                .indexWhere((element) =>
                                    element.name ==
                                    _workoutProvider
                                        .workoutdata
                                        .routinedatas[widget.rindex]
                                        .exercises[pindex]
                                        .name)]
                            .category ==
                        '유산소'
                    ? _cardioexercisedetailWidget(pindex)
                    : _exercisedetailWidget(pindex);
          },
          itemCount: numEx,
        ));
  }

  Widget _exercisedetailWidget(pindex) {
    int ueindex = _exProvider.exercisesdata.exercises.indexWhere((element) =>
        element.name ==
        _workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[pindex].name);
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
      };
      if (states.any(interactiveStates.contains)) {
        return Theme.of(context).primaryColor;
      }
      return Colors.white;
    }

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        color: Color(0xFF101012),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            isKeyboardVisible
                ? Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            'Timer: ',
                            textScaleFactor: 1.7,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(child: Consumer<RoutineTimeProvider>(
                            builder: (context, provider, child) {
                          return Text(
                              provider.userest
                                  ? provider.timeron < 0
                                      ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                      : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                  : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                              textScaleFactor: 1.7,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (provider.userest && provider.timeron < 0)
                                          ? Colors.red
                                          : Colors.white));
                        })),
                      ],
                    ),
                  )
                : Container(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                child: Text(
                                  '  Timer: ',
                                  textScaleFactor: 1.7,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(child: Consumer<RoutineTimeProvider>(
                                  builder: (context, provider, child) {
                                return Text(
                                    provider.userest
                                        ? provider.timeron < 0
                                            ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                            : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                        : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                    textScaleFactor: 1.7,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (provider.userest &&
                                                provider.timeron < 0)
                                            ? Colors.red
                                            : Colors.white));
                              })),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              _routinetimeProvider.restcheck();
                              _routinetimeProvider.resttimecheck(
                                  _workoutProvider
                                      .workoutdata
                                      .routinedatas[widget.rindex]
                                      .exercises[pindex]
                                      .rest);
                            },
                            child: Consumer<RoutineTimeProvider>(
                                builder: (builder, provider, child) {
                              return Text(
                                provider.userest
                                    ? 'Rest Timer on'
                                    : 'Rest Timer off',
                                textScaleFactor: 1.7,
                                style: TextStyle(
                                  color: provider.userest
                                      ? Colors.white
                                      : Color(0xFF717171),
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                          ),
                        ],
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
                            textScaleFactor: 1.7,
                            style: TextStyle(
                              color: Color(0xFF717171),
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
                    GestureDetector(
                      onTap: () {
                        exguide(widget.ueindex);
                      },
                      child: Consumer<WorkoutdataProvider>(
                          builder: (builder, provider, child) {
                        var _exercise = provider.workoutdata
                            .routinedatas[widget.rindex].exercises[pindex];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _exercise.name.length < 10
                                ? Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFF101012),
                                  )
                                : Container(),
                            isKeyboardVisible
                                ? Text(
                                    _exercise.name,
                                    textScaleFactor: 2.0,
                                    style: TextStyle(color: Colors.white),
                                  )
                                : _exercise.name.length < 8
                                    ? Text(
                                        _exercise.name,
                                        textScaleFactor: 3.2,
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Flexible(
                                        child: Text(
                                          _exercise.name,
                                          textScaleFactor: 2.4,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
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
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                    Consumer<ExercisesdataProvider>(
                        builder: (builder, provider, child) {
                      var _info = provider.exercisesdata.exercises[ueindex];
                      return isKeyboardVisible
                          ? Container()
                          : GestureDetector(
                              onTap: () {
                                _displayExEditDialog();
                              },
                              child: Text(
                                "Best 1RM: ${_info.onerm.toStringAsFixed(1)}/${_info.goal.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                                textScaleFactor: 1.7,
                                style: TextStyle(color: Color(0xFF717171)),
                              ),
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
                          textScaleFactor: 1.1,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        )),
                    Container(
                        width: 70,
                        child: Text(
                          "Weight(${_userProvider.userdata.weight_unit})",
                          textScaleFactor: 1.1,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
                    Container(width: 35),
                    Container(
                        width: 40,
                        child: Text(
                          "Reps",
                          textScaleFactor: 1.1,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
                    Container(
                        width: 70,
                        child: Text(
                          "1RM",
                          textScaleFactor: 1.1,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ],
                )),
            Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
              var _sets = provider.workoutdata.routinedatas[widget.rindex]
                  .exercises[pindex].sets;
              if (_isSetChanged == true) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  _controller.animateTo(
                    _controller.position.maxScrollExtent,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );

                  print(_controller);
                });
                _isSetChanged = false;
              } else {
                null;
              }

              return Expanded(
                child: Column(
                  children: [
                    Flexible(
                      child: ListView.separated(
                          shrinkWrap: true,
                          controller: _controller,
                          itemBuilder: (BuildContext _context, int index) {
                            return Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    child: Transform.scale(
                                        scale: 1.2,
                                        child: Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                                  Colors.white),
                                          child: Checkbox(
                                              checkColor: Colors.white,
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              value: _sets[index].ischecked,
                                              onChanged: (newvalue) {
                                                _routinetimeProvider.isstarted
                                                    ? [
                                                        _workoutProvider
                                                            .boolcheck(
                                                                widget.rindex,
                                                                pindex,
                                                                index,
                                                                newvalue),
                                                        newvalue == true
                                                            ? [
                                                                _routinetimeProvider.resettimer(provider
                                                                    .workoutdata
                                                                    .routinedatas[
                                                                        widget
                                                                            .rindex]
                                                                    .exercises[
                                                                        pindex]
                                                                    .rest),
                                                                _workoutOnermCheck(
                                                                    _sets[
                                                                        index],
                                                                    ueindex),
                                                                index ==
                                                                        _sets.length -
                                                                            1
                                                                    ? [
                                                                        _workoutProvider.setsplus(
                                                                            widget.rindex,
                                                                            pindex),
                                                                        _isSetChanged =
                                                                            true,
                                                                        print(
                                                                            "jjjjjjjjjjjjjj"),
                                                                        weightController[pindex]
                                                                            .controllerlist
                                                                            .add(new TextEditingController(text: null)),
                                                                        repsController[pindex]
                                                                            .controllerlist
                                                                            .add(new TextEditingController(text: null)),
                                                                        showToast(
                                                                            "세트를 추가했어요 필요없으면 다음으로 넘어가보세요"),
                                                                      ]
                                                                    : null,
                                                              ]
                                                            : null,
                                                        _editWorkoutwCheck()
                                                      ]
                                                    : _showMyDialog(pindex,
                                                        index, newvalue);
                                              }),
                                        )),
                                  ),
                                  Expanded(
                                    child: Slidable(
                                      startActionPane: ActionPane(
                                          extentRatio: 1.0,
                                          motion: CustomMotion(
                                            onOpen: () {
                                              _routinetimeProvider.isstarted
                                                  ? [
                                                      _workoutProvider
                                                          .boolcheck(
                                                              widget.rindex,
                                                              pindex,
                                                              index,
                                                              true),
                                                      _routinetimeProvider
                                                          .resettimer(provider
                                                              .workoutdata
                                                              .routinedatas[
                                                                  widget.rindex]
                                                              .exercises[pindex]
                                                              .rest),
                                                      _workoutOnermCheck(
                                                          _sets[index],
                                                          ueindex),
                                                      index == _sets.length - 1
                                                          ? [
                                                              _workoutProvider
                                                                  .setsplus(
                                                                      widget
                                                                          .rindex,
                                                                      pindex),
                                                              _isSetChanged =
                                                                  true,
                                                              weightController[
                                                                      pindex]
                                                                  .controllerlist
                                                                  .add(new TextEditingController(
                                                                      text:
                                                                          null)),
                                                              repsController[
                                                                      pindex]
                                                                  .controllerlist
                                                                  .add(new TextEditingController(
                                                                      text:
                                                                          null)),
                                                              showToast(
                                                                  "세트를 추가했어요! 다음으로 넘어갈 수도 있어요")
                                                            ]
                                                          : null,
                                                      _editWorkoutwCheck()
                                                    ]
                                                  : _showMyDialog(
                                                      pindex, index, true);
                                            },
                                            onClose: () {},
                                            motionWidget: StretchMotion(),
                                          ),
                                          children: [
                                            SlidableAction(
                                              autoClose: true,
                                              onPressed: (_) {},
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
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
                                              textScaleFactor: 1.7,
                                              style: TextStyle(
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
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: false,
                                                      decimal: true),
                                              style: TextStyle(
                                                fontSize: _themeProvider
                                                        .userFontSize *
                                                    21 /
                                                    0.8,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText:
                                                    "${_sets[index].weight}",
                                                hintStyle: TextStyle(
                                                  fontSize: _themeProvider
                                                          .userFontSize *
                                                      21 /
                                                      0.8,
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
                                                _workoutProvider.weightcheck(
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
                                                  height: 19 *
                                                      _themeProvider
                                                          .userFontSize /
                                                      0.8)),
                                          Container(
                                            width: 40,
                                            child: TextField(
                                              controller: repsController[pindex]
                                                  .controllerlist[index],
                                              keyboardType:
                                                  TextInputType.number,
                                              style: TextStyle(
                                                fontSize: _themeProvider
                                                        .userFontSize *
                                                    21 /
                                                    0.8,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText:
                                                    "${_sets[index].reps}",
                                                hintStyle: TextStyle(
                                                  fontSize: 21 *
                                                      _themeProvider
                                                          .userFontSize /
                                                      0.8,
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
                                                _workoutProvider.repscheck(
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
                                                      textScaleFactor: 1.7,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  : Text(
                                                      "${_sets[index].weight}",
                                                      textScaleFactor: 1.7,
                                                      style: TextStyle(
                                                          color: Colors.white),
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
                          itemCount: _sets.length),
                    ),
                    Container(
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
                              icon: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 24,
                              )),
                          IconButton(
                              onPressed: () {
                                _isSetChanged = true;
                                _workoutProvider.setsplus(
                                    widget.rindex, pindex);
                                weightController[pindex]
                                    .controllerlist
                                    .add(new TextEditingController(text: null));
                                repsController[pindex]
                                    .controllerlist
                                    .add(new TextEditingController(text: null));
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
                                              size: 30,
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                                primary:
                                    (provider.nowonrindex != widget.rindex) &&
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
                                        {_showMyDialog_finish()}
                                      else
                                        {
                                          _routinetimeProvider.resettimer(
                                              _workoutProvider
                                                  .workoutdata
                                                  .routinedatas[widget.rindex]
                                                  .exercises[pindex]
                                                  .rest),
                                          provider.routinecheck(widget.rindex)
                                        }
                                    ];
                            },
                            child: Text(
                                (provider.nowonrindex != widget.rindex) &&
                                        _routinetimeProvider.isstarted
                                    ? '다른 루틴 수행중'
                                    : provider.routineButton),
                          );
                        })),
                        Container(
                            child: pindex !=
                                    _workoutProvider
                                            .workoutdata
                                            .routinedatas[widget.rindex]
                                            .exercises
                                            .length -
                                        1
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                              Icons.arrow_forward_ios_outlined,
                                              color: Colors.white,
                                              size: 30,
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
      );
    });
  }

  _showMyDialog(pindex, index, newvalue) async {
    var _sets = _workoutProvider
        .workoutdata.routinedatas[widget.rindex].exercises[pindex].sets;
    int ueindex = _exProvider.exercisesdata.exercises.indexWhere((element) =>
        element.name ==
        _workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[pindex].name);

    var result = await showDialog(
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
      _workoutOnermCheck(_sets[index], ueindex);
      _exProvider
                  .exercisesdata
                  .exercises[_exProvider.exercisesdata.exercises.indexWhere(
                      (element) =>
                          element.name ==
                          _workoutProvider
                              .workoutdata
                              .routinedatas[widget.rindex]
                              .exercises[pindex]
                              .name)]
                  .category ==
              '유산소'
          ? _countcontroller[index].start()
          : null;
    }
  }

  _showMyDialog_finish() async {
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
      _editWorkoutwoCheck();
    }
  }

  void _displayExEditDialog() {
    var index = _exProvider.exercisesdata.exercises
        .indexWhere((element) => element.name == _exercise.name);
    var _exOnermController = TextEditingController(
        text: _exProvider.exercisesdata.exercises[index].onerm
            .toStringAsFixed(1));
    var _exGoalController = TextEditingController(
        text:
            _exProvider.exercisesdata.exercises[index].goal.toStringAsFixed(1));
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
              '목표를 달성하셨나요?',
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("더 높은 목표를 설정해보세요!",
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 20),
                TextField(
                  controller: _exOnermController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                    fontSize: 21 * _themeProvider.userFontSize / 0.8,
                    color: Colors.white,
                  ),
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
                      labelText: "1RM (" +
                          _exProvider.exercisesdata.exercises[index].name +
                          ")",
                      labelStyle: TextStyle(
                          fontSize: 16.0 * _themeProvider.userFontSize / 0.8,
                          color: Colors.grey),
                      hintText: "1RM",
                      hintStyle: TextStyle(
                          fontSize: 24.0 * _themeProvider.userFontSize / 0.8,
                          color: Colors.white)),
                  onChanged: (text) {},
                ),
                TextField(
                  controller: _exGoalController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                    fontSize: 21 * _themeProvider.userFontSize / 0.8,
                    color: Colors.white,
                  ),
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
                      labelText: "목표 (" +
                          _exProvider.exercisesdata.exercises[index].name +
                          ")",
                      labelStyle: TextStyle(
                          fontSize: 16.0 * _themeProvider.userFontSize / 0.8,
                          color: Colors.grey),
                      hintText: "목표",
                      hintStyle: TextStyle(
                          fontSize: 24.0 * _themeProvider.userFontSize / 0.8,
                          color: Colors.white)),
                  onChanged: (text) {},
                ),
              ],
            ),
            actions: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    foregroundColor: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                    padding: EdgeInsets.all(12.0),
                  ),
                  child: Text('수정하기',
                      textScaleFactor: 1.7,
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _exProvider.putOnermGoalValue(
                        index,
                        double.parse(_exOnermController.text),
                        double.parse(_exGoalController.text));
                    _postExerciseCheck();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ),
            ],
          );
        });
  }

  void _workoutOnermCheck(Sets _sets, ueindex) {
    var _onerm;
    var _exercise = _exProvider.exercisesdata.exercises[ueindex];
    print("onerm");
    if (_sets.reps != 1) {
      _onerm = (_sets.weight * (1 + _sets.reps / 30));
    } else if (_sets.reps == 1) {
      _onerm = _sets.weight;
    } else {
      _onerm = 0;
    }
    if (_onerm > _exercise.onerm) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            _exProvider.putOnermValue(
                _exProvider.exercisesdata.exercises
                    .indexWhere((element) => element.name == _exercise.name),
                _onerm);
            return newOnermAlerts(
                onerm: _onerm, sets: _sets, exercise: _exercise);
          });
      _routinetimeProvider.newRoutineUpdate();
      print("display");
      print(_onerm);
      print(_exercise.onerm);
    } else {
      print("nodisplay");
      print(_onerm);
      print(_exercise.onerm);
    }
  }

  Widget _bodyexercisedetailWidget(pindex) {
    int ueindex = _exProvider.exercisesdata.exercises.indexWhere((element) =>
        element.name ==
        _workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[pindex].name);
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
      };
      if (states.any(interactiveStates.contains)) {
        return Theme.of(context).primaryColor;
      }
      return Colors.white;
    }

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
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
              isKeyboardVisible
                  ? Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              'Timer: ',
                              textScaleFactor: 1.7,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(child: Consumer<RoutineTimeProvider>(
                              builder: (context, provider, child) {
                            return Text(
                                provider.userest
                                    ? provider.timeron < 0
                                        ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                        : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                    : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                textScaleFactor: 1.7,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (provider.userest &&
                                            provider.timeron < 0)
                                        ? Colors.red
                                        : Colors.white));
                          })),
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: Text(
                                    '  Timer: ',
                                    textScaleFactor: 1.7,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(child: Consumer<RoutineTimeProvider>(
                                    builder: (context, provider, child) {
                                  return Text(
                                      provider.userest
                                          ? provider.timeron < 0
                                              ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                              : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                          : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                      textScaleFactor: 1.7,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: (provider.userest &&
                                                  provider.timeron < 0)
                                              ? Colors.red
                                              : Colors.white));
                                })),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                _routinetimeProvider.restcheck();
                                _routinetimeProvider.resttimecheck(
                                    _workoutProvider
                                        .workoutdata
                                        .routinedatas[widget.rindex]
                                        .exercises[pindex]
                                        .rest);
                              },
                              child: Consumer<RoutineTimeProvider>(
                                  builder: (builder, provider, child) {
                                return Text(
                                  provider.userest
                                      ? 'Rest Timer on'
                                      : 'Rest Timer off',
                                  textScaleFactor: 1.7,
                                  style: TextStyle(
                                    color: provider.userest
                                        ? Colors.white
                                        : Color(0xFF717171),
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                            ),
                          ],
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
                              textScaleFactor: 1.7,
                              style: TextStyle(
                                color: Color(0xFF717171),
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
                      GestureDetector(
                        onTap: () {
                          exguide(widget.ueindex);
                        },
                        child: Consumer<WorkoutdataProvider>(
                            builder: (builder, provider, child) {
                          var _exercise = provider.workoutdata
                              .routinedatas[widget.rindex].exercises[pindex];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _exercise.name.length < 10
                                  ? Icon(
                                      Icons.info_outline_rounded,
                                      color: Color(0xFF101012),
                                    )
                                  : Container(),
                              isKeyboardVisible
                                  ? Text(
                                      _exercise.name,
                                      textScaleFactor: 2.0,
                                      style: TextStyle(color: Colors.white),
                                    )
                                  : _exercise.name.length < 8
                                      ? Text(
                                          _exercise.name,
                                          textScaleFactor: 3.2,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                      : Flexible(
                                          child: Text(
                                            _exercise.name,
                                            textScaleFactor: 2.4,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
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
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),
                      Consumer<ExercisesdataProvider>(
                          builder: (builder, provider, child) {
                        var _info = provider.exercisesdata.exercises[ueindex];
                        return isKeyboardVisible
                            ? Container()
                            : Text(
                                "Best 1RM: ${_info.onerm.toStringAsFixed(1)}/${_info.goal.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                                textScaleFactor: 1.7,
                                style: TextStyle(color: Color(0xFF717171)),
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
                            textScaleFactor: 1.1,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          )),
                      Container(
                          width: 70,
                          child: Row(
                            children: [
                              Text(
                                "Weight",
                                textScaleFactor: 1.1,
                                style: TextStyle(
                                  color: Colors.white,
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
                                  child: Padding(
                                    padding: EdgeInsets.zero,
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  content: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      '맨몸 카테고리의 운동은 기본 무게가 체중으로 세팅되고,\n무게를 누르면 체중에 추가/제거가 가능해요.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Container(width: 35),
                      Container(
                          width: 40,
                          child: Text(
                            "Reps",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                      Container(
                          width: 70,
                          child: Text(
                            "1RM",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ],
                  )),
              Consumer2<WorkoutdataProvider, UserdataProvider>(
                  builder: (builder, provider, provider2, child) {
                var _sets = provider.workoutdata.routinedatas[widget.rindex]
                    .exercises[pindex].sets;
                if (_isSetChanged == true) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    _controller.animateTo(
                      _controller.position.maxScrollExtent,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );

                    print(_controller);
                  });
                  _isSetChanged = false;
                } else {
                  null;
                }

                return Expanded(
                  child: Column(
                    children: [
                      Flexible(
                        child: ListView.separated(
                            shrinkWrap: true,
                            controller: _controller,
                            itemBuilder: (BuildContext _context, int index) {
                              weightController[pindex]
                                      .controllerlist[index]
                                      .text =
                                  provider2.userdata.bodyStats.last.weight
                                      .toString();
                              provider.workoutdata.routinedatas[widget.rindex]
                                      .exercises[pindex].sets[index].index =
                                  provider2.userdata.bodyStats.last.weight;
                              return Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 60,
                                      child: Transform.scale(
                                          scale: 1.2,
                                          child: Theme(
                                            data: ThemeData(
                                                unselectedWidgetColor:
                                                    Colors.white),
                                            child: Checkbox(
                                                checkColor: Colors.white,
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                value: _sets[index].ischecked,
                                                onChanged: (newvalue) {
                                                  _routinetimeProvider.isstarted
                                                      ? [
                                                          _workoutProvider
                                                              .boolcheck(
                                                                  widget.rindex,
                                                                  pindex,
                                                                  index,
                                                                  newvalue),
                                                          newvalue == true
                                                              ? [
                                                                  _routinetimeProvider.resettimer(provider
                                                                      .workoutdata
                                                                      .routinedatas[
                                                                          widget
                                                                              .rindex]
                                                                      .exercises[
                                                                          pindex]
                                                                      .rest),
                                                                  _workoutOnermCheck(
                                                                      _sets[
                                                                          index],
                                                                      ueindex),
                                                                  index ==
                                                                          _sets.length -
                                                                              1
                                                                      ? [
                                                                          _workoutProvider.setsplus(
                                                                              widget.rindex,
                                                                              pindex),
                                                                          _isSetChanged =
                                                                              true,
                                                                          print(
                                                                              "jjjjjjjjjjjjjj"),
                                                                          weightController[pindex]
                                                                              .controllerlist
                                                                              .add(new TextEditingController(text: provider2.userdata.bodyStats.last.weight.toString())),
                                                                          repsController[pindex]
                                                                              .controllerlist
                                                                              .add(new TextEditingController(text: null)),
                                                                          showToast(
                                                                              "세트를 추가했어요 필요없으면 다음으로 넘어가보세요"),
                                                                        ]
                                                                      : null,
                                                                ]
                                                              : null,
                                                          _editWorkoutwCheck()
                                                        ]
                                                      : _showMyDialog(pindex,
                                                          index, newvalue);
                                                }),
                                          )),
                                    ),
                                    Expanded(
                                      child: Slidable(
                                        startActionPane: ActionPane(
                                            extentRatio: 1.0,
                                            motion: CustomMotion(
                                              onOpen: () {
                                                _routinetimeProvider.isstarted
                                                    ? [
                                                        _workoutProvider
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
                                                        _workoutOnermCheck(
                                                            _sets[index],
                                                            ueindex),
                                                        index ==
                                                                _sets.length - 1
                                                            ? [
                                                                _workoutProvider
                                                                    .setsplus(
                                                                        widget
                                                                            .rindex,
                                                                        pindex),
                                                                _isSetChanged =
                                                                    true,
                                                                weightController[
                                                                        pindex]
                                                                    .controllerlist
                                                                    .add(new TextEditingController(
                                                                        text: provider2
                                                                            .userdata
                                                                            .bodyStats
                                                                            .last
                                                                            .weight
                                                                            .toString())),
                                                                repsController[
                                                                        pindex]
                                                                    .controllerlist
                                                                    .add(new TextEditingController(
                                                                        text:
                                                                            null)),
                                                                showToast(
                                                                    "세트를 추가했어요! 다음으로 넘어갈 수도 있어요")
                                                              ]
                                                            : null,
                                                        _editWorkoutwCheck()
                                                      ]
                                                    : _showMyDialog(
                                                        pindex, index, true);
                                              },
                                              onClose: () {},
                                              motionWidget: StretchMotion(),
                                            ),
                                            children: [
                                              SlidableAction(
                                                autoClose: true,
                                                onPressed: (_) {},
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
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
                                                textScaleFactor: 1.7,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Container(
                                                width: 70,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _displaySetWeightAlert(
                                                        pindex, index);
                                                  },
                                                  child: Center(
                                                    child: Text(
                                                        "${_sets[index].index + _sets[index].weight}",
                                                        textScaleFactor: 1.7,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        )),
                                                  ),
                                                )),
                                            Container(
                                                width: 35,
                                                child: SvgPicture.asset(
                                                    "assets/svg/multiply.svg",
                                                    color: Colors.white,
                                                    height: 19 *
                                                        _themeProvider
                                                            .userFontSize /
                                                        0.8)),
                                            Container(
                                              width: 40,
                                              child: TextField(
                                                controller:
                                                    repsController[pindex]
                                                        .controllerlist[index],
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 21 *
                                                      _themeProvider
                                                          .userFontSize /
                                                      0.8,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "${_sets[index].reps}",
                                                  hintStyle: TextStyle(
                                                    fontSize: 21 *
                                                        _themeProvider
                                                            .userFontSize /
                                                        0.8,
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
                                                  _workoutProvider.repscheck(
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
                                                        "${((_sets[index].weight + _sets[index].index) * (1 + _sets[index].reps / 30)).toStringAsFixed(1)}",
                                                        textScaleFactor: 1.7,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    : Text(
                                                        "${_sets[index].weight + _sets[index].index}",
                                                        textScaleFactor: 1.7,
                                                        style: TextStyle(
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
                                color: Color(0xFF101012),
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
                                icon: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 24,
                                )),
                            IconButton(
                                onPressed: () {
                                  _isSetChanged = true;
                                  _workoutProvider.setsplus(
                                      widget.rindex, pindex);
                                  weightController[pindex].controllerlist.add(
                                      new TextEditingController(
                                          text: provider2
                                              .userdata.bodyStats.last.weight
                                              .toString()));
                                  repsController[pindex].controllerlist.add(
                                      new TextEditingController(text: null));
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
                                                size: 30,
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
                                  primary:
                                      (provider.nowonrindex != widget.rindex) &&
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
                                          {_showMyDialog_finish()}
                                        else
                                          {
                                            _routinetimeProvider.resettimer(
                                                _workoutProvider
                                                    .workoutdata
                                                    .routinedatas[widget.rindex]
                                                    .exercises[pindex]
                                                    .rest),
                                            provider.routinecheck(widget.rindex)
                                          }
                                      ];
                              },
                              child: Text(
                                  (provider.nowonrindex != widget.rindex) &&
                                          _routinetimeProvider.isstarted
                                      ? '다른 루틴 수행중'
                                      : provider.routineButton),
                            );
                          })),
                          Container(
                              child: pindex !=
                                      _workoutProvider
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
                                                size: 30,
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

  Widget _cardioexercisedetailWidget(pindex) {
    int ueindex = _exProvider.exercisesdata.exercises.indexWhere((element) =>
        element.name ==
        _workoutProvider
            .workoutdata.routinedatas[widget.rindex].exercises[pindex].name);
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
      };
      if (states.any(interactiveStates.contains)) {
        return Theme.of(context).primaryColor;
      }
      return Colors.white;
    }

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
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
              isKeyboardVisible
                  ? Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              'Timer: ',
                              textScaleFactor: 1.7,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(child: Consumer<RoutineTimeProvider>(
                              builder: (context, provider, child) {
                            return Text(
                                provider.userest
                                    ? provider.timeron < 0
                                        ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                        : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                    : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                textScaleFactor: 1.7,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (provider.userest &&
                                            provider.timeron < 0)
                                        ? Colors.red
                                        : Colors.white));
                          })),
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: Text(
                                    '  Timer: ',
                                    textScaleFactor: 1.7,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(child: Consumer<RoutineTimeProvider>(
                                    builder: (context, provider, child) {
                                  return Text(
                                      provider.userest
                                          ? provider.timeron < 0
                                              ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                              : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                          : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                      textScaleFactor: 1.7,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: (provider.userest &&
                                                  provider.timeron < 0)
                                              ? Colors.red
                                              : Colors.white));
                                })),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                _routinetimeProvider.restcheck();
                                _routinetimeProvider.resttimecheck(
                                    _workoutProvider
                                        .workoutdata
                                        .routinedatas[widget.rindex]
                                        .exercises[pindex]
                                        .rest);
                              },
                              child: Consumer<RoutineTimeProvider>(
                                  builder: (builder, provider, child) {
                                return Text(
                                  provider.userest
                                      ? 'Rest Timer on'
                                      : 'Rest Timer off',
                                  textScaleFactor: 1.7,
                                  style: TextStyle(
                                    color: provider.userest
                                        ? Colors.white
                                        : Color(0xFF717171),
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                            ),
                          ],
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
                              textScaleFactor: 1.7,
                              style: TextStyle(
                                color: Color(0xFF717171),
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
                      GestureDetector(
                        onTap: () {
                          exguide(widget.ueindex);
                        },
                        child: Consumer<WorkoutdataProvider>(
                            builder: (builder, provider, child) {
                          var _exercise = provider.workoutdata
                              .routinedatas[widget.rindex].exercises[pindex];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _exercise.name.length < 10
                                  ? Icon(
                                      Icons.info_outline_rounded,
                                      color: Color(0xFF101012),
                                    )
                                  : Container(),
                              isKeyboardVisible
                                  ? Text(
                                      _exercise.name,
                                      textScaleFactor: 2.0,
                                      style: TextStyle(color: Colors.white),
                                    )
                                  : _exercise.name.length < 8
                                      ? Text(
                                          _exercise.name,
                                          textScaleFactor: 3.2,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                      : Flexible(
                                          child: Text(
                                            _exercise.name,
                                            textScaleFactor: 2.4,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                              Column(
                                children: [
                                  Container(
                                    height: 7,
                                  ),
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),
                      Consumer<ExercisesdataProvider>(
                          builder: (builder, provider, child) {
                        var _info = provider.exercisesdata.exercises[ueindex];
                        return isKeyboardVisible
                            ? Container()
                            : Text(
                                "Best 1RM: ${_info.onerm.toStringAsFixed(1)}/${_info.goal.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                                textScaleFactor: 1.7,
                                style: TextStyle(color: Color(0xFF717171)),
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
                            textScaleFactor: 1.1,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          )),
                      Container(
                        width: 40,
                        padding: EdgeInsets.only(right: 4),
                      ),
                      Container(
                          width: 80,
                          child: Text(
                            "Distance",
                            textScaleFactor: 4.0,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                      Container(
                          width: 140,
                          child: Text(
                            "Duration(hh:mm:ss)",
                            textScaleFactor: 4.0,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ],
                  )),
              Consumer2<WorkoutdataProvider, UserdataProvider>(
                  builder: (builder, provider, provider2, child) {
                var _sets = provider.workoutdata.routinedatas[widget.rindex]
                    .exercises[pindex].sets;
                if (_isSetChanged == true) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    _controller.animateTo(
                      _controller.position.maxScrollExtent,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );

                    print(_controller);
                  });
                  _isSetChanged = false;
                } else {
                  null;
                }

                return Expanded(
                  child: Column(
                    children: [
                      Flexible(
                        child: ListView.separated(
                            shrinkWrap: true,
                            controller: _controller,
                            itemBuilder: (BuildContext _context, int index) {
                              exControllerlist.add(ExpandableController());
                              _countcontroller.add(CountDownController());
                              weightController[pindex]
                                      .controllerlist[index]
                                      .text =
                                  provider2.userdata.bodyStats.last.weight
                                      .toString();
                              provider.workoutdata.routinedatas[widget.rindex]
                                      .exercises[pindex].sets[index].index =
                                  provider2.userdata.bodyStats.last.weight;
                              return Container(
                                padding: EdgeInsets.only(right: 10),
                                child: ExpandablePanel(
                                    controller: exControllerlist[index],
                                    theme: const ExpandableThemeData(
                                      headerAlignment:
                                          ExpandablePanelHeaderAlignment.center,
                                      hasIcon: false,
                                      iconColor: Colors.white,
                                    ),
                                    header: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 60,
                                          child: Transform.scale(
                                              scale: 1.2,
                                              child: Theme(
                                                data: ThemeData(
                                                    unselectedWidgetColor:
                                                        Colors.white),
                                                child: Checkbox(
                                                    checkColor: Colors.white,
                                                    activeColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    value:
                                                        _sets[index].ischecked,
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
                                                                          _sets[
                                                                              index],
                                                                          ueindex),
                                                                      index ==
                                                                              _sets.length - 1
                                                                          ? [
                                                                              _workoutProvider.setsplus(widget.rindex, pindex),
                                                                              _isSetChanged = true,
                                                                              print("jjjjjjjjjjjjjj"),
                                                                              weightController[pindex].controllerlist.add(new TextEditingController(text: provider2.userdata.bodyStats.last.weight.toString())),
                                                                              repsController[pindex].controllerlist.add(new TextEditingController(text: null)),
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
                                                                _sets[index],
                                                                ueindex),
                                                            index ==
                                                                    _sets.length -
                                                                        1
                                                                ? [
                                                                    _workoutProvider.setsplus(
                                                                        widget
                                                                            .rindex,
                                                                        pindex),
                                                                    _isSetChanged =
                                                                        true,
                                                                    weightController[pindex].controllerlist.add(new TextEditingController(
                                                                        text: provider2
                                                                            .userdata
                                                                            .bodyStats
                                                                            .last
                                                                            .weight
                                                                            .toString())),
                                                                    repsController[
                                                                            pindex]
                                                                        .controllerlist
                                                                        .add(new TextEditingController(
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
                                                  motionWidget: StretchMotion(),
                                                ),
                                                children: [
                                                  SlidableAction(
                                                    autoClose: true,
                                                    onPressed: (_) {},
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    foregroundColor:
                                                        Colors.white,
                                                    icon: Icons.check,
                                                    label: '밀어서 check',
                                                  )
                                                ]),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: 25,
                                                  child: Text(
                                                    "${index + 1}",
                                                    textScaleFactor: 1.7,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Container(
                                                    width: 40,
                                                    child: Center(
                                                      child: IconButton(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 2, 0, 0),
                                                        iconSize: 30,
                                                        onPressed: () {
                                                          int _duration = (((_sets[index].reps /
                                                                              10000)
                                                                          .floor() *
                                                                      3600) +
                                                                  ((_sets[index].reps - (_sets[index].reps / 10000).floor() * 10000) /
                                                                              100)
                                                                          .floor() *
                                                                      60 +
                                                                  (_sets[index]
                                                                          .reps -
                                                                      (_sets[index].reps / 100)
                                                                              .floor() *
                                                                          100))
                                                              .toInt();
                                                          for (int s = 0;
                                                              s < _sets.length;
                                                              s++) {
                                                            exControllerlist[s]
                                                                .value = false;
                                                          }
                                                          ;
                                                          exControllerlist[
                                                                  index]
                                                              .value = true;
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
                                                                  _routinetimeProvider.resettimer(provider
                                                                      .workoutdata
                                                                      .routinedatas[
                                                                          widget
                                                                              .rindex]
                                                                      .exercises[
                                                                          pindex]
                                                                      .rest),
                                                                  _countcontroller[
                                                                          index]
                                                                      .restart(
                                                                          duration:
                                                                              _duration),
                                                                  _workoutOnermCheck(
                                                                      _sets[
                                                                          index],
                                                                      ueindex),
                                                                  index ==
                                                                          _sets.length -
                                                                              1
                                                                      ? [
                                                                          _workoutProvider.setsplus(
                                                                              widget.rindex,
                                                                              pindex),
                                                                          _isSetChanged =
                                                                              true,
                                                                          weightController[pindex]
                                                                              .controllerlist
                                                                              .add(new TextEditingController(text: provider2.userdata.bodyStats.last.weight.toString())),
                                                                          repsController[pindex]
                                                                              .controllerlist
                                                                              .add(new TextEditingController(text: null)),
                                                                          showToast(
                                                                              "세트를 추가했어요! 다음으로 넘어갈 수도 있어요")
                                                                        ]
                                                                      : null,
                                                                  _editWorkoutwCheck()
                                                                ]
                                                              : _showMyDialog(
                                                                  pindex,
                                                                  index,
                                                                  true);
                                                        },
                                                        icon: Icon(
                                                            Icons
                                                                .play_arrow_rounded,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )),
                                                Container(
                                                    width: 80,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _displaySetWeightAlert(
                                                            pindex, index);
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                            "${_sets[index].weight}",
                                                            textScaleFactor:
                                                                1.7,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                      ),
                                                    )),
                                                Container(
                                                    width: 140,
                                                    child: Center(
                                                        child: TimeInputField(
                                                            duration:
                                                                _sets[index]
                                                                    .reps,
                                                            rindex:
                                                                widget.rindex,
                                                            pindex: pindex,
                                                            index: index))),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    collapsed: Container(),
                                    expanded: Container(
                                      child: Center(
                                        child: CircularCountDownTimer(
                                          duration: (((_sets[index].reps /
                                                              10000)
                                                          .floor() *
                                                      3600) +
                                                  ((_sets[index].reps -
                                                                  (_sets[index].reps /
                                                                              10000)
                                                                          .floor() *
                                                                      10000) /
                                                              100)
                                                          .floor() *
                                                      60 +
                                                  (_sets[index].reps -
                                                      (_sets[index].reps / 100)
                                                              .floor() *
                                                          100))
                                              .toInt(),
                                          initialDuration: 0,
                                          controller: _countcontroller[index],
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          ringColor: Colors.grey[300]!,
                                          ringGradient: null,
                                          fillColor: Colors.purpleAccent[100]!,
                                          fillGradient: null,
                                          backgroundColor: Colors.purple[500],
                                          backgroundGradient: null,
                                          strokeWidth: 20.0,
                                          strokeCap: StrokeCap.round,
                                          textStyle: TextStyle(
                                              fontSize: 33.0 *
                                                  _themeProvider.userFontSize /
                                                  0.8,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                          textFormat:
                                              CountdownTextFormat.HH_MM_SS,
                                          isReverse: true,
                                          isReverseAnimation: false,
                                          isTimerTextShown: true,
                                          autoStart: false,
                                          onStart: () {
                                            debugPrint('Countdown Started');
                                          },
                                          onComplete: () {
                                            _countcontroller[index].reset();
                                            debugPrint('Countdown Ended');
                                          },
                                          onChange: (String timeStamp) {
                                            debugPrint(
                                                'Countdown Changed $timeStamp');
                                          },
                                          timeFormatterFunction:
                                              (defaultFormatterFunction,
                                                  duration) {
                                            if (duration.inSeconds == 10) {
                                              return "Start";
                                            } else {
                                              return Function.apply(
                                                  defaultFormatterFunction,
                                                  [duration]);
                                            }
                                          },
                                        ),
                                      ),
                                    )),
                              );
                            },
                            separatorBuilder:
                                (BuildContext _context, int index) {
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
                            itemCount: _sets.length),
                      ),
                      Container(
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
                                icon: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 24,
                                )),
                            IconButton(
                                onPressed: () {
                                  _isSetChanged = true;
                                  _workoutProvider.setsplus(
                                      widget.rindex, pindex);
                                  weightController[pindex].controllerlist.add(
                                      new TextEditingController(
                                          text: provider2
                                              .userdata.bodyStats.last.weight
                                              .toString()));
                                  repsController[pindex].controllerlist.add(
                                      new TextEditingController(text: null));
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
                                                size: 30,
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
                                  primary:
                                      (provider.nowonrindex != widget.rindex) &&
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
                                          {_showMyDialog_finish()}
                                        else
                                          {
                                            _routinetimeProvider.resettimer(
                                                _workoutProvider
                                                    .workoutdata
                                                    .routinedatas[widget.rindex]
                                                    .exercises[pindex]
                                                    .rest),
                                            provider.routinecheck(widget.rindex)
                                          }
                                      ];
                              },
                              child: Text(
                                  (provider.nowonrindex != widget.rindex) &&
                                          _routinetimeProvider.isstarted
                                      ? '다른 루틴 수행중'
                                      : provider.routineButton),
                            );
                          })),
                          Container(
                              child: pindex !=
                                      _workoutProvider
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
                                                size: 30,
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

  void exguide(int eindex) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Colors.white,
            ),
            child: ExerciseGuide(
              eindex: eindex,
              isroutine: true,
            ));
      },
    );
  }

  void _showMyDialog_finisddsh() {
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
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('운동을 종료 하시겠나요?',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
                Text('외부를 터치하면 취소 할 수 있어요',
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            actions: <Widget>[
              _FinishConfirmButton(),
            ],
          );
        });
  }

  Widget _FinishConfirmButton() {
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              recordExercise();
              _editHistoryCheck();
              _editWorkoutwoCheck();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("운동 종료 하기",
                textScaleFactor: 1.7, style: TextStyle(color: Colors.white))));
  }

  void _displaySetRestAlert(pindex) {
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
              '휴식 시간을 설정 해볼게요',
              textScaleFactor: 1.5,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('세트당 휴식 시간을 입력해주세요',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 20),
                TextField(
                  controller: _resttimectrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 21 * _themeProvider.userFontSize / 0.8,
                    color: Colors.white,
                  ),
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
                      hintText: "휴식 시간 입력(초)",
                      hintStyle: TextStyle(
                          fontSize: 24.0 * _themeProvider.userFontSize / 0.8,
                          color: Colors.white)),
                  onChanged: (text) {
                    int changetime;
                    changetime = int.parse(text);
                    _routinetimeProvider.resttimecheck(changetime);
                  },
                ),
              ],
            ),
            actions: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    foregroundColor: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                    padding: EdgeInsets.all(12.0),
                  ),
                  child: Text('휴식 시간 설정하기',
                      textScaleFactor: 1.5,
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _workoutProvider.resttimecheck(
                        widget.rindex, pindex, _routinetimeProvider.changetime);
                    _editWorkoutwCheck();
                    _resttimectrl.clear();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ),
            ],
          );
        });
  }

  void _displaySetWeightAlert(pindex, eindex) {
    double input = _workoutProvider.workoutdata.routinedatas[widget.rindex]
        .exercises[pindex].sets[eindex].weight
        .abs();
    _additionalweightctrl.text = _workoutProvider.workoutdata
        .routinedatas[widget.rindex].exercises[pindex].sets[eindex].weight
        .abs()
        .toString();
    _routinemenuProvider.boolchangeto(_workoutProvider
                .workoutdata
                .routinedatas[widget.rindex]
                .exercises[pindex]
                .sets[eindex]
                .weight <
            0
        ? false
        : true);
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
              '중량 추가/제거가 가능해요',
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('추가/제거할 중량을 입력해주세요',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 20),
                _posnegControllerWidget(),
                SizedBox(
                  width: 150,
                  child: Consumer2<RoutineMenuStater, WorkoutdataProvider>(
                      builder: (context, provider, provider2, child) {
                    return TextField(
                      controller: _additionalweightctrl,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                      style: TextStyle(
                        fontSize: 21 * _themeProvider.userFontSize / 0.8,
                        color: provider.ispositive ? Colors.white : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          isDense: true,
                          prefixIcon: Text(
                            provider.ispositive ? "+" : "-",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 35 * _themeProvider.userFontSize / 0.8,
                              color: provider.ispositive
                                  ? Colors.white
                                  : Colors.red,
                            ),
                          ),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 0, minHeight: 0),
                          filled: true,
                          enabledBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 3),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 3),
                          ),
                          hintText: "입력",
                          hintStyle: TextStyle(
                              fontSize:
                                  21.0 * _themeProvider.userFontSize / 0.8,
                              color: provider.ispositive
                                  ? Colors.white
                                  : Colors.red)),
                      onChanged: (text) {
                        input = double.parse(text);
                      },
                    );
                  }),
                ),
              ],
            ),
            actions: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    foregroundColor: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                    padding: EdgeInsets.all(12.0),
                  ),
                  child: Text('중량 추가/제거 하기',
                      textScaleFactor: 1.7,
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    _workoutProvider.weightcheck(widget.rindex, pindex, eindex,
                        _routinemenuProvider.ispositive ? input : -input);
                    _editWorkoutwCheck();
                    _additionalweightctrl.clear();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ),
            ],
          );
        });
  }

  Widget _posnegControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<RoutineMenuStater>(builder: (context, provider, child) {
        return Container(
          color: Theme.of(context).cardColor,
          child: CupertinoSlidingSegmentedControl(
              groupValue: provider.ispositive ? 0 : 1,
              children: _menuList,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              backgroundColor: Theme.of(context).cardColor,
              thumbColor: provider.ispositive
                  ? Theme.of(context).primaryColor
                  : Colors.red,
              onValueChanged: (i) {
                provider.boolchange();
              }),
        );
      }),
    );
  }

  void recordExercise() {
    var exercise_all =
        _workoutProvider.workoutdata.routinedatas[widget.rindex].exercises;
    for (int n = 0; n < exercise_all.length; n++) {
      var recordedsets = exercise_all[n].sets.where((sets) {
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

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    _routinemenuProvider =
        Provider.of<RoutineMenuStater>(context, listen: false);

    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);

    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercises = _exProvider.exercisesdata.exercises;
    _staticPageState = Provider.of<StaticPageProvider>(context, listen: false);
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _prefsProvider = Provider.of<PrefsProvider>(context, listen: false);

    return Scaffold(
        appBar: _appbarWidget(),
        body: _exercisedetailPage(),
        backgroundColor: Color(0xFF101012));
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }
}
