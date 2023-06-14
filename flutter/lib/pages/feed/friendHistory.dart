import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/historydata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/statistics/static_exercise.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/src/utils/util.dart';

// ignore: must_be_immutable
class FriendHistory extends StatefulWidget {
  SDBdata sdbdata;
  FriendHistory({Key? key, required this.sdbdata}) : super(key: key);

  @override
  _FriendHistoryState createState() => _FriendHistoryState();
}

class _FriendHistoryState extends State<FriendHistory>
    with TickerProviderStateMixin {
  var _userProvider;
  var _themeProvider;
  var _hisProvider;
  bool _isEdited = false;
  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    bool btnDisabled = false;
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
                    ];
            },
          ),
          title: Text(
            widget.sdbdata.nickname!,
            textScaleFactor: 2.0,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          actions: [
            widget.sdbdata.user_email == _userProvider.userdata.email
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_isEdited == true) {
                          HistoryExercisesEdit(
                                  history_id: widget.sdbdata.id,
                                  user_email: _userProvider.userdata.email,
                                  exercises: widget.sdbdata.exercises)
                              .patchHistoryExercises()
                              .then((data) => data["user_email"] != null
                                  ? {
                                      _hisProvider.patchHistoryExdata(
                                          widget.sdbdata.id,
                                          widget.sdbdata.exercises)
                                    }
                                  : showToast("입력을 확인해주세요"));
                        }
                        _isEdited = !_isEdited;
                      });
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 12.0, left: 8.0, bottom: 4.0, top: 8.0),
                        child: Text(_isEdited == false ? "수정" : "완료",
                            textScaleFactor: 1.8,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                      ),
                    ),
                  )
                : Container()
          ],
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _friendHistoryWidget() {
    bool btnDisabled = false;
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 10 && btnDisabled == false) {
          btnDisabled = true;
          Navigator.of(context).pop();
        }
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Consumer<HistorydataProvider>(
                    builder: (builder, provider, child) {
                  return _onechartExercisesWidget(widget.sdbdata.exercises);
                }))),
      ),
    );
  }

  Widget _onechartExercisesWidget(exercises) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReorderableListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: (int oldIndex, int newIndex) {
              if (_isEdited) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = widget.sdbdata.exercises.removeAt(oldIndex);
                  widget.sdbdata.exercises.insert(newIndex, item);
                });
              }
            },
            onReorderStart: (index) {},
            onReorderEnd: (index) {},
            itemBuilder: (BuildContext _context, int index) {
              return Row(key: Key("$index"), children: [
                _isEdited == true
                    ? ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          child: Container(
                            height: 100,
                            width: 24.0,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorDark,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0))),
                          ),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: _onechartExerciseWidget(exercises, widget.sdbdata.id,
                      _userProvider.userdata, true, index),
                )
              ]);
            },
            shrinkWrap: true,
            itemCount: exercises.length,
            scrollDirection: Axis.vertical),
        /*
        _isEdited
            ? GestureDetector(
                onTap: () {},
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
                                          color: Theme.of(context)
                                              .primaryColorLight,
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
            : Container()
            
            운동추가*/
      ],
    );
  }

  Widget _onechartExerciseWidget(
      exuniq, history_id, userdata, bool shirink, index) {
    var _exImage;
    try {
      _exImage = extra_completely_new_Ex[extra_completely_new_Ex
              .indexWhere((element) => element.name == exuniq[index].name)]
          .image;
      _exImage ??= "";
    } catch (e) {
      _exImage = "";
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _exImage != ""
                        ? Image.asset(
                            _exImage,
                            height: 48,
                            width: 48,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 48,
                            width: 48,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: Icon(Icons.image_not_supported,
                                color: Theme.of(context).primaryColorDark),
                          ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(exuniq[index].name,
                          textScaleFactor: 1.4,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                    ),
                  ],
                ),
              ),
              widget.sdbdata.user_email == userdata.email
                  ? _isEdited
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                Transition(
                                    child: StaticsExerciseDetails(
                                        exercise: exuniq[index],
                                        index: index,
                                        origin_exercises: exuniq,
                                        history_id: history_id),
                                    transitionEffect:
                                        TransitionEffect.RIGHT_TO_LEFT));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.settings,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ))
                      : Container()
                  : Container()
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.sdbdata.exercises[index].isCardio!
                      ? _cardioExerciseSetsWidget(exuniq[index].sets)
                      : _chartExerciseSetsWidget(exuniq[index].sets,
                          exuniq[index].onerm, exuniq[index].goal, userdata),
                  const SizedBox(height: 4.0)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _chartExerciseSetsWidget(sets, onerm, goal, userdata) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            padding: const EdgeInsets.all(5.0),
            height: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 25,
                        child: Text(
                          "Set",
                          textScaleFactor: 1.0,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    width: 70,
                    child: Text(
                      "Weight(${_userProvider.userdata.weight_unit})",
                      textScaleFactor: 1.0,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    )),
                Container(width: 35),
                const SizedBox(
                    width: 40,
                    child: Text(
                      "Reps",
                      textScaleFactor: 1.0,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    )),
                const SizedBox(
                    width: 70,
                    child: Text(
                      "1RM",
                      textScaleFactor: 1.0,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ],
            )),
        SizedBox(
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Padding(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                      itemBuilder: (BuildContext _context, int index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
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
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  sets[index].weight.toStringAsFixed(1),
                                  textScaleFactor: 1.7,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                  width: 35,
                                  child: SvgPicture.asset(
                                      "assets/svg/multiply.svg",
                                      color: Colors.grey,
                                      height: 14 *
                                          _themeProvider.userFontSize /
                                          0.8)),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  sets[index].reps.toString(),
                                  textScaleFactor: 1.7,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                  width: 70,
                                  child: (sets[index].reps != 1)
                                      ? Text(
                                          "${(sets[index].weight * (1 + sets[index].reps / 30)).toStringAsFixed(1)}",
                                          textScaleFactor: 1.7,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight),
                                          textAlign: TextAlign.center,
                                        )
                                      : Text(
                                          "${sets[index].weight}",
                                          textScaleFactor: 1.7,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight),
                                          textAlign: TextAlign.center,
                                        )),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext _context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          height: 0,
                          child: Container(
                            alignment: Alignment.center,
                            height: 0,
                            color: const Color(0xFF717171),
                          ),
                        );
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: sets.length))),
        ),
        const SizedBox(height: 8),
        Row(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("",
                textScaleFactor: 1.0,
                style: TextStyle(color: Color(0xFF717171))),
            const Expanded(child: SizedBox()),
            Text(
                "1RM: " +
                    onerm.toStringAsFixed(1) +
                    "/${goal.toStringAsFixed(1)}${userdata.weight_unit}",
                textScaleFactor: 1.2,
                style: const TextStyle(color: Color(0xFF717171)))
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _cardioExerciseSetsWidget(sets) {
    double totalDistance = 0;
    num totalTime = 0;
    sets.forEach((value) {
      totalDistance += value.weight;
      totalTime += value.reps;
    });
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(5.0),
            height: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 25,
                        child: Text(
                          "Set",
                          textScaleFactor: 1.0,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: const Text(
                            "거리(km)",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: const Text(
                            "운동 시간(시:분:초)",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ))
                    ],
                  ),
                ),
              ],
            )),
        SizedBox(
          child: ListView.separated(
              itemBuilder: (BuildContext _context, int index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 25,
                              child: Text(
                                "${index + 1}",
                                textScaleFactor: 1.7,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
                              child: Text(
                                sets[index].weight.toStringAsFixed(1),
                                textScaleFactor: 1.7,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
                              child: Text(
                                Duration(seconds: sets[index].reps.toInt())
                                    .toString()
                                    .split('.')[0],
                                textScaleFactor: 1.7,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext _context, int index) {
                return Container(
                  alignment: Alignment.center,
                  height: 0,
                  child: Container(
                    alignment: Alignment.center,
                    height: 0,
                    color: const Color(0xFF717171),
                  ),
                );
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sets.length),
        ),
        const SizedBox(height: 4),
        Row(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Expanded(child: SizedBox()),
            Text(
                "Total: ${totalDistance}km/${Duration(seconds: totalTime.toInt()).toString().split('.')[0]}",
                textScaleFactor: 1.0,
                style: const TextStyle(color: Color(0xFF717171))),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    return Scaffold(
      appBar: _appbarWidget(),
      body: _friendHistoryWidget(),
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
