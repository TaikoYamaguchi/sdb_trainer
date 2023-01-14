import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/pages/each_workout_search.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/utils/change_name.dart';
import 'package:sdb_trainer/src/utils/my_flexible_space_bar.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';
import 'package:tutorial/tutorial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:expandable/expandable.dart';

class EachWorkoutDetails extends StatefulWidget {
  int rindex;
  EachWorkoutDetails({Key? key, required this.rindex}) : super(key: key);

  @override
  _EachWorkoutDetailsState createState() => _EachWorkoutDetailsState();
}

class _EachWorkoutDetailsState extends State<EachWorkoutDetails>
    with TickerProviderStateMixin {
  var _userProvider;
  var _workoutProvider;
  var backupwddata;
  var _PopProvider;
  var _PrefsProvider;
  var _exercises;
  final controller = TextEditingController();
  var _exProvider;
  late List<hisdata.Exercises> exerciseList = [];
  bool _inittutor = true;

  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  var btnDisabled;
  var _customExUsed = false;
  var _customRuUsed = false;
  var selectedItem = '기타';
  var selectedItem2 = '기타';

  var keyPlus = GlobalKey();
  var keyContainer = GlobalKey();
  var keyCheck = GlobalKey();
  var keySearch = GlobalKey();
  var keySelect = GlobalKey();

  List<TutorialItem> itens = [];

  //Iniciando o estado.
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
              "+버튼을 눌러 원하는 운동을 추가 하세요",
              textScaleFactor: 1.7,
              style: TextStyle(color: Colors.white),
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
      TutorialItem(
        globalKey: keySearch,
        touchScreen: true,
        top: 200,
        left: 50,
        children: [
          Text(
            "이곳에 검색하여 원하는 운동을 찾고,",
            textScaleFactor: 1.7,
            style: TextStyle(color: Colors.white),
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
        shapeFocus: ShapeFocus.square,
      ),
      TutorialItem(
        globalKey: keySelect,
        touchScreen: true,
        top: 200,
        left: 50,
        children: [
          Text(
            "운동을 클릭하여 원하는 운동을 추가한 뒤,",
            textScaleFactor: 1.7,
            style: TextStyle(color: Colors.white),
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
        shapeFocus: ShapeFocus.square,
      ),
      TutorialItem(
        globalKey: keyCheck,
        touchScreen: true,
        top: 200,
        left: 50,
        children: [
          Text(
            "이곳을 눌러 Routine 수정을 완료하세요",
            textScaleFactor: 1.7,
            style: TextStyle(color: Colors.white),
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
        shapeFocus: ShapeFocus.oval,
      ),
    });

    ///FUNÇÃO QUE EXIBE O TUTORIAL.

    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      leading: Center(
        child: GestureDetector(
          child: Icon(
            Icons.arrow_back_ios_outlined,
            color: Theme.of(context).primaryColorLight,
          ),
          onTap: () {
            btnDisabled == true
                ? null
                : [btnDisabled = true, Navigator.of(context).pop()];
          },
        ),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return NameInputDialog(rindex: widget.rindex);
                },
              );
            },
            child: Container(
              child: Consumer<WorkoutdataProvider>(
                  builder: (builder, provider, child) {
                return Text(
                  provider.workoutdata.routinedatas[widget.rindex].name,
                  textScaleFactor: 1.3,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                );
              }),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          key: keyPlus,
          icon: SvgPicture.asset(
            "assets/svg/add_white.svg",
            color: Theme.of(context).primaryColorLight,
          ),
          onPressed: () {
            _workoutProvider.dataBU(widget.rindex);
            Navigator.push(
                context,
                Transition(
                    child: EachWorkoutSearch(
                      rindex: widget.rindex,
                    ),
                    transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            _PrefsProvider.eachworkouttutor
                ? [
                    Future.delayed(Duration(milliseconds: 100)).then((value) {
                      Tutorial.showTutorial(context, itens);
                    }),
                    _PrefsProvider.tutordone()
                  ]
                : null;
          },
        )
      ],
      backgroundColor: Theme.of(context).canvasColor,
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

  Widget _exercisesWidget(bool scrollable, bool shirink) {
    return Container(
      child: Consumer3<WorkoutdataProvider, ExercisesdataProvider,
          RoutineTimeProvider>(builder: (builder, wdp, exp, rtp, child) {
        List exunique = exp.exercisesdata.exercises;
        List exlist = wdp.workoutdata.routinedatas[widget.rindex].exercises;
        for (int i = 0; i < exlist.length; i++) {
          final filter = exunique.where((unique) {
            return (unique.name == exlist[i].name);
          }).toList();
          if (filter.isEmpty) {
            _workoutProvider.removeexAt(widget.rindex, i);
            showToast('더 이상 존재하지 않는 운동은 삭제되요');
          }
        }
        return Column(children: [
          ReorderableListView.builder(
              physics: scrollable ? new NeverScrollableScrollPhysics() : null,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = exlist.removeAt(oldIndex);
                  exlist.insert(newIndex, item);
                  _editWorkoutCheck();
                });
              },
              padding: EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (BuildContext _context, int index) {
                final exinfo = exunique.where((unique) {
                  return (unique.name == exlist[index].name);
                }).toList();
                if (exlist.length == 1) {
                  top = 20;
                  bottom = 20;
                } else if (index == 0) {
                  top = 20;
                  bottom = 0;
                } else if (index == exlist.length - 1) {
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
                              (element) => element.name == exlist[index].name)]
                      .image;
                  if (_exImage == null) {
                    _exImage = "";
                  }
                } catch (e) {
                  _exImage = "";
                }

                return GestureDetector(
                  key: Key('$index'),
                  onTap: () {
                    [
                      _PopProvider.exstackup(2),
                      Navigator.push(
                          context,
                          Transition(
                              child: EachExerciseDetails(
                                ueindex: exunique.indexWhere((element) =>
                                    element.name == exlist[index].name),
                                eindex: index,
                                rindex: widget.rindex,
                              ),
                              transitionEffect: TransitionEffect.RIGHT_TO_LEFT))
                    ];
                  },
                  child: Slidable(
                    endActionPane: ActionPane(
                        extentRatio: 0.2,
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              _workoutProvider.removeexAt(widget.rindex, index);
                              _editWorkoutCheck();
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Theme.of(context).buttonColor,
                            icon: Icons.delete,
                            label: 'Delete',
                          )
                        ]),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                              color: rtp.isstarted
                                  ? (index == rtp.nowoneindex &&
                                          widget.rindex == rtp.nowonrindex)
                                      ? Color(0xffCEEC97)
                                      : Theme.of(context).cardColor
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(top),
                                  bottomRight: Radius.circular(bottom),
                                  topLeft: Radius.circular(top),
                                  bottomLeft: Radius.circular(bottom))),
                          height: 76,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    _exImage != ""
                                        ? Image.asset(
                                            _exImage,
                                            height: 64,
                                            width: 64,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height: 64,
                                            width: 64,
                                            child: Icon(
                                                Icons.image_not_supported,
                                                color: Theme.of(context)
                                                    .primaryColorDark),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle),
                                          ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exlist[index].name,
                                            textScaleFactor: 1.7,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorLight),
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "Rest: ${exlist[index].rest}",
                                                    textScaleFactor: 1.0,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF717171))),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 12, 4, 12),
                                child: Container(
                                  height: 15.0,
                                  width: 3.0,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColorDark,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                ),
                              )
                            ],
                          ),
                        ),
                        index == exlist.length - 1
                            ? Container()
                            : Container(
                                alignment: Alignment.center,
                                height: 0.5,
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 0.5,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              )
                      ],
                    ),
                  ),
                );
              },
              shrinkWrap: shirink,
              itemCount: exlist.length),
          GestureDetector(
              onTap: () {
                _workoutProvider.dataBU(widget.rindex);
                _exProvider.resettags();
                _exProvider.inittestdata();
                Navigator.push(
                    context,
                    Transition(
                        child: EachWorkoutSearch(
                          rindex: widget.rindex,
                        ),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                color: Theme.of(context).buttonColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 4.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("이곳을 눌러보세요",
                                      textScaleFactor: 1.5,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      )),
                                  Text("운동을 추가 할 수 있어요",
                                      textScaleFactor: 1.1,
                                      style: TextStyle(
                                        color: Colors.grey,
                                      )),
                                ],
                              ),
                            )
                          ]),
                    ),
                  ),
                ),
              ))
        ]);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercises = _exProvider.exercisesdata.exercises;
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);
    _PopProvider.tutorpopoff();
    _PrefsProvider.eachworkouttutor
        ? _PrefsProvider.steptwo
            ? [
                Future.delayed(Duration(milliseconds: 400)).then((value) {
                  Tutorial.showTutorial(context, itens);
                  _PrefsProvider.steptwodone();
                })
              ]
            : null
        : null;

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
        appBar: null,
        body: CustomScrollView(slivers: [
          SliverAppBar(
            snap: false,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
            actions: [
              IconButton(
                key: keyPlus,
                icon: SvgPicture.asset("assets/svg/add_white.svg",
                    color: Theme.of(context).primaryColorLight),
                onPressed: () {
                  _workoutProvider.dataBU(widget.rindex);
                  _exProvider.resettags();
                  _exProvider.inittestdata();
                  Navigator.push(
                      context,
                      Transition(
                          child: EachWorkoutSearch(
                            rindex: widget.rindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));

                  _PrefsProvider.eachworkouttutor
                      ? [
                          Future.delayed(Duration(milliseconds: 100))
                              .then((value) {
                            Tutorial.showTutorial(context, itens);
                          }),
                          _PrefsProvider.tutordone()
                        ]
                      : null;
                },
              )
            ],
            leading: Center(
              child: GestureDetector(
                child: Icon(Icons.arrow_back_ios_outlined,
                    color: Theme.of(context).primaryColorLight),
                onTap: () {
                  btnDisabled == true
                      ? null
                      : [btnDisabled = true, Navigator.of(context).pop()];
                },
              ),
            ),
            expandedHeight: _appbarWidget().preferredSize.height * 2,
            collapsedHeight: _appbarWidget().preferredSize.height,
            flexibleSpace: myFlexibleSpaceBar(
              expandedTitleScale: 1.2,
              titlePaddingTween: EdgeInsetsTween(
                  begin: EdgeInsets.only(left: 12.0, bottom: 8),
                  end: EdgeInsets.only(left: 60.0, bottom: 8)),
              title: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NameInputDialog(rindex: widget.rindex);
                      });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Consumer<WorkoutdataProvider>(
                          builder: (builder, provider, child) {
                        return Text(
                          provider.workoutdata.routinedatas[widget.rindex].name,
                          textScaleFactor: 1.3,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, _index) {
                return Container(child: _exercisesWidget(true, true));
              },
              childCount: 1,
            ),
          )
        ]),
      );
    });
  }
}
