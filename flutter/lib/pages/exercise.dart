import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/pages/each_plan.dart';
import 'package:sdb_trainer/pages/each_workout.dart';
import 'package:sdb_trainer/pages/exercise_filter.dart';
import 'package:sdb_trainer/pages/routine_bank.dart';
import 'package:sdb_trainer/pages/unique_exercise.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:sdb_trainer/src/utils/change_name.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:tutorial/tutorial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Exercise extends StatefulWidget {
  final onPush;
  Exercise({Key? key, this.onPush}) : super(key: key);

  @override
  ExerciseState createState() => ExerciseState();
}

class ExerciseState extends State<Exercise> {
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  var _userProvider;
  var _exProvider;
  var _workoutProvider;
  var _famousdataProvider;
  var _routinetimeProvider;
  var _RoutineMenuProvider;
  var _PopProvider;
  var _PrefsProvider;
  bool modecheck = false;
  PageController? controller;
  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  String _title = "Workout List";
  var _customExUsed = false;

  var keyPlus = GlobalKey();
  var keyContainer = GlobalKey();
  var keyCheck = GlobalKey();
  var keySearch = GlobalKey();
  var keySelect = GlobalKey();
  var _menuList;

  List<TutorialItem> itens = [];

  @override
  void initState() {
    itens.addAll({
      TutorialItem(
          globalKey: keyPlus,
          touchScreen: true,
          top: 200,
          left: 50,
          children: [
            Text(
              "+버튼을 눌러 원하는 이름의 루틴을 추가하세요",
              textScaleFactor: 1.7,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            SizedBox(
              height: 100,
            )
          ],
          widgetNext: Text(
            "아무곳을 눌러 진행",
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          shapeFocus: ShapeFocus.oval),
    });

    ///FUNÇÃO QUE EXIBE O TUTORIAL.

    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          title: Row(
            children: [
              Text(
                "운동",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
            ],
          ),
          actions: [
            Consumer<RoutineMenuStater>(builder: (builder, provider, child) {
              if (provider.menustate == 2) {
                return IconButton(
                  iconSize: 30,
                  icon: Icon(Icons.refresh_rounded),
                  onPressed: () {
                    _onRefresh();
                  },
                );
              } else {
                return Container();
              }
            })
          ],
        ));
  }

  Future<void> _onRefresh() {
    _famousdataProvider.getdata();
    return Future<void>.value();
  }

  Widget _workoutWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: 40,
            alignment: Alignment.center,
            child: Center(
              child: Consumer<RoutineMenuStater>(
                  builder: (builder, provider, child) {
                return _ExerciseControllerWidget();
              }),
            ),
          ),
          Consumer<RoutineMenuStater>(builder: (builder, provider, child) {
            return _routinemenuPage();
          }),
        ],
      ),
    );
  }

  Widget _ExerciseControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<RoutineMenuStater>(builder: (context, provider, child) {
        return Container(
          child: CupertinoSlidingSegmentedControl(
              groupValue: provider.menustate,
              children: _menuList,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              thumbColor: Theme.of(context).primaryColor,
              onValueChanged: (i) {
                controller!.animateToPage(i as int,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut);
                provider.change(i);
              }),
        );
      }),
    );
  }

  Widget _routinemenuPage() {
    controller = PageController(initialPage: _RoutineMenuProvider.menustate);
    return Expanded(
      child: PageView(
        onPageChanged: (value) {
          _RoutineMenuProvider.change(value);
        },
        controller: controller,
        children: [
          group_by_target(),
          _MyWorkout(),
          RoutineBank(),
        ],
      ),
    );
  }

  Widget _MyWorkout() {
    return Container(
      //padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
            List routinelist = provider.workoutdata.routinedatas;
            return ReorderableListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                onReorder: (int oldIndex, int newIndex) {
                  _routinetimeProvider.isstarted
                      ? showToast("운동중엔 순서변경이 불가능 해요")
                      : setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = routinelist.removeAt(oldIndex);
                          routinelist.insert(newIndex, item);
                          _editWorkoutCheck();
                        });
                },
                padding: EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (BuildContext _context, int index) {
                  final List<Color> color = <Color>[];
                  color.add(Color(0xFffc60a8).withOpacity(1.0));
                  color.add(Theme.of(context).primaryColor.withOpacity(1.0));

                  final List<double> stops = <double>[];
                  stops.add(0.3);
                  stops.add(1.0);

                  final LinearGradient gradientColors = LinearGradient(
                      colors: color,
                      stops: stops,
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter);

                  return GestureDetector(
                    key: Key('$index'),
                    onTap: () {
                      _PopProvider.exstackup(1);
                      routinelist[index].mode == 0
                          ? Navigator.push(
                              context,
                              Transition(
                                  child: EachWorkoutDetails(
                                    rindex: index,
                                  ),
                                  transitionEffect:
                                      TransitionEffect.RIGHT_TO_LEFT))
                          : Navigator.push(
                              context,
                              Transition(
                                  child: EachPlanDetails(
                                    rindex: index,
                                  ),
                                  transitionEffect:
                                      TransitionEffect.RIGHT_TO_LEFT));
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Card(
                              color: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              elevation: 8.0,
                              margin: new EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 6.0),
                              child: Slidable(
                                endActionPane: ActionPane(
                                    extentRatio: 0.4,
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return NameInputDialog(
                                                  rindex: index);
                                            },
                                          );
                                        },
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor:
                                            Theme.of(context).primaryColorLight,
                                        icon: Icons.edit,
                                        label: '수정',
                                      ),
                                      SlidableAction(
                                        onPressed: (_) {
                                          _routinetimeProvider.isstarted
                                              ? showToast("운동중엔 루틴제거는 불가능 해요")
                                              : showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return showsimpleAlerts(
                                                      layer: 1,
                                                      rindex: index,
                                                      eindex: -1,
                                                    );
                                                  });
                                        },
                                        backgroundColor: Color(0xFFFE4A49),
                                        foregroundColor:
                                            Theme.of(context).primaryColorLight,
                                        icon: Icons.delete,
                                        label: '삭제',
                                      )
                                    ]),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5.0),
                                      leading: Container(
                                        height: double.infinity,
                                        padding: EdgeInsets.only(right: 15.0),
                                        decoration: new BoxDecoration(
                                            border: new Border(
                                                right: new BorderSide(
                                                    width: 1.0,
                                                    color: Theme.of(context)
                                                        .primaryColorLight))),
                                        child: routinelist[index].mode == 0
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: SizedBox(
                                                  width: 25,
                                                  child: SvgPicture.asset(
                                                      "assets/svg/dumbel_on.svg",
                                                      color: Theme.of(context)
                                                          .primaryColorLight),
                                                ),
                                              )
                                            : CircularPercentIndicator(
                                                radius: 20,
                                                lineWidth: 5.0,
                                                animation: true,
                                                percent: (routinelist[index]
                                                            .exercises[0]
                                                            .progress +
                                                        1) /
                                                    routinelist[index]
                                                        .exercises[0]
                                                        .plans
                                                        .length,
                                                center: new Text(
                                                  "${routinelist[index].exercises[0].progress + 1}/${routinelist[index].exercises[0].plans.length}",
                                                  textScaleFactor: 0.8,
                                                  style: new TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  ),
                                                ),
                                                linearGradient: gradientColors,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                              ),
                                      ),
                                      title: Text(
                                        routinelist[index].name,
                                        textScaleFactor: 1.5,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          routinelist[index].mode == 0
                                              ? Text(
                                                  "리스트 모드 - ${routinelist[index].exercises.length}개 운동",
                                                  textScaleFactor: 1.0,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorLight))
                                              : Text("플랜 모드",
                                                  textScaleFactor: 1.0,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorLight)),
                                        ],
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_right,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          size: 30.0)),
                                ),
                              )),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: routinelist.length);
          }),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    //color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return NameInputDialog(rindex: -1);
                        },
                      );
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor),
                            child: Icon(
                              Icons.add,
                              size: 28.0,
                              color: Theme.of(context).primaryColorLight,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("이곳을 눌러보세요",
                                    textScaleFactor: 1.5,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                                Text("원하는 운동 플랜을 만들 수 있어요",
                                    textScaleFactor: 1.1,
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        ]),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void filterExercise(List query) {
    final suggestions = _exProvider.exercisesdata.exercises.where((exercise) {
      if (query[0] == 'All') {
        return true;
      } else {
        final extarget = Set.from(exercise.target);
        final query_s = Set.from(query);
        return (query_s.intersection(extarget).isNotEmpty) as bool;
      }
    }).toList();
    _exProvider.settestdata_f1(suggestions);
  }

  Widget group_by_target() {
    return Container(
      child: GridView.builder(
        itemCount: 12,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 7 / 8,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          var key_list = ExImage().body_part_image.keys.toList();
          return GestureDetector(
            onTap: () {
              _PopProvider.exstackup(1);
              _exProvider.inittestdata();
              _exProvider.settags([key_list[index].toString()]);
              filterExercise(_exProvider.tags);
              Navigator.push(
                  context,
                  Transition(
                      child: ExerciseFilter(),
                      transitionEffect: TransitionEffect.BOTTOM_TO_TOP));
            },
            child: Card(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: ExImage().body_part_image[key_list[index]] != ''
                          ? Container(
                              height: MediaQuery.of(context).size.width / 4,
                              width: MediaQuery.of(context).size.width / 4,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  image: DecorationImage(
                                    image: new AssetImage(ExImage()
                                        .body_part_image[key_list[index]]),
                                    fit: BoxFit.cover,
                                  )))
                          : Container(
                              color: Theme.of(context).primaryColorLight,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 100,
                              )),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        '${key_list[index]}',
                        textScaleFactor: 1.3,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);

    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    _RoutineMenuProvider =
        Provider.of<RoutineMenuStater>(context, listen: false);
    _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);
    _menuList = <int, Widget>{
      0: Padding(
        child: Text("개별 운동",
            textScaleFactor: 1.3,
            style: TextStyle(color: Theme.of(context).primaryColorLight)),
        padding: const EdgeInsets.all(5.0),
      ),
      1: Padding(
          child: Text("나의 플랜",
              textScaleFactor: 1.3,
              style: TextStyle(color: Theme.of(context).primaryColorLight)),
          padding: const EdgeInsets.all(5.0)),
      2: Padding(
          child: Text("루틴 찾기",
              textScaleFactor: 1.3,
              style: TextStyle(color: Theme.of(context).primaryColorLight)),
          padding: const EdgeInsets.all(5.0))
    };

    _PrefsProvider.eachworkouttutor
        ? _PrefsProvider.stepone
            ? [
                Future.delayed(Duration(milliseconds: 0)).then((value) {
                  Tutorial.showTutorial(context, itens);
                  _PrefsProvider.steponedone();
                }),
              ]
            : null
        : null;

    return Consumer<PopProvider>(builder: (Builder, provider, child) {
      bool _goto = provider.goto;
      _goto == false
          ? null
          : [
              provider.exstackup(0),
              Future.delayed(Duration.zero, () async {
                int grindex = _workoutProvider.workoutdata.routinedatas
                    .indexWhere((routine) =>
                        routine.name ==
                        _PrefsProvider.prefs.getString('lastroutine'));
                Navigator.of(context).popUntil((route) => route.isFirst);
                if (_workoutProvider.workoutdata
                        .routinedatas[_routinetimeProvider.nowonrindex].mode ==
                    0) {
                  Navigator.push(
                      context,
                      Transition(
                          child: EachWorkoutDetails(
                            rindex: _routinetimeProvider.nowonrindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  Navigator.push(
                      context,
                      Transition(
                          child: EachExerciseDetails(
                            ueindex: _exProvider.exercisesdata.exercises
                                .indexWhere((element) =>
                                    element.name ==
                                    _workoutProvider
                                        .workoutdata
                                        .routinedatas[
                                            _routinetimeProvider.nowonrindex]
                                        .exercises[
                                            _routinetimeProvider.nowoneindex]
                                        .name),
                            eindex: _routinetimeProvider.nowoneindex,
                            rindex: _routinetimeProvider.nowonrindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  provider.gotooff();
                  provider.exstackup(2);
                } else {
                  Navigator.push(
                      context,
                      Transition(
                          child: EachPlanDetails(
                            rindex: _routinetimeProvider.nowonrindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  provider.gotooff();
                  provider.exstackup(1);
                }
              }),
            ];
      provider.gotolast == false
          ? null
          : [
              provider.exstackup(0),
              Future.delayed(Duration.zero, () async {
                int grindex = _workoutProvider.workoutdata.routinedatas
                    .indexWhere((routine) =>
                        routine.name ==
                        _PrefsProvider.prefs.getString('lastroutine'));
                Navigator.of(context).popUntil((route) => route.isFirst);
                if (_workoutProvider.workoutdata.routinedatas[grindex].mode ==
                    1) {
                  Navigator.push(
                      context,
                      Transition(
                          child: EachPlanDetails(
                            rindex: grindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  provider.gotooff();
                  provider.exstackup(1);
                } else {
                  Navigator.push(
                      context,
                      Transition(
                          child: EachWorkoutDetails(
                            rindex: grindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  provider.gotooff();
                  provider.exstackup(1);
                }
              }),
            ];
      return Scaffold(
        appBar: _appbarWidget(),
        body: Consumer2<ExercisesdataProvider, WorkoutdataProvider>(
            builder: (context, provider1, provider2, widget) {
          if (provider2.workoutdata != null) {
            return _workoutWidget();
          }
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }),
      );
    });
  }
}
