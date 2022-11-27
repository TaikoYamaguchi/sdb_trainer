import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sdb_trainer/pages/exercise.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/version_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/navigators/exercise_navi.dart';
import 'package:sdb_trainer/navigators/profile_navi.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/pages/login.dart';
import 'package:sdb_trainer/pages/signup.dart';
import 'package:sdb_trainer/pages/feed.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/supero_version.dart';
import 'package:tutorial/tutorial.dart';
import 'dart:math' as math;
import 'package:launch_review/launch_review.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/exercise_done.dart';

import 'statics.dart';
import 'package:sdb_trainer/src/utils/notification.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _historydataProvider;
  var _exProvider;
  var _exercises;
  var _routinetimeProvider;
  var _PopProvider;
  late List<hisdata.Exercises> exerciseList = [];
  var _workoutdataProvider;
  var _bodyStater;
  var _loginState;
  var _userdataProvider;
  int updatecount = 0;
  bool _updateCheck = false;
  @override
  void initState() {
    var _appUpdateVersion = SuperoVersion.getSuperoVersion().toString();
    VersionService.loadVersionData().then((data) {
      if (data == _appUpdateVersion) {
        _updateCheck = true;
      } else {
        _showUpdateVersion();
      }
    });
    super.initState();
  }

  BottomNavigationBarItem _bottomNavigationBarItem(
      String iconName, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset("assets/svg/${iconName}_off.svg"),
      activeIcon: SvgPicture.asset("assets/svg/${iconName}_on.svg",
          color: Theme.of(context).primaryColor),
      label: label,
    );
  }

  Widget _bottomNavigationBarwidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomNavigationBar(
          backgroundColor: Color(0xFF212121),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          selectedFontSize: 16,
          unselectedItemColor: Color(0xFF717171),
          unselectedFontSize: 16,
          onTap: (int index) {
            _bodyStater.change(index);
          },
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          currentIndex: _bodyStater.bodystate,
          items: [
            _bottomNavigationBarItem("home", "홈"),
            _bottomNavigationBarItem("dumbel", "운동"),
            _bottomNavigationBarItem("feed", "피드"),
            _bottomNavigationBarItem("calendar", "기록"),
            _bottomNavigationBarItem("profile", "프로필"),
          ],
        ),
      ),
    );
  }

  void _editWorkoutCheck() async {
    WorkoutEdit(
            user_email: _userdataProvider.userdata.email,
            id: _workoutdataProvider.workoutdata.id,
            routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? [showToast("done!"), _workoutdataProvider.getdata()]
            : showToast("입력을 확인해주세요"));
  }

  void _editWorkoutwoCheck() async {
    var routinedatas_all = _workoutdataProvider.workoutdata.routinedatas;
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
            id: _workoutdataProvider.workoutdata.id,
            user_email: _userdataProvider.userdata.email,
            routinedatas: routinedatas_all)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? showToast("완료")
            : showToast("입력을 확인해주세요"));
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
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('운동을 종료 하시겠나요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('외부를 터치하면 취소 할 수 있어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
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
              if (_workoutdataProvider.workoutdata
                      .routinedatas[_routinetimeProvider.nowonrindex].mode ==
                  1) {
                recordExercise_plan();
                _editHistoryCheck();
                _editWorkoutCheck();
              } else {
                recordExercise();
                _editHistoryCheck();
                _editWorkoutwoCheck();
              }
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("운동 종료 하기",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void recordExercise_plan() {
    var exercise_all = _workoutdataProvider
        .workoutdata
        .routinedatas[_routinetimeProvider.nowonrindex]
        .exercises[0]
        .plans[_workoutdataProvider
            .workoutdata
            .routinedatas[_routinetimeProvider.nowonrindex]
            .exercises[0]
            .progress]
        .exercises;
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
      var _eachex = _exProvider.exercisesdata.exercises[_exProvider
          .exercisesdata.exercises
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

  void recordExercise() {
    var exercise_all = _workoutdataProvider
        .workoutdata.routinedatas[_routinetimeProvider.nowonrindex].exercises;
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
      var _eachex = _exProvider.exercisesdata.exercises[_exProvider
          .exercisesdata.exercises
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

  Future<dynamic> _showUpdateVersion() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () => Future.value(false),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).cardColor,
              title: new Text("앱이 업데이트 되었어요",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              content: new SingleChildScrollView(
                child: Column(
                  children: [
                    Text("더 좋은 서비스를 제공해 드리기 위해",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text("앱을 업데이트 해주세요",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
              actions: <Widget>[
                new SizedBox(
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
                          disabledForegroundColor:
                              Color.fromRGBO(246, 58, 64, 20),
                          padding: EdgeInsets.all(12.0),
                        ),
                        child: new Text("업데이트 하러가기",
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.white)),
                        onPressed: () => {
                              LaunchReview.launch(
                                  androidAppId: "com.tk_lck.supero"),
                              exit(0),
                            })),
              ],
            ));
      },
    );
  }

  void _editHistoryCheck() async {
    if (!exerciseList.isEmpty) {
      HistoryPost(
              user_email: _userdataProvider.userdata.email,
              exercises: exerciseList,
              new_record: _routinetimeProvider.routineNewRecord,
              workout_time: _routinetimeProvider.routineTime,
              nickname: _userdataProvider.userdata.nickname)
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
                  _routinetimeProvider.routinecheck(0),
                  _routinetimeProvider.getprefs(_workoutdataProvider.workoutdata
                      .routinedatas[_routinetimeProvider.nowonrindex].name),
                  _historydataProvider.getdata(),
                  _historydataProvider.getHistorydataAll(),
                  exerciseList = []
                }
              : showToast("입력을 확인해주세요"));
    } else {
      _routinetimeProvider.routinecheck(0);
    }
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
            user_email: _userdataProvider.userdata.email,
            exercises: _exProvider.exercisesdata.exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  Widget _AppCloseConfirmButton() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(false);
                  },
                  child: Text("Cancel",
                      style: TextStyle(fontSize: 20.0, color: Colors.red)))),
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: TextButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text("Confirm",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).primaryColor)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _historydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    _userdataProvider.getUsersFriendsAll();

    return Consumer2<BodyStater, LoginPageProvider>(
        builder: (builder, provider1, provider2, child) {
      return WillPopScope(
        onWillPop: () async {
          final shouldPop;
          _bodyStater.bodystate == 0
              ? shouldPop = true
              : [
                  shouldPop = false,
                  _bodyStater.bodystate == 1
                      ? _PopProvider.popon()
                      : _bodyStater.bodystate == 4
                          ? _PopProvider.propopon()
                          : null
                ];

          return shouldPop!;
        },
        child: Scaffold(
          body: _loginState.isLogin
              ? IndexedStack(index: _bodyStater.bodystate, children: <Widget>[
                  Home(),
                  TabNavigator(),
                  Feed(),
                  Calendar(),
                  TabProfileNavigator()
                ])
              : _loginState.isSignUp
                  ? SignUpPage()
                  : LoginPage(),
          floatingActionButton: Consumer<RoutineTimeProvider>(
              builder: (builder, provider, child) {
            return Container(
              child: (provider.isstarted && _bodyStater.bodystate != 1)
                  ? ExpandableFab(
                      distance: 105,
                      children: [
                        SizedBox(
                            width: 100,
                            height: 40,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  disabledForegroundColor:
                                      Color.fromRGBO(246, 58, 64, 20),
                                  padding: EdgeInsets.all(12.0),
                                ),
                                onPressed: () {
                                  provider.restcheck();
                                },
                                child: Text(
                                    provider.userest
                                        ? provider.timeron < 0
                                            ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                            : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                        : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                    style: TextStyle(
                                        color: (provider.userest &&
                                                provider.timeron < 0)
                                            ? Colors.red
                                            : Colors.white)))),
                        Row(
                          children: [
                            ActionButton(
                              onPressed: () {
                                _PopProvider.gotoon();
                                _bodyStater.change(1);
                              },
                              icon: Icon(Icons.play_arrow),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            ActionButton(
                              onPressed: _displayFinishAlert,
                              icon: Icon(Icons.stop),
                            ),
                          ],
                        ),
                      ],
                    )
                  : null,
            );
          }),
          extendBody: false,
          backgroundColor: Color(0xFF101012),
          bottomNavigationBar:
              _loginState.isLogin ? _bottomNavigationBarwidget() : null,
        ),
      );
    });
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    Key? key,
    this.initialOpen,
    required this.distance,
    required this.children,
  }) : super(key: key);

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = widget.distance;
    for (var i = 0, distances = 50.0; i < count; i++, distances += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 0,
          maxDistance: distances,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: () {
              _toggle();
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Consumer<RoutineTimeProvider>(
                builder: (builder, provider, child) {
              return Text(
                  provider.userest
                      ? provider.timeron < 0
                          ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                          : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                      : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                  style: TextStyle(
                      color: (provider.userest && provider.timeron < 0)
                          ? Colors.red
                          : Colors.white));
            }),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees,
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 8 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).primaryColor,
          elevation: 4.0,
          child: IconButton(
            iconSize: 20,
            onPressed: onPressed,
            icon: icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
