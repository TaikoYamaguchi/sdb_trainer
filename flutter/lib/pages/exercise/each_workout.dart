import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/exercise/each_exercise.dart';
import 'package:sdb_trainer/pages/exercise/each_workout_search.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/utils/change_name.dart';
import 'package:sdb_trainer/src/utils/circleNumberPainter.dart';
import 'package:sdb_trainer/src/utils/exStartButton.dart';
import 'package:sdb_trainer/src/utils/my_flexible_space_bar.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';
import 'package:tutorial/tutorial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// ignore: must_be_immutable
class EachWorkoutDetails extends StatefulWidget {
  int rindex;
  EachWorkoutDetails({Key? key, required this.rindex}) : super(key: key);

  @override
  _EachWorkoutDetailsState createState() => _EachWorkoutDetailsState();
}

class _EachWorkoutDetailsState extends State<EachWorkoutDetails>
    with TickerProviderStateMixin {
  final _listViewKey = GlobalKey();
  bool dragstart = false;
  final ScrollController _scroller = ScrollController();
  var _userProvider;
  var _workoutProvider;
  var _routinetimeProvider;
  var backupwddata;
  var _PopProvider;
  var _PrefsProvider;
  final controller = TextEditingController();
  var _exProvider;
  late List<hisdata.Exercises> exerciseList = [];
  bool _exImageOpen = true;

  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  var btnDisabled;
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
            const Text(
              "+버튼을 눌러 원하는 운동을 추가 하세요",
              textScaleFactor: 1.7,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 100,
            )
          ],
          widgetNext: const Text(
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
          const Text(
            "이곳에 검색하여 원하는 운동을 찾고,",
            textScaleFactor: 1.7,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 100,
          )
        ],
        widgetNext: const Text(
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
          const Text(
            "운동을 클릭하여 원하는 운동을 추가한 뒤,",
            textScaleFactor: 1.7,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 100,
          )
        ],
        widgetNext: const Text(
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
          const Text(
            "이곳을 눌러 Routine 수정을 완료하세요",
            textScaleFactor: 1.7,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 100,
          )
        ],
        widgetNext: const Text(
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
            child: Consumer<WorkoutdataProvider>(
                builder: (builder, provider, child) {
              return Text(
                provider.workoutdata.routinedatas[widget.rindex].name,
                textScaleFactor: 1.3,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              );
            }),
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
                    Future.delayed(const Duration(milliseconds: 100))
                        .then((value) {
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
    bool btnDisabled = false;
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 10 && btnDisabled == false) {
          btnDisabled = true;
          Navigator.of(context).pop();
        }
      },
      child: Consumer3<WorkoutdataProvider, ExercisesdataProvider,
          RoutineTimeProvider>(builder: (builder, wdp, exp, provider3, child) {
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
              physics: scrollable ? const NeverScrollableScrollPhysics() : null,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = exlist.removeAt(oldIndex);
                  exlist.insert(newIndex, item);
                  if (oldIndex == _routinetimeProvider.nowoneindex &&
                      widget.rindex == _routinetimeProvider.nowonrindex) {
                    _routinetimeProvider.nowoneindexupdate(newIndex);
                  } else if (oldIndex > _routinetimeProvider.nowoneindex &&
                      newIndex <= _routinetimeProvider.nowoneindex) {
                    _routinetimeProvider.nowoneindexupdate(
                        _routinetimeProvider.nowoneindex + 1);
                  } else if (oldIndex < _routinetimeProvider.nowoneindex &&
                      newIndex >= _routinetimeProvider.nowoneindex) {
                    _routinetimeProvider.nowoneindexupdate(
                        _routinetimeProvider.nowoneindex - 1);
                  }

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
                List doneex = wdp.workoutdata.routinedatas[widget.rindex]
                    .exercises[index].sets
                    .where((e) => e.ischecked == true)
                    .toList();
                bool curItem = index == _routinetimeProvider.nowoneindex &&
                    widget.rindex == _routinetimeProvider.nowonrindex;

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
                  _exImage ??= "";
                } catch (e) {
                  _exImage = "";
                }

                return Container(
                    key: Key('$index'),
                    child: Scrollable(
                      viewportBuilder:
                          (BuildContext context, ViewportOffset position) =>
                              Slidable(
                        endActionPane: ActionPane(
                            extentRatio:
                                _routinetimeProvider.isstarted ? 0.6 : 0.4,
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  if (_routinetimeProvider.isstarted) {
                                    if (widget.rindex ==
                                            _routinetimeProvider.nowonrindex &&
                                        index ==
                                            _routinetimeProvider.nowoneindex) {
                                      _routinetimeProvider.nowoneindexupdate(0);
                                      showToast(
                                          "${"운동 중인 " + exlist[_routinetimeProvider.nowoneindex].name} 맨 위로 올렸어요");
                                      setState(() {
                                        final item = exlist.removeAt(index);
                                        exlist.insert(0, item);
                                      });
                                    } else {
                                      if (widget.rindex ==
                                              _routinetimeProvider
                                                  .nowonrindex &&
                                          index >
                                              _routinetimeProvider.nowoneindex)
                                        _routinetimeProvider.nowoneindexupdate(
                                            _routinetimeProvider.nowoneindex +
                                                1);
                                      showToast(
                                          exlist[index].name + " 맨 위로 올렸어요");
                                      setState(() {
                                        final item = exlist.removeAt(index);
                                        exlist.insert(0, item);
                                      });
                                    }
                                  } else {
                                    showToast(
                                        exlist[index].name + " 맨 위로 올렸어요");
                                    setState(() {
                                      final item = exlist.removeAt(index);
                                      exlist.insert(0, item);
                                    });
                                  }
                                },
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor:
                                    Theme.of(context).highlightColor,
                                icon: Icons.keyboard_double_arrow_up,
                                label: '맨 위',
                              ),
                              _routinetimeProvider.isstarted &&
                                      widget.rindex ==
                                          _routinetimeProvider.nowonrindex &&
                                      index != _routinetimeProvider.nowoneindex
                                  ? SlidableAction(
                                      onPressed: (_) {
                                        if (index >
                                            _routinetimeProvider.nowoneindex) {
                                          showToast(
                                              "${"운동 중인 " + exlist[_routinetimeProvider.nowoneindex].name} 아래로 올렸어요");
                                          setState(() {
                                            final item = exlist.removeAt(index);
                                            exlist.insert(
                                                _routinetimeProvider
                                                        .nowoneindex +
                                                    1,
                                                item);
                                          });
                                        } else if (index <
                                            _routinetimeProvider.nowoneindex) {
                                          showToast(
                                              "${"운동 중인 " + exlist[_routinetimeProvider.nowoneindex].name} 아래로 내렸어요");
                                          _routinetimeProvider
                                              .nowoneindexupdate(
                                                  _routinetimeProvider
                                                          .nowoneindex -
                                                      1);
                                          setState(() {
                                            final item = exlist.removeAt(index);
                                            exlist.insert(
                                                _routinetimeProvider
                                                        .nowoneindex +
                                                    1,
                                                item);
                                          });
                                        }
                                      },
                                      backgroundColor: const Color(0xFffc60a8),
                                      foregroundColor:
                                          Theme.of(context).highlightColor,
                                      icon: index >
                                              _routinetimeProvider.nowoneindex
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      label: '현 운동',
                                    )
                                  : Container(),
                              SlidableAction(
                                onPressed: (_) {
                                  _workoutProvider.removeexAt(
                                      widget.rindex, index);
                                  _editWorkoutCheck();
                                },
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor:
                                    Theme.of(context).highlightColor,
                                icon: Icons.delete,
                                label: '삭제',
                              )
                            ]),
                        child: Builder(
                          builder: (context) => ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(top),
                                bottomRight: Radius.circular(bottom),
                                topLeft: Radius.circular(top),
                                bottomLeft: Radius.circular(bottom)),
                            child: Column(
                              children: [
                                Material(
                                  child: Ink(
                                    decoration: BoxDecoration(
                                        color: _routinetimeProvider.isstarted
                                            ? curItem
                                                ? Color(0xffCEEC97).withOpacity(1)
                                                : Colors.black.withOpacity(0.0)
                                            : Colors.white.withOpacity(0.0),
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(top),
                                            bottomRight: Radius.circular(bottom),
                                            topLeft: Radius.circular(top),
                                            bottomLeft: Radius.circular(bottom))),
                                    child: InkWell(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(top),
                                          bottomRight: Radius.circular(bottom),
                                          topLeft: Radius.circular(top),
                                          bottomLeft: Radius.circular(bottom)),
                                      onTap: () {
                                        [
                                          _PopProvider.exstackup(2),
                                          Navigator.push(
                                              context,
                                              Transition(
                                                  child: EachExerciseDetails(
                                                    ueindex: exunique.indexWhere(
                                                        (element) =>
                                                            element.name ==
                                                            exlist[index].name),
                                                    eindex: index,
                                                    rindex: widget.rindex,
                                                  ),
                                                  transitionEffect:
                                                      TransitionEffect
                                                          .RIGHT_TO_LEFT))
                                        ];
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(top),
                                                bottomRight:
                                                    Radius.circular(bottom),
                                                topLeft: Radius.circular(top),
                                                bottomLeft:
                                                    Radius.circular(bottom))),
                                        height: _exImageOpen ? 64 : 40,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  _exImageOpen
                                                      ? _exImage != ""
                                                          ? Image.asset(
                                                              _exImage,
                                                              height: 64,
                                                              width: 64,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Container(
                                                              height: 64,
                                                              width: 64,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle),
                                                              child: Icon(
                                                                  Icons
                                                                      .image_not_supported,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark),
                                                            )
                                                      : Container(),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          exlist[index].name,
                                                          textScaleFactor: 1.7,
                                                          style: TextStyle(
                                                              color: curItem
                                                                  ? Colors.black
                                                                  : Theme.of(
                                                                          context)
                                                                      .primaryColorLight),
                                                        ),
                                                        _exImageOpen
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      "휴식: ${exlist[index].rest}",
                                                                      textScaleFactor:
                                                                          1.0,
                                                                      style: const TextStyle(
                                                                          color: Color(
                                                                              0xFF717171))),
                                                                ],
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            doneex.isNotEmpty
                                                ? SizedBox(
                                                    width: 32,
                                                    height: 32,
                                                    child: CircleNumberWidget(
                                                        number: doneex.length,
                                                        color: Theme.of(context)
                                                            .primaryColorDark),
                                                  )
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
                                                    Slidable.of(context)?.close();
                                                  }
                                                },
                                                child: Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                            8, 12, 8, 12),
                                                    child: Container(
                                                      height: 30.0,
                                                      width: 4.0,
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(context)
                                                              .primaryColorDark,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                                  Radius.circular(
                                                                      8.0))),
                                                    ),
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                index == exlist.length - 1
                                    ? Container()
                                    : Container(
                                        alignment: Alignment.center,
                                        height: 0.5,
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          height: 0.5,
                                          color:
                                              Theme.of(context).primaryColorDark,
                                        ),
                                      )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ));
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
                                size: 16.0,
                                color: Theme.of(context).highlightColor,
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
                                  const Text("운동을 추가 할 수 있어요",
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

  Widget mySliver() {
    return CustomScrollView(key: _listViewKey, controller: _scroller, slivers: [
      SliverAppBar(
        snap: false,
        floating: false,
        pinned: true,
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.9),
        actions: [
          IconButton(
            key: keyPlus,
            icon: SvgPicture.asset("assets/svg/add_white.svg",
                width: 24,
                height: 24,
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
                      Future.delayed(const Duration(milliseconds: 100))
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
              begin: const EdgeInsets.only(left: 12.0, bottom: 8),
              end: const EdgeInsets.only(left: 60.0, bottom: 8, right: 40)),
          title: GestureDetector(
            onTap: () {
              /*
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NameInputDialog(rindex: widget.rindex);
                  });

               */
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<WorkoutdataProvider>(
                    builder: (builder, provider, child) {
                  return Text(
                    provider.workoutdata.routinedatas[widget.rindex].name,
                    textScaleFactor: 1.3,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ExStartButton(rindex: widget.rindex, pindex: 0),
                ),
              ],
            ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, _index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
                child: _exercisesWidget(true, true));
          },
          childCount: 1,
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
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

      return Scaffold(appBar: null, body: _createListener(mySliver()));
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
