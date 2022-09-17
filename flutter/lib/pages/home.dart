import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:transition/transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _exercisesdataProvider;
  var _userdataProvider;
  var _bodyStater;
  var _staticPageState;
  var _chartIndex;
  var _historydataAll;
  var _testdata0;
  var allEntries;

  var _prefs;
  String _addexinput = '';
  late var _testdata = _testdata0.exercises;


  PreferredSizeWidget _appbarWidget() {
    //if (_userdataProvider.userdata != null) {
    return AppBar(
      title: Consumer<UserdataProvider>(builder: (builder, provider, child) {
        if (provider.userdata != null) {
          return Text(
            provider.userdata.nickname + "님",
            style: TextStyle(color: Colors.white),
          );
        } else {
          return PreferredSize(
              preferredSize: Size.fromHeight(56.0),
              child: Container(
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator())));
        }
      }),
      actions: [
        IconButton(
          icon: SvgPicture.asset("assets/svg/chart.svg"),
          onPressed: () {
            _bodyStater.change(3);
            _staticPageState.change(false);
            _chartIndex.changePageController(1);
          },
        )
      ],
      backgroundColor: Colors.black,
    );
  }

  Widget _homeWidget(_exunique, context) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text("SDB ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.w600)),
                  Text(
                      (_exercisesdataProvider
                                  .exercisesdata
                                  .exercises[(_exercisesdataProvider
                                      .exercisesdata.exercises
                                      .indexWhere((exercise) {
                                if (exercise.name == "스쿼트") {
                                  return true;
                                } else {
                                  return false;
                                }
                              }))]
                                  .onerm +
                              _exercisesdataProvider
                                  .exercisesdata
                                  .exercises[(_exercisesdataProvider
                                      .exercisesdata.exercises
                                      .indexWhere((exercise) {
                                if (exercise.name == "데드리프트") {
                                  return true;
                                } else {
                                  return false;
                                }
                              }))]
                                  .onerm +
                              _exercisesdataProvider
                                  .exercisesdata
                                  .exercises[(_exercisesdataProvider
                                      .exercisesdata.exercises
                                      .indexWhere((exercise) {
                                if (exercise.name == "벤치프레스") {
                                  return true;
                                } else {
                                  return false;
                                }
                              }))]
                                  .onerm)
                          .floor()
                          .toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.w800)),
                  Text(
                      "/" +
                          (_exercisesdataProvider
                                      .exercisesdata
                                      .exercises[(_exercisesdataProvider
                                          .exercisesdata.exercises
                                          .indexWhere((exercise) {
                                    if (exercise.name == "스쿼트") {
                                      return true;
                                    } else {
                                      return false;
                                    }
                                  }))]
                                      .goal +
                                  _exercisesdataProvider
                                      .exercisesdata
                                      .exercises[(_exercisesdataProvider
                                          .exercisesdata.exercises
                                          .indexWhere((exercise) {
                                    if (exercise.name == "데드리프트") {
                                      return true;
                                    } else {
                                      return false;
                                    }
                                  }))]
                                      .goal +
                                  _exercisesdataProvider
                                      .exercisesdata
                                      .exercises[(_exercisesdataProvider
                                          .exercisesdata.exercises
                                          .indexWhere((exercise) {
                                    if (exercise.name == "벤치프레스") {
                                      return true;
                                    } else {
                                      return false;
                                    }
                                  }))]
                                      .goal)
                              .floor()
                              .toString() +
                          "kg",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600)),
                ]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _lastRoutineWidget(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _liftingStatWidget(_exunique, context),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _countHistoryWidget(context),
            ),

          ],
        ),
      ),
    );
  }

  Widget _lastRoutineWidget() {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Card(
        color: Theme.of(context).cardColor,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('''최근 수행한 루틴은''',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                ),
                GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.settings, color: Colors.grey, size: 18.0))
              ],
            ),
            Consumer<PrefsProvider>(builder: (builder, provider, child) {
              final storage = FlutterSecureStorage();
              return Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    Text(provider.prefs.getString('lastroutine') == null ? '아직 한번도 루틴을 수행하지 않았습니다.' : '${provider.prefs.getString('lastroutine')}',
                        style: TextStyle(
                            color: Color(0xFffc60a8),
                            fontSize: 24,
                            fontWeight: FontWeight.w600)),

                  ],
                ),
              );
            }),
          ]),
        ));
  }

  Widget _countHistoryWidget(context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Card(
        color: Theme.of(context).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: deviceWidth / 2),
                      child: Text('''1년 동안''',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.settings, color: Colors.grey, size: 18.0))
              ],
            ),
            Consumer<HistorydataProvider>(builder: (builder, provider, child) {
              final storage = FlutterSecureStorage();
              return Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('''38''',
                        style: TextStyle(
                            color: Color(0xFffc60a8),
                            fontSize: 54,
                            fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('''일 운동했어요!''',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }),
          ]),
        ));
  }

  Widget _liftingStatWidget(_exunique, context) {
    return Card(
        color: Theme.of(context).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text('''Lifting Stats''',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      _testdata = _testdata0.exercises;
                      setState(() {});
                      exselect(true, true, context);
                    },
                    child: Icon(Icons.settings, color: Colors.grey, size: 24.0))
              ],
            ),
            SizedBox(height: 8.0),
            Consumer<ExercisesdataProvider>(
                builder: (builder, provider, child) {
              final storage = FlutterSecureStorage();
              return ReorderableListView.builder(
                  onReorder: (int oldIndex, int newIndex) {
                    if (oldIndex > newIndex) {
                      provider.insertHomeExList(
                          newIndex, provider.homeExList[oldIndex]);
                      provider.removeHomeExList(oldIndex + 1);
                    } else {
                      provider.insertHomeExList(
                          newIndex, provider.homeExList[oldIndex]);
                      provider.removeHomeExList(oldIndex);
                    }
                    storage.write(
                        key: 'sdb_HomeExList',
                        value: jsonEncode((_exercisesdataProvider.homeExList)));
                  },
                  itemBuilder: (BuildContext _context, int index) {
                    return Slidable(
                        key: Key("$index"),
                        endActionPane: ActionPane(
                            extentRatio: 0.15,
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  provider.removeHomeExList(index);
                                  storage.write(
                                      key: 'sdb_HomeExList',
                                      value: jsonEncode(
                                          (_exercisesdataProvider.homeExList)));
                                },
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                              )
                            ]),
                        child: _homeProgressiveBarChart(index, context));
                  },
                  shrinkWrap: true,
                  itemCount: _exercisesdataProvider.homeExList.length);
            }),
          ]),
        ));
  }

  void exselect(bool isadd, bool isex, context, [int where = 0]) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: Center(
                child: _exercises_searchWidget(
                    isadd, isex, where, state, context)),
          );
        });
      },
    );
  }

  Widget _exercises_searchWidget(
      bool isadd, bool isex, int where, StateSetter state, context) {
    return Column(
      children: [
        Container(
          height: 15,
        ),
        Container(
          child: Text(
            isex ? '운동을 선택해주세요' : '1RM 기준 운동을 선택해주세요',
            style: TextStyle(
                fontSize: 24.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                hintText: "Exercise Name",
                hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              onChanged: (text) {
                searchExercise(text.toString(), state);
              }),
        ),
        exercisesWidget(_testdata, true, isadd, isex, where, context)
      ],
    );
  }

  void searchExercise(String query, StateSetter updateState) {
    setState(() {});
    final suggestions =
        _exercisesdataProvider.exercisesdata.exercises.where((exercise) {
      final exTitle = exercise.name;
      return (exTitle.contains(query)) as bool;
    }).toList();

    updateState(() => _testdata = suggestions);
  }

  Widget exercisesWidget(
      exuniq, bool shirink, bool isadd, bool isex, int where, context) {
    double top = 0;
    double bottom = 0;
    return Expanded(
      //color: Colors.black,
      child: Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
        return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 5),
            itemBuilder: (BuildContext _context, int index) {
              if (index == 0) {
                top = 20;
                bottom = 0;
              } else if (index == exuniq.length - 1) {
                top = 0;
                bottom = 20;
              } else {
                top = 0;
                bottom = 0;
              }
              ;
              final storage = FlutterSecureStorage();
              return GestureDetector(
                onTap: () {
                  _exercisesdataProvider.addHomeExList(exuniq[index].name);
                  storage.write(
                      key: 'sdb_HomeExList',
                      value: jsonEncode((_exercisesdataProvider.homeExList)));
                  Navigator.of(context).pop();
                },
                child: Container(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(top),
                            bottomRight: Radius.circular(bottom),
                            topLeft: Radius.circular(top),
                            bottomLeft: Radius.circular(bottom))),
                    height: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exuniq[index].name,
                              style:
                                  TextStyle(fontSize: 21, color: Colors.white),
                            ),
                            Text(
                                "1RM: ${exuniq[index].onerm.toStringAsFixed(1)}/${exuniq[index].goal.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF717171))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext _context, int index) {
              return Container(
                alignment: Alignment.center,
                height: 1,
                color: Color(0xFF212121),
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 1,
                  color: Color(0xFF717171),
                ),
              );
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: shirink,
            itemCount: exuniq.length);
      }),
    );
  }

  Widget _homeProgressiveBarChart(index, context) {
    return _exercisesdataProvider.homeExList.length > index
        ? Padding(
            key: Key('$index'),
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () => {
                _chartIndex.change(index),
                _chartIndex.changePageController(0),
                _staticPageState.change(true),
                _bodyStater.change(3),
              },
              child: Container(
                height: 24,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width / 2 - 40,
                        child: Text(_exercisesdataProvider.homeExList[index],
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: LiquidLinearProgressIndicator(
                        value: _exercisesdataProvider
                                .exercisesdata
                                .exercises[(_exercisesdataProvider
                                    .exercisesdata.exercises
                                    .indexWhere((exercise) {
                              if (exercise.name ==
                                  _exercisesdataProvider.homeExList[index]) {
                                return true;
                              } else {
                                return false;
                              }
                            }))]
                                .onerm /
                            _exercisesdataProvider
                                .exercisesdata
                                .exercises[(_exercisesdataProvider
                                    .exercisesdata.exercises
                                    .indexWhere((exercise) {
                              if (exercise.name ==
                                  _exercisesdataProvider.homeExList[index]) {
                                return true;
                              } else {
                                return false;
                              }
                            }))]
                                .goal, // Defaults to 0.5.
                        borderColor: Theme.of(context).primaryColor,
                        valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).primaryColor),
                        backgroundColor: Colors.grey,
                        borderWidth: 0.0,
                        borderRadius: 15.0,
                        direction: Axis
                            .horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
                        center: Center(
                          child: Text(
                              _exercisesdataProvider
                                      .exercisesdata
                                      .exercises[(_exercisesdataProvider
                                          .exercisesdata.exercises
                                          .indexWhere((exercise) {
                                    if (exercise.name ==
                                        _exercisesdataProvider
                                            .homeExList[index]) {
                                      return true;
                                    } else {
                                      return false;
                                    }
                                  }))]
                                      .onerm
                                      .floor()
                                      .toString() +
                                  "/" +
                                  _exercisesdataProvider
                                      .exercisesdata
                                      .exercises[(_exercisesdataProvider
                                          .exercisesdata.exercises
                                          .indexWhere((exercise) {
                                    if (exercise.name ==
                                        _exercisesdataProvider
                                            .homeExList[index]) {
                                      return true;
                                    } else {
                                      return false;
                                    }
                                  }))]
                                      .goal
                                      .floor()
                                      .toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _homeGaugeChart(_exunique, index, color) {
    return _exunique.exercises.length > index
        ? GestureDetector(
            onTap: () => {
              _chartIndex.change(index),
              _chartIndex.changePageController(0),
              _staticPageState.change(true),
              _bodyStater.change(3),
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: SizedBox(
                width: 150,
                height: 150,
                child: SfRadialGauge(axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: _exunique.exercises[index].goal,
                    ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 0,
                          endValue: _exunique.exercises[index].onerm,
                          color: color)
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          widget: Container(
                              child: Column(children: <Widget>[
                            Text(_exunique.exercises[index].name,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                _exunique.exercises[index].onerm
                                        .floor()
                                        .toString() +
                                    "/" +
                                    _exunique.exercises[index].goal
                                        .floor()
                                        .toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ])),
                          angle: 90,
                          positionFactor: 0.5)
                    ],
                  )
                ]),
              ),
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    _historydataAll = Provider.of<HistorydataProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _staticPageState = Provider.of<StaticPageProvider>(context, listen: false);
    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);
    _testdata0 = Provider.of<ExercisesdataProvider>(context, listen: false)
        .exercisesdata;
    return Scaffold(
        appBar: _appbarWidget(),
        body: Consumer<ExercisesdataProvider>(
            builder: (context, provider, widget) {
          if (provider.exercisesdata != null) {
            return _homeWidget(provider.exercisesdata, context);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        }),
        backgroundColor: Colors.black);
  }
}
