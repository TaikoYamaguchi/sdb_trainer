import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sdb_trainer/pages/exercise_done.dart';
import 'package:sdb_trainer/pages/exercise_guide.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
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
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/themeMode.dart';

class ExStartButton extends StatefulWidget {
  int rindex;
  int pindex;
  ExStartButton({Key? key, required this.rindex, required this.pindex})
      : super(key: key);

  @override
  State<ExStartButton> createState() => _ExStartButtonState();
}

class _ExStartButtonState extends State<ExStartButton> {
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
  late List<hisdata.Exercises> exerciseList = [];

  @override
  void initState() {
    super.initState();
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

    return _exStartButton();
  }

  Widget _exStartButton() {
    return Container(child:
        Consumer<RoutineTimeProvider>(builder: (builder, provider, child) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: (provider.nowonrindex != widget.rindex) &&
                    _routinetimeProvider.isstarted
                ? Color(0xFF212121)
                : provider.buttoncolor,
            textStyle: const TextStyle()),
        onPressed: () {
          (provider.nowonrindex != widget.rindex) &&
                  _routinetimeProvider.isstarted
              ? null
              : [
                  if (_routinetimeProvider.isstarted)
                    {_showMyDialog_finish()}
                  else
                    {
                      _routinetimeProvider.resettimer(_workoutProvider
                          .workoutdata
                          .routinedatas[widget.rindex]
                          .exercises[widget.pindex]
                          .rest),
                      provider.routinecheck(widget.rindex)
                    }
                ];
        },
        child: Text((provider.nowonrindex != widget.rindex) &&
                _routinetimeProvider.isstarted
            ? '다른 루틴 수행중'
            : provider.routineButton),
      );
    }));
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
      if (!exerciseList.isEmpty) {
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
            date: DateTime.now().toString().substring(0, 10),
            isCardio: _eachex.category == "유산소" ? true : false));
      }

      if (monerm > _eachex.onerm) {
        modifyExercise(monerm, exercise_all[n].name);
      }
    }
    _postExerciseCheck();
  }

  void modifyExercise(double newonerm, exname) {
    _exProvider
        .exercisesdata
        .exercises[_exProvider.exercisesdata.exercises
            .indexWhere((element) => element.name == exname)]
        .onerm = newonerm;
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userProvider.userdata.email,
            exercises: _exProvider.exercisesdata.exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exProvider.getdata()}
            : showToast("입력을 확인해주세요"));
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
                  Navigator.of(context, rootNavigator: true).pop(),
                  Navigator.push(
                      context,
                      Transition(
                          child: ExerciseDone(
                              exerciseList: exerciseList,
                              routinetime: _routinetimeProvider.routineTime,
                              sdbdata: hisdata.SDBdata.fromJson(data)),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT)),
                  _editWorkoutwoCheck(),
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

  void _editWorkoutwoCheck() async {
    var routinedatas_all = _workoutProvider.workoutdata.routinedatas;
    for (int n = 0;
        n < routinedatas_all[_routinetimeProvider.nowonrindex].exercises.length;
        n++) {
      for (int i = 0;
          i <
              routinedatas_all[_routinetimeProvider.nowonrindex]
                  .exercises[n]
                  .sets
                  .length;
          i++) {
        routinedatas_all[_routinetimeProvider.nowonrindex]
            .exercises[n]
            .sets[i]
            .ischecked = false;
      }
    }
    WorkoutEdit(
            id: _workoutProvider.workoutdata.id,
            user_email: _userProvider.userdata.email,
            routinedatas: routinedatas_all)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? showToast("완료")
            : showToast("입력을 확인해주세요"));
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
