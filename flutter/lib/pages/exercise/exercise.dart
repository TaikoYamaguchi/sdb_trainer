import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/exercise/each_exercise.dart';
import 'package:sdb_trainer/pages/exercise/each_plan.dart';
import 'package:sdb_trainer/pages/exercise/each_workout.dart';
import 'package:sdb_trainer/pages/search/exercise_filter.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
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
  final ScrollController _scroller = ScrollController();
  final _listViewKey = GlobalKey();
  var _userProvider;
  var _exProvider;
  var _workoutProvider;
  var _famousdataProvider;
  var _routinetimeProvider;
  var _PopProvider;
  bool modecheck = false;
  bool dragstart = false;
  PageController? controller;
  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;

  var keyPlus = GlobalKey();
  var keyContainer = GlobalKey();
  var keyCheck = GlobalKey();
  var keySearch = GlobalKey();
  var keySelect = GlobalKey();

  Map<String, String> UNIT_ID = kReleaseMode
      ? {
          'ios': 'ca-app-pub-1921739371491657/3676809918',
          'android': 'ca-app-pub-1921739371491657/2555299930',
        }
      : {
          'ios': 'ca-app-pub-3940256099942544/2934735716',
          'android': 'ca-app-pub-3940256099942544/6300978111',
        };
  BannerAd? banner;

  List<TutorialItem> itens = [];

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
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
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Future<void> _onRefresh() {
    _famousdataProvider.getdata();
    return Future<void>.value();
  }

  Widget _createListener(Widget child) {
    return Listener(
      child: child,
      onPointerMove: (PointerMoveEvent event) {
        if (dragstart) {
          RenderBox render =
              _listViewKey.currentContext?.findRenderObject() as RenderBox;
          Offset position = render.localToGlobal(Offset.zero);
          double topY = position.dy;
          double bottomY = topY + render.size.height;
          const detectedRange = 100;

          const moveDistance = 3;
          if (event.position.dy < topY + detectedRange) {
            var to = _scroller.offset - moveDistance;
            to = (to < 0) ? 0 : to;
            _scroller.jumpTo(to);
          }
          if (event.position.dy > bottomY - detectedRange) {
            _scroller.jumpTo(_scroller.offset + moveDistance);
          }
        }
        // print("x: ${position.dy}, "
        //     "y: ${position.dy}, "
        //     "height: ${render.size.height}, "
        //     "width: ${render.size.width}");
      },
    );
  }

  Widget _myWorkout() {
    return Container(
      //padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        key: _listViewKey,
        controller: _scroller,
        shrinkWrap: true,
        children: [
          Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
            List routinelist = provider.workoutdata.routinedatas;
            return ReorderableListView.builder(
                physics: const NeverScrollableScrollPhysics(),
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
                onReorderStart: (index) {
                  dragstart = true;
                },
                onReorderEnd: (index) {
                  dragstart = false;
                },
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (BuildContext _context, int index) {
                  final List<Color> color = <Color>[];
                  color.add(const Color(0xFffc60a8).withOpacity(1.0));
                  color.add(Theme.of(context).primaryColor.withOpacity(1.0));
                  final List<double> stops = <double>[];
                  stops.add(0.3);
                  stops.add(1.0);

                  final LinearGradient gradientColors = LinearGradient(
                      colors: color,
                      stops: stops,
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter);
                  return Scrollable(
                    key: Key('$index'),
                    viewportBuilder:
                        (BuildContext context, ViewportOffset position) => Card(
                      color: Theme.of(context).cardColor,
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      margin:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 6.0),
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
                                      return NameInputDialog(rindex: index);
                                    },
                                  );
                                },
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor:
                                    Theme.of(context).highlightColor,
                                icon: Icons.edit,
                                label: '수정',
                              ),
                              SlidableAction(
                                onPressed: (_) {
                                  _routinetimeProvider.isstarted
                                      ? showToast("운동중엔 루틴제거는 불가능 해요")
                                      : showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return showsimpleAlerts(
                                              layer: 1,
                                              rindex: index,
                                              eindex: -1,
                                            );
                                          });
                                },
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor:
                                    Theme.of(context).highlightColor,
                                icon: Icons.delete,
                                label: '삭제',
                              )
                            ]),
                        child: Consumer<RoutineTimeProvider>(
                            builder: (builder, provider, child) {
                          bool curWorkout = index == provider.nowonrindex;
                          return Builder(
                              builder: (context) => Material(
                                    elevation: provider.isstarted
                                        ? curWorkout
                                            ? 5
                                            : 0
                                        : 0,
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                          color: provider.isstarted
                                              ? curWorkout
                                                  ? const Color(0xffCEEC97)
                                                  : Theme.of(context).cardColor
                                              : Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      child: InkWell(
                                        hoverColor: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
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
                                                          TransitionEffect
                                                              .RIGHT_TO_LEFT))
                                              : Navigator.push(
                                                  context,
                                                  Transition(
                                                      child: EachPlanDetails(
                                                        rindex: index,
                                                      ),
                                                      transitionEffect:
                                                          TransitionEffect
                                                              .RIGHT_TO_LEFT));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 5, 0, 5),
                                              leading: Container(
                                                height: double.infinity,
                                                padding: const EdgeInsets.only(
                                                    right: 15.0),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        right: BorderSide(
                                                            width: 1.0,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark))),
                                                child: routinelist[index]
                                                            .mode ==
                                                        0
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        child: SizedBox(
                                                          width: 25,
                                                          child: SvgPicture.asset(
                                                              "assets/svg/dumbel_on.svg",
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                        ),
                                                      )
                                                    : CircularPercentIndicator(
                                                        radius: 20,
                                                        lineWidth: 5.0,
                                                        animation: true,
                                                        percent: (routinelist[
                                                                        index]
                                                                    .exercises[
                                                                        0]
                                                                    .progress +
                                                                1) /
                                                            (routinelist[index]
                                                                    .exercises[
                                                                        0]
                                                                    .plans
                                                                    .length +
                                                                1),
                                                        center: Text(
                                                          "${routinelist[index].exercises[0].progress + 1}/${routinelist[index].exercises[0].plans.length + 1}",
                                                          textScaleFactor: 0.8,
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorLight,
                                                          ),
                                                        ),
                                                        linearGradient:
                                                            gradientColors,
                                                        circularStrokeCap:
                                                            CircularStrokeCap
                                                                .round,
                                                      ),
                                              ),
                                              title: Text(
                                                routinelist[index].name,
                                                textScaleFactor: 1.5,
                                                style: TextStyle(
                                                    color: curWorkout
                                                        ? Colors.black
                                                        : Theme.of(context)
                                                            .primaryColorLight,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                  routinelist[index].mode == 0
                                                      ? "리스트 모드 - ${routinelist[index].exercises.length}개 운동"
                                                      : "플랜 모드",
                                                  textScaleFactor: 1.0,
                                                  style: TextStyle(
                                                      color: curWorkout
                                                          ? Colors.black
                                                          : Theme.of(context)
                                                              .primaryColorLight)),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  provider.isstarted
                                                      ? curWorkout
                                                          ? Text(
                                                              provider.userest
                                                                  ? provider.timeron <
                                                                          0
                                                                      ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                                                      : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                                                  : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                                              textScaleFactor:
                                                                  1.4,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: (provider.userest &&
                                                                          provider.timeron <
                                                                              0)
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .black))
                                                          : Container()
                                                      : Container(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (Slidable.of(context)!
                                                              .actionPaneType
                                                              .value ==
                                                          ActionPaneType.none) {
                                                        Slidable.of(context)
                                                            ?.openEndActionPane();
                                                      } else {
                                                        Slidable.of(context)
                                                            ?.close();
                                                      }
                                                    },
                                                    child: Container(
                                                      color: provider.isstarted
                                                          ? index ==
                                                                  provider
                                                                      .nowonrindex
                                                              ? const Color(
                                                                  0xffCEEC97)
                                                              : Theme.of(
                                                                      context)
                                                                  .cardColor
                                                          : Theme.of(context)
                                                              .cardColor,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                12, 8, 12, 8),
                                                        child: Container(
                                                          height: 30.0,
                                                          width: 4.0,
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          8.0))),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ),
                                      ),
                                    ),
                                  ));
                        }),
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
                              color: Theme.of(context).highlightColor,
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
                                const Text("원하는 운동 플랜을 만들 수 있어요",
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
          ),

          /*
          Container(
            color: Theme.of(context).canvasColor,
            height: 50.0,
            child: AdWidget(
              ad: banner!,
            ),
          )*/
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              _exProvider.settags2(['All']);

              filterExercise(_exProvider.tags);
              Navigator.push(
                  context,
                  Transition(
                      child: const ExerciseFilter(),
                      transitionEffect: TransitionEffect.BOTTOM_TO_TOP));
            },
            child: Card(
              elevation: 0.3,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: ExImage().body_part_image[key_list[index]] != ''
                          ? Container(
                              height: MediaQuery.of(context).size.width / 4,
                              width: MediaQuery.of(context).size.width / 4,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                  image: DecorationImage(
                                    image: AssetImage(ExImage()
                                        .body_part_image[key_list[index]]),
                                    fit: BoxFit.cover,
                                  )))
                          : Container(
                              color: Theme.of(context).primaryColorLight,
                              child: const Icon(
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

    return Consumer<PopProvider>(builder: (Builder, provider, child) {
      bool _goto = provider.goto;
      _goto == false
          ? null
          : [
              provider.exstackup(0),
              Future.delayed(Duration.zero, () async {
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
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
            ];
      return Scaffold(
        appBar: _appbarWidget(),
        body: Consumer2<ExercisesdataProvider, WorkoutdataProvider>(
            builder: (context, provider1, provider2, widget) {
          if (provider2.workoutdata != null) {
            return _createListener(_myWorkout());
          }
          return Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }),
      );
    });
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }
}
