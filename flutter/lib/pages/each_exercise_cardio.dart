import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/pages/exercise_done.dart';
import 'package:sdb_trainer/pages/exercise_guide.dart';
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
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/bodystate.dart';

class CardioExerciseDetails extends StatefulWidget {
  int ueindex;
  int eindex;
  int rindex;
  CardioExerciseDetails(
      {Key? key,
      required this.eindex,
      required this.ueindex,
      required this.rindex})
      : super(key: key);

  @override
  _CardioExerciseDetailsState createState() => _CardioExerciseDetailsState();
}

class _CardioExerciseDetailsState extends State<CardioExerciseDetails> {
  var _userProvider;
  var _hisProvider;
  var _exProvider;
  var _workoutProvider;
  var _routinetimeProvider;
  var _PopProvider;
  var _exercise;
  var _bodyStater;
  var _exercises;
  var _chartIndex;
  var _staticPageState;
  var _currentExindex;
  bool _isSetChanged = false;
  double top = 0;
  double bottom = 0;
  double? weight;
  int? reps;
  TextEditingController _resttimectrl = TextEditingController(text: "");
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
    return PageView.builder(
      onPageChanged: (value) {
        if (_routinetimeProvider.nowonrindex == widget.rindex) {
          _routinetimeProvider.nowoneindexupdate(value);
        }
      },
      controller: controller,
      itemBuilder: (context, pindex) {
        _currentExindex = pindex;
        return _exercisedetailWidget(pindex, context);
      },
      itemCount: numEx,
    );
  }

  Widget _exercisedetailWidget(pindex, context) {
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
      return Theme.of(context).primaryColorLight;
    }

    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
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
                                color: Theme.of(context).primaryColorLight,
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
                                        : Theme.of(context).primaryColorLight));
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
                                      color:
                                          Theme.of(context).primaryColorLight,
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
                                              : Theme.of(context)
                                                  .primaryColorLight));
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
                                        ? Theme.of(context).primaryColorLight
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
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight),
                                    )
                                  : _exercise.name.length < 8
                                      ? Text(
                                          _exercise.name,
                                          textScaleFactor: 4.0,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                        )
                                      : Flexible(
                                          child: Text(
                                            _exercise.name,
                                            textScaleFactor: 3.2,
                                            overflow: TextOverflow.ellipsis,
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
                              color: Theme.of(context).primaryColorLight,
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
                              color: Theme.of(context).primaryColorLight,
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
                              color: Theme.of(context).primaryColorLight,
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
                              color: Theme.of(context).primaryColorLight,
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
                                                    Theme.of(context)
                                                        .primaryColorLight),
                                            child: Checkbox(
                                                checkColor: Theme.of(context)
                                                    .primaryColorLight,
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
                                                      : _displayStartAlert(
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
                                                    : _displayStartAlert(
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
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .primaryColorLight,
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
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
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
                                                  fontSize: 21,
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "${_sets[index].weight}",
                                                  hintStyle: TextStyle(
                                                    fontSize: 21,
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
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
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
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "${_sets[index].reps}",
                                                  hintStyle: TextStyle(
                                                    fontSize: 21,
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
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorLight),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    : Text(
                                                        "${_sets[index].weight}",
                                                        textScaleFactor: 1.7,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorLight),
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
                                  color: Theme.of(context).primaryColorLight,
                                  size: 24,
                                )),
                            IconButton(
                                onPressed: () {
                                  _isSetChanged = true;
                                  _workoutProvider.setsplus(
                                      widget.rindex, pindex);
                                  weightController[pindex].controllerlist.add(
                                      new TextEditingController(text: null));
                                  repsController[pindex].controllerlist.add(
                                      new TextEditingController(text: null));
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Theme.of(context).primaryColorLight,
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
                                                color: Theme.of(context)
                                                    .primaryColorLight,
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
                                                  color: Theme.of(context)
                                                      .primaryColorLight),
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
                                            color: Theme.of(context)
                                                .primaryColorLight,
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
                                          {_displayFinishAlert()}
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
                                                color: Theme.of(context)
                                                    .primaryColorLight,
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
                                                color: Theme.of(context)
                                                    .primaryColorLight,
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
                                            color: Theme.of(context)
                                                .primaryColorLight,
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).primaryColorLight,
            ),
            child: ExerciseGuide(
              eindex: eindex,
              isroutine: true,
            ));
      },
    );
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
                color: Theme.of(context).primaryColorLight,
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
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
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
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('세트당 휴식 시간을 입력해주세요',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                SizedBox(height: 20),
                TextField(
                  controller: _resttimectrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 21,
                    color: Theme.of(context).primaryColorLight,
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
                          fontSize: 24.0,
                          color: Theme.of(context).primaryColorLight)),
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
                      color: Theme.of(context).primaryColorLight,
                    ),
                    disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                    padding: EdgeInsets.all(12.0),
                  ),
                  child: Text('휴식 시간 설정하기',
                      textScaleFactor: 1.7,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
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

  void _displayStartAlert(pindex, sindex, newvalue) {
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
              '운동을 시작 할 수 있어요',
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('운동을 시작 할까요?',
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
              _StartConfirmButton(pindex, sindex, newvalue),
            ],
          );
        });
  }

  Widget _StartConfirmButton(pindex, sindex, newvalue) {
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
              _routinetimeProvider.resettimer(_workoutProvider.workoutdata
                  .routinedatas[widget.rindex].exercises[pindex].rest);
              _routinetimeProvider.routinecheck(widget.rindex);
              _workoutProvider.boolcheck(
                  widget.rindex, pindex, sindex, newvalue);
              _editWorkoutwCheck();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("운동 시작 하기",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  void recordExercise() {
    var exercise_all =
        _workoutProvider.workoutdata.routinedatas[widget.rindex].exercises;
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
                  _routinetimeProvider.getprefs(_workoutProvider
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

    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);

    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercises = _exProvider.exercisesdata.exercises;
    _staticPageState = Provider.of<StaticPageProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _bodyStater = Provider.of<BodyStater>(context, listen: false);

    return Scaffold(appBar: _appbarWidget(), body: _exercisedetailPage());
  }
}
