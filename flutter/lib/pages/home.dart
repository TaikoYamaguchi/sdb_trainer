import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/src/model/historydata.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart' as workoutModel;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:ui' as ui;

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _exProvider;
  var _PopProvider;
  var _userProvider;
  var _bodyStater;
  var _staticPageState;
  var _chartIndex;
  var _hisProvider;
  var _testdata0;
  var allEntries;
  var _historydata;
  int _historyCardIndexCtrl = 4242;
  var _dateCtrl = 1;
  var _barsGradient;
  final _historyCardcontroller =
      PageController(viewportFraction: 0.9, initialPage: 4242, keepPage: true);
  late var _testdata = _testdata0.exercises;
  var _timer;
  var _isbottomTitleEx = false;
  var _mainFontColor;

  TextEditingController _userWeightController = TextEditingController(text: "");
  TextEditingController _userWeightGoalController =
      TextEditingController(text: "");
  Map<String, int> _exerciseCountMap = {
    "바벨 스쿼트": 0,
    "바벨 데드리프트": 0,
    "바벨 벤치 프레스": 0,
    "밀리터리 프레스": 0
  };

  Map<String, int> _exerciseCountMapOdd = {
    "바벨 스쿼트": 0,
    "바벨 데드리프트": 0,
    "바벨 벤치 프레스": 0,
    "밀리터리 프레스": 0
  };
  Map<String, int> _exerciseCountMapThird = {
    "바벨 스쿼트": 0,
    "바벨 데드리프트": 0,
    "바벨 벤치 프레스": 0,
    "밀리터리 프레스": 0
  };

  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  DateTime _toDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior = ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enableSelectionZooming: true,
        selectionRectBorderColor: Colors.red,
        selectionRectBorderWidth: 2,
        selectionRectColor: Colors.grey,
        enablePanning: true,
        maximumZoomLevel: 0.7);

    Future.delayed(const Duration(seconds: 30)).then((value) {
      _timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
        _historyCardIndexCtrl++;

        _historyCardcontroller.animateToPage(
          _historyCardIndexCtrl,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _staticPageState = Provider.of<StaticPageProvider>(context, listen: false);
    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);
    _testdata0 = Provider.of<ExercisesdataProvider>(context, listen: false)
        .exercisesdata;
    _mainFontColor = Theme.of(context).primaryColorLight;
    _barsGradient = LinearGradient(
      colors: [
        const Color(0xFffc60a8),
        Theme.of(context).primaryColor,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    return Scaffold(
      appBar: _appbarWidget(),
      body:
          Consumer<ExercisesdataProvider>(builder: (context, provider, widget) {
        if (provider.exercisesdata != null) {
          return _homeWidget(provider.exercisesdata, context);
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }

  PreferredSizeWidget _appbarWidget() {
    //if (_userProvider.userdata != null) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          title:
              Consumer<UserdataProvider>(builder: (builder, provider, child) {
            if (provider.userdata != null) {
              return Text(
                provider.userdata.nickname + "님 반가워요",
                style: TextStyle(color: _mainFontColor),
              );
            } else {
              return const PreferredSize(
                  preferredSize: Size.fromHeight(56.0),
                  child: Center(child: CircularProgressIndicator()));
            }
          }),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _dateControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl(
          groupValue: _dateCtrl,
          children: <int, Widget>{
            1: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("1주",
                  textScaleFactor: 1.1,
                  style: TextStyle(
                    color: _dateCtrl == 1 ? _mainFontColor : Colors.grey,
                  )),
            ),
            2: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("1달",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: _dateCtrl == 2 ? _mainFontColor : Colors.grey,
                    ))),
            3: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("6달",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: _dateCtrl == 3 ? _mainFontColor : Colors.grey,
                    ))),
            4: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("1년",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: _dateCtrl == 4 ? _mainFontColor : Colors.grey,
                    ))),
            5: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("모두",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: _dateCtrl == 5 ? _mainFontColor : Colors.grey,
                    )))
          },
          padding: const EdgeInsets.symmetric(horizontal: 6),
          backgroundColor: Theme.of(context).canvasColor,
          thumbColor: Theme.of(context).primaryColor,
          onValueChanged: (i) {
            setState(() {
              _dateCtrl = i as int;
              _dateController(_dateCtrl);
            });
          }),
    );
  }

  int _toDayKrInt() {
    String _toDayKr = DateFormat.E('ko_KR').format(_toDay);
    int _toDayKrInt = 0;
    switch (_toDayKr) {
      case "월":
        _toDayKrInt = 0;
        break;
      case "화":
        _toDayKrInt = 1;
        break;
      case "수":
        _toDayKrInt = 2;
        break;
      case "목":
        _toDayKrInt = 3;
        break;
      case "금":
        _toDayKrInt = 4;
        break;
      case "토":
        _toDayKrInt = 5;
        break;
      case "일":
        _toDayKrInt = 6;
        break;
    }
    return _toDayKrInt;
  }

  static int calculateMonthSize(DateTime dateTime) {
    return dateTime.year * 12 + dateTime.month;
  }

  static int getMonthSizeBetweenDates(DateTime initialDate, DateTime endDate) {
    return calculateMonthSize(endDate) - calculateMonthSize(initialDate) + 1;
  }

  static String _getQuarter(DateTime date) {
    return "${date.year.toString().substring(2, 4)}'${(date.month + 2) ~/ 3}Q";
  }

  static String _getYear(DateTime date) {
    return "${date.year}년";
  }

  void _dateController(_dateCtrl) async {
    if (_hisProvider.historydata != null) {
      if (_dateCtrl == 1) {
        _historydata = await _hisProvider.historydata.sdbdatas.where((sdbdata) {
          if (_toDay
                  .difference(DateTime.parse(sdbdata.date.substring(0, 10)))
                  .inDays <=
              _toDayKrInt()) {
            return true;
          } else {
            return false;
          }
        }).toList();
      } else if (_dateCtrl == 2) {
        _historydata = await _hisProvider.historydata.sdbdatas.where((sdbdata) {
          if (_toDay
                  .difference(DateTime.parse(sdbdata.date.substring(0, 10)))
                  .inDays <=
              (21 + 1 + _toDayKrInt())) {
            return true;
          } else {
            return false;
          }
        }).toList();
      } else if (_dateCtrl == 3) {
        _historydata = await _hisProvider.historydata.sdbdatas.where((sdbdata) {
          if (getMonthSizeBetweenDates(
                  DateTime.parse(sdbdata.date.substring(0, 10)), _toDay) <=
              6) {
            return true;
          } else {
            return false;
          }
        }).toList();
      } else if (_dateCtrl == 4) {
        _historydata = await _hisProvider.historydata.sdbdatas.where((sdbdata) {
          if (_toDay
                  .difference(DateTime.parse(sdbdata.date.substring(0, 10)))
                  .inDays <=
              365) {
            return true;
          } else {
            return false;
          }
        }).toList();
      } else if (_dateCtrl == 5) {
        _historydata = await _hisProvider.historydata.sdbdatas;
      }
    }
  }

  Widget _homeWidget(_exunique, context) {
    return NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.baseline,
              //     textBaseline: TextBaseline.alphabetic,
              //     children: <Widget>[
              //       Text("SDB ",
              //           style: TextStyle(
              //               color: _mainFontColor,
              //               fontSize: 54,
              //               fontWeight: FontWeight.w600)),
              //       Text(
              //           (_exProvider
              //                       .exercisesdata
              //                       .exercises[(_exProvider
              //                           .exercisesdata.exercises
              //                           .indexWhere((exercise) {
              //                     if (exercise.name == "바벨 스쿼트") {
              //                       return true;
              //                     } else {
              //                       return false;
              //                     }
              //                   }))]
              //                       .onerm +
              //                   _exProvider
              //                       .exercisesdata
              //                       .exercises[(_exProvider
              //                           .exercisesdata.exercises
              //                           .indexWhere((exercise) {
              //                     if (exercise.name == "바벨 데드리프트") {
              //                       return true;
              //                     } else {
              //                       return false;
              //                     }
              //                   }))]
              //                       .onerm +
              //                   _exProvider
              //                       .exercisesdata
              //                       .exercises[(_exProvider
              //                           .exercisesdata.exercises
              //                           .indexWhere((exercise) {
              //                     if (exercise.name == "벤치프레스") {
              //                       return true;
              //                     } else {
              //                       return false;
              //                     }
              //                   }))]
              //                       .onerm)
              //               .floor()
              //               .toString(),
              //           style: TextStyle(
              //               color: _mainFontColor,
              //               fontSize: 46,
              //               fontWeight: FontWeight.w800)),
              //       Text(
              //           "/" +
              //               (_exProvider
              //                           .exercisesdata
              //                           .exercises[(_exProvider
              //                               .exercisesdata.exercises
              //                               .indexWhere((exercise) {
              //                         if (exercise.name == "바벨 스쿼트") {
              //                           return true;
              //                         } else {
              //                           return false;
              //                         }
              //                       }))]
              //                           .goal +
              //                       _exProvider
              //                           .exercisesdata
              //                           .exercises[(_exProvider
              //                               .exercisesdata.exercises
              //                               .indexWhere((exercise) {
              //                         if (exercise.name == "바벨 데드리프트") {
              //                           return true;
              //                         } else {
              //                           return false;
              //                         }
              //                       }))]
              //                           .goal +
              //                       _exProvider
              //                           .exercisesdata
              //                           .exercises[(_exProvider
              //                               .exercisesdata.exercises
              //                               .indexWhere((exercise) {
              //                         if (exercise.name == "벤치프레스") {
              //                           return true;
              //                         } else {
              //                           return false;
              //                         }
              //                       }))]
              //                           .goal)
              //                   .floor()
              //                   .toString() +
              //               "kg",
              //           style: TextStyle(
              //               color: _mainFontColor,
              //               fontSize: 24,
              //               fontWeight: FontWeight.w600)),
              //     ]),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                child: _lastRoutineWidget(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _historyCard(context),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                child: _weightLiftingWidget(context),
              ),
            ],
          ),
        ));
  }

  Widget _lastRoutineWidget() {
    double deviceWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: deviceWidth,
      child: Card(
        color: Theme.of(context).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<PrefsProvider>(builder: (builder, provider, child) {
            return IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                      padding: EdgeInsets.only(right: deviceWidth / 2 - 40),
                      child: Text(
                          provider.prefs.getString('lastroutine') == ''
                              ? "수행 한 루틴이 없어요"
                              : '''최근 진행한 루틴은''',
                          textScaleFactor:
                              provider.prefs.getString('lastroutine') == null
                                  ? 1.0
                                  : 1.4,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: provider.prefs.getString('lastroutine') ==
                                      null
                                  ? Colors.grey
                                  : _mainFontColor,
                              fontWeight: FontWeight.w600)),
                    ),
                    GestureDetector(
                      onTap: () {
                        provider.prefs.getString('lastroutine') == null
                            ? _bodyStater.change(1)
                            : [
                                _PopProvider.gotoonlast(),
                                _bodyStater.change(1)
                              ];
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              provider.prefs.getString('lastroutine') == ''
                                  ? '눌러서 루틴을 수행 해보세요!'
                                  : '${provider.prefs.getString('lastroutine')}',
                              textScaleFactor:
                                  provider.prefs.getString('lastroutine') ==
                                          null
                                      ? 1.3
                                      : 1.7,
                              style: const TextStyle(
                                  color: Color(0xFffc60a8),
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _weightLiftingWidget(context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: deviceWidth,
      child: Card(
        color: Theme.of(context).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<PrefsProvider>(builder: (builder, provider, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Consumer<UserdataProvider>(builder: (builder, provider, child) {
                  return GestureDetector(
                    onTap: () {
                      _displayBodyWeightDialog();
                    },
                    child: SizedBox(
                      width: deviceWidth * 0.3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("몸무게",
                                    textScaleFactor: 1.3,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _mainFontColor,
                                        fontWeight: FontWeight.w600)),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                      "(${DateFormat('MM/dd').format(DateTime.parse(_userProvider.userdata.bodyStats.last.date))})",
                                      textScaleFactor: 0.8,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Color(0xFF717171),
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    _userProvider.userdata.bodyStats.last.weight
                                            .toString() +
                                        _userProvider.userdata.weight_unit,
                                    textScaleFactor: 2.0,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color(0xFffc60a8),
                                        fontWeight: FontWeight.w600)),
                              ]),
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                                "목표 ${_userProvider.userdata.bodyStats.last.weight_goal}" +
                                    _userProvider.userdata.weight_unit,
                                textScaleFactor: 1.2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Color(0xFF717171),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(
                  width: deviceWidth * 0.6,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, top: 4.0),
                              child: Text('''Lifting Stats''',
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                      color: _mainFontColor,
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
                            child: const Icon(Icons.settings,
                                color: Colors.grey, size: 18.0))
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Consumer<ExercisesdataProvider>(
                        builder: (builder, provider, child) {
                      const storage = FlutterSecureStorage();
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
                                value: jsonEncode((_exProvider.homeExList)));
                          },
                          itemBuilder: (BuildContext _context, int index) {
                            return Slidable(
                                key: Key("$index"),
                                endActionPane: ActionPane(
                                    extentRatio: 0.1,
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) {
                                          provider.removeHomeExList(index);
                                          storage.write(
                                              key: 'sdb_HomeExList',
                                              value: jsonEncode(
                                                  (_exProvider.homeExList)));
                                        },
                                        backgroundColor:
                                            const Color(0xFFFE4A49),
                                        foregroundColor: _mainFontColor,
                                        icon: Icons.delete,
                                        padding: EdgeInsets.zero,
                                      )
                                    ]),
                                child:
                                    _homeProgressiveBarChart(index, context));
                          },
                          shrinkWrap: true,
                          itemCount: _exProvider.homeExList.length);
                    }),
                  ]),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _historyCard(context) {
    var _page = 11;
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
              controller: _historyCardcontroller,
              onPageChanged: (int index) =>
                  setState(() => _historyCardIndexCtrl = index),
              itemBuilder: (_, i) {
                return Transform.scale(
                  scale: i == _historyCardIndexCtrl ? 1.03 : 0.97,
                  child: _historyCardCase(i, _page, context),
                );
              }),
        ),
        _dateControllerWidget(),
        const SizedBox(height: 6.0),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SmoothPageIndicator(
            controller: _historyCardcontroller,
            count: _page,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              type: WormType.thin,
              activeDotColor: Theme.of(context).primaryColor,
              dotColor: Colors.grey,
              // strokeWidth: 5,
            ),
          ),
        )
      ],
    );
  }

  Widget _historyCardCase(_historyCardIndexCtrl, length, context) {
    var _realIndex = _historyCardIndexCtrl % length;
    switch (_realIndex) {
      case 0:
        _isbottomTitleEx = false;
        return _countHistoryNoWidget(context, _realIndex);
      case 1:
        _isbottomTitleEx = false;
        return _countHistoryDateWidget(context, _realIndex);
      case 2:
        _isbottomTitleEx = false;
        return _countHistorySetWidget(context, _realIndex);
      case 3:
        _isbottomTitleEx = false;
        return _countHistoryWeightWidget(context, _realIndex);
      case 4:
        _isbottomTitleEx = false;
        return _countHistoryTimeWidget(context, _realIndex);
      case 5:
        _isbottomTitleEx = true;
        return _countHistoryExBestWidget(context, _realIndex);
      case 6:
        _isbottomTitleEx = true;
        return _countHistoryExSetsWidget(context, _realIndex);
      case 7:
        _isbottomTitleEx = true;
        return _countHistoryExWeightWidget(context, _realIndex);
      case 8:
        _isbottomTitleEx = true;
        return _countHistoryPartCountWidget(context, _realIndex);
      case 9:
        _isbottomTitleEx = true;
        return _countHistoryPartSetWidget(context, _realIndex);
      case 10:
        _isbottomTitleEx = true;
        return _countHistoryPartWeightWidget(context, _realIndex);

      default:
        _isbottomTitleEx = false;
        return _countHistoryNoWidget(context, 0);
    }
  }

  String _dateStringCase(_dateCtrl) {
    switch (_dateCtrl) {
      case 1:
        return "이번주 동안";
      case 2:
        return "1개월 동안";
      case 3:
        return "6개월 동안";
      case 4:
        return "1년 동안";
      default:
        return "우리 함께 총";
    }
  }

  SideTitles _bottomTitles() {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta) {
        String text = '';
        switch (_dateCtrl) {
          case 1:
            switch (value.toInt()) {
              case 0:
                text = "월";
                break;
              case 1:
                text = "화";
                break;
              case 2:
                text = "수";
                break;
              case 3:
                text = "목";
                break;
              case 4:
                text = "금";
                break;
              case 5:
                text = "토";
                break;
              case 6:
                text = "일";
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));
          case 2:
            switch (value.toInt()) {
              case 0:
                text = "3주전";
                break;
              case 1:
                text = "2주전";
                break;
              case 2:
                text = "지난주";
                break;
              case 3:
                text = "이번주";
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));
          case 3:
            switch (value.toInt()) {
              case 0:
                text = _toDay.month - 5 > 0
                    ? "${_toDay.month - 5}월"
                    : "${_toDay.month - 5 + 12}월";
                break;
              case 1:
                text = _toDay.month - 4 > 0
                    ? "${_toDay.month - 4}월"
                    : "${_toDay.month - 4 + 12}월";
                break;
              case 2:
                text = _toDay.month - 3 > 0
                    ? "${_toDay.month - 3}월"
                    : "${_toDay.month - 3 + 12}월";
                break;
              case 3:
                text = _toDay.month - 2 > 0
                    ? "${_toDay.month - 2}월"
                    : "${_toDay.month - 2 + 12}월";
                break;
              case 4:
                text = _toDay.month - 1 > 0
                    ? "${_toDay.month - 1}월"
                    : "${_toDay.month - 1 + 12}월";
                break;
              case 5:
                text = "${_toDay.month}월";
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));
          case 4:
            switch (value.toInt()) {
              case 0:
                text = _getQuarter(
                    DateTime(_toDay.year, _toDay.month - 9, _toDay.day));
                break;
              case 1:
                text = _getQuarter(
                    DateTime(_toDay.year, _toDay.month - 6, _toDay.day));
                break;
              case 2:
                text = _getQuarter(
                    DateTime(_toDay.year, _toDay.month - 3, _toDay.day));
                break;
              case 3:
                text = _getQuarter(
                    DateTime(_toDay.year, _toDay.month, _toDay.day));
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));
          case 5:
            switch (value.toInt()) {
              case 0:
                text =
                    "${DateFormat('yyyy').format(DateTime(_toDay.year, _toDay.month, _toDay.day))}년";
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));

          default:
            switch (value.toInt()) {
              case 0:
                text = DateFormat('MM/dd')
                    .format(_toDay.subtract(Duration(days: value.toInt())));
                break;
              case 1:
                text = DateFormat('MM/dd')
                    .format(_toDay.subtract(Duration(days: value.toInt())));
                break;
              case 2:
                text = DateFormat('MM/dd')
                    .format(_toDay.subtract(Duration(days: value.toInt())));
                break;
              case 3:
                text = DateFormat('MM/dd')
                    .format(_toDay.subtract(Duration(days: value.toInt())));
                break;
              case 4:
                text = DateFormat('MM/dd')
                    .format(_toDay.subtract(Duration(days: value.toInt())));
                break;
              case 5:
                text = DateFormat('MM/dd')
                    .format(_toDay.subtract(Duration(days: value.toInt())));
                break;
              case 6:
                text = DateFormat('MM/dd')
                    .format(_toDay.subtract(Duration(days: value.toInt())));
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));
        }
      },
    );
  }

  SideTitles _bottomExTitles(_realIndex) {
    if (_realIndex == 5 || _realIndex == 8) {
      return SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            String text = '';
            switch (value.toInt()) {
              case 0:
                text = _exerciseCountMap.keys.elementAt(3 - value.toInt());
                break;
              case 1:
                text = _exerciseCountMap.keys.elementAt(3 - value.toInt());
                break;
              case 2:
                text = _exerciseCountMap.keys.elementAt(3 - value.toInt());
                break;
              case 3:
                text = _exerciseCountMap.keys.elementAt(3 - value.toInt());
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));
          });
    } else if (_realIndex == 6 || _realIndex == 9) {
      return SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            String text = '';
            switch (value.toInt()) {
              case 0:
                text = _exerciseCountMapOdd.keys.elementAt(3 - value.toInt());
                break;
              case 1:
                text = _exerciseCountMapOdd.keys.elementAt(3 - value.toInt());
                break;
              case 2:
                text = _exerciseCountMapOdd.keys.elementAt(3 - value.toInt());
                break;
              case 3:
                text = _exerciseCountMapOdd.keys.elementAt(3 - value.toInt());
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));
          });
    } else if (_realIndex == 7 || _realIndex == 10) {
      return SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            String text = '';
            switch (value.toInt()) {
              case 0:
                text = _exerciseCountMapThird.keys.elementAt(3 - value.toInt());
                break;
              case 1:
                text = _exerciseCountMapThird.keys.elementAt(3 - value.toInt());
                break;
              case 2:
                text = _exerciseCountMapThird.keys.elementAt(3 - value.toInt());
                break;
              case 3:
                text = _exerciseCountMapThird.keys.elementAt(3 - value.toInt());
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));
          });
    } else {
      return SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            String text = '';
            switch (value.toInt()) {
              case 0:
                text = _exerciseCountMapThird.keys.elementAt(3 - value.toInt());
                break;
              case 1:
                text = _exerciseCountMapThird.keys.elementAt(3 - value.toInt());
                break;
              case 2:
                text = _exerciseCountMapThird.keys.elementAt(3 - value.toInt());
                break;
              case 3:
                text = _exerciseCountMapThird.keys.elementAt(3 - value.toInt());
                break;
            }
            return Text(text,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.grey));
          });
    }
  }

  Widget _countHistoryNoWidget(context, _realIndex) {
    var _historyDate = [];
    List<double> _chartData = [];
    var _chartDataBest;
    List<BarChartGroupData> _barChartGroupData = [];

    _dateController(_dateCtrl);
    if (_historydata != null) {
      for (var sdbdata in _historydata) {
        _historyDate.add(sdbdata);
      }
    }

    switch (_dateCtrl) {
      case 1:
        for (int i = 0; i < 7; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if (sdbdata.date.substring(0, 10) ==
                DateFormat('yyyy-MM-dd').format(
                    _toDay.subtract(Duration(days: _toDayKrInt() - i)))) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 7; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 2:
        for (int i = 0; i < 4; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if (DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(
                            DateTime.parse(sdbdata.date.substring(0, 10)))
                        .inDays >
                    -7 &&
                DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(
                            DateTime.parse(sdbdata.date.substring(0, 10)))
                        .inDays <=
                    0) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 3:
        for (int i = 0; i < 6; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if ((getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.date.substring(0, 10)),
                        _toDay) <=
                    6 - i) &&
                (getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.date.substring(0, 10)), _toDay) >
                    (5 - i))) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 6; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 4:
        for (int i = 0; i < 4; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if (_getQuarter(DateTime(
                    _toDay.year, _toDay.month - (3) * (3 - i), _toDay.day)) ==
                _getQuarter(DateTime.parse(sdbdata.date.substring(0, 10)))) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 5:
        for (int i = 0; i < 1; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if (_getYear(DateTime(_toDay.year, _toDay.month, _toDay.day)) ==
                _getYear(DateTime.parse(sdbdata.date.substring(0, 10)))) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 1; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(
        context,
        _dateStringCase(_dateCtrl),
        "${_historyDate.length}회",
        " 운동했어요!",
        2,
        40,
        _realIndex,
        _barChartGroupData);
  }

  Widget _countHistoryDateWidget(context, _realIndex) {
    var _historyDate = <DuplicateHistoryDate>{};
    List<BarChartGroupData> _barChartGroupData = [];
    _dateController(_dateCtrl);
    List<double> _chartData = [];
    var _chartDataBest;
    if (_historydata != null) {
      for (var sdbdata in _historydata) {
        _historyDate.add(DuplicateHistoryDate(sdbdata));
      }
    }

    switch (_dateCtrl) {
      case 1:
        for (int i = 0; i < 7; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if (sdbdata.sdbdata.date!.substring(0, 10) ==
                DateFormat('yyyy-MM-dd').format(
                    _toDay.subtract(Duration(days: _toDayKrInt() - i)))) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 7; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 2:
        for (int i = 0; i < 4; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if (DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(DateTime.parse(
                            sdbdata.sdbdata.date!.substring(0, 10)))
                        .inDays >
                    -7 &&
                DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(DateTime.parse(
                            sdbdata.sdbdata.date!.substring(0, 10)))
                        .inDays <=
                    0) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 3:
        for (int i = 0; i < 6; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if ((getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.sdbdata.date!.substring(0, 10)),
                        _toDay) <=
                    6 - i) &&
                (getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.sdbdata.date!.substring(0, 10)),
                        _toDay) >
                    (5 - i))) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 6; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 4:
        for (int i = 0; i < 4; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if (_getQuarter(DateTime(
                    _toDay.year, _toDay.month - (3) * (3 - i), _toDay.day)) ==
                _getQuarter(
                    DateTime.parse(sdbdata.sdbdata.date!.substring(0, 10)))) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 5:
        for (int i = 0; i < 1; i++) {
          int _value = 0;
          for (var sdbdata in _historyDate) {
            if (_getYear(DateTime(_toDay.year, _toDay.month, _toDay.day)) ==
                _getYear(
                    DateTime.parse(sdbdata.sdbdata.date!.substring(0, 10)))) {
              _value++;
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 1; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(
        context,
        _dateStringCase(_dateCtrl),
        "${_historyDate.length}일",
        " 운동했어요!",
        2,
        40,
        _realIndex,
        _barChartGroupData);
  }

  Widget _countHistorySetWidget(context, _realIndex) {
    List<BarChartGroupData> _barChartGroupData = [];
    _dateController(_dateCtrl);
    List<double> _chartData = [];
    var _chartDataBest;
    var _historySet = 0;
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        for (Exercises exercises in sdbdata.exercises) {
          // ignore: unused_local_variable
          for (workoutModel.Sets sets in exercises.sets) {
            _historySet++;
          }
        }
      }
    }
    switch (_dateCtrl) {
      case 1:
        for (int i = 0; i < 7; i++) {
          var _historySet = 0;
          for (SDBdata sdbdata in _historydata) {
            if (sdbdata.date!.substring(0, 10) ==
                DateFormat('yyyy-MM-dd').format(
                    _toDay.subtract(Duration(days: _toDayKrInt() - i)))) {
              for (Exercises exercises in sdbdata.exercises) {
                // ignore: unused_local_variable
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _chartData.add(_historySet.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 7; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 2:
        for (int i = 0; i < 4; i++) {
          var _historySet = 0;
          for (SDBdata sdbdata in _historydata) {
            if (DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(
                            DateTime.parse(sdbdata.date!.substring(0, 10)))
                        .inDays >
                    -7 &&
                DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(
                            DateTime.parse(sdbdata.date!.substring(0, 10)))
                        .inDays <=
                    0) {
              for (Exercises exercises in sdbdata.exercises) {
                // ignore: unused_local_variable
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _chartData.add(_historySet.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 3:
        for (int i = 0; i < 6; i++) {
          var _historySet = 0;
          for (var sdbdata in _historydata) {
            if ((getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.date!.substring(0, 10)),
                        _toDay) <=
                    6 - i) &&
                (getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.date!.substring(0, 10)),
                        _toDay) >
                    (5 - i))) {
              for (Exercises exercises in sdbdata.exercises) {
                // ignore: unused_local_variable
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _chartData.add(_historySet.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 6; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 4:
        for (int i = 0; i < 4; i++) {
          var _historySet = 0;
          for (var sdbdata in _historydata) {
            if (_getQuarter(DateTime(
                    _toDay.year, _toDay.month - (3) * (3 - i), _toDay.day)) ==
                _getQuarter(DateTime.parse(sdbdata.date!.substring(0, 10)))) {
              for (Exercises exercises in sdbdata.exercises) {
                // ignore: unused_local_variable
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _chartData.add(_historySet.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 5:
        for (int i = 0; i < 1; i++) {
          var _historySet = 0;
          for (var sdbdata in _historydata) {
            if (_getYear(DateTime(_toDay.year, _toDay.month, _toDay.day)) ==
                _getYear(DateTime.parse(sdbdata.date!.substring(0, 10)))) {
              for (Exercises exercises in sdbdata.exercises) {
                // ignore: unused_local_variable
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _chartData.add(_historySet.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 1; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(context, _dateStringCase(_dateCtrl),
        "$_historySet세트", " 수행했어요!", 2, 40, _realIndex, _barChartGroupData);
  }

  Widget _countHistoryWeightWidget(context, _realIndex) {
    var _historyWeight = 0;
    List<BarChartGroupData> _barChartGroupData = [];
    List<double> _chartData = [];
    var _chartDataBest;
    _dateController(_dateCtrl);
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        for (Exercises exercise in sdbdata.exercises) {
          for (workoutModel.Sets sets in exercise.sets) {
            _historyWeight = _historyWeight + (sets.weight * sets.reps).toInt();
          }
        }
      }
    }
    switch (_dateCtrl) {
      case 1:
        for (int i = 0; i < 7; i++) {
          var _historyWeight = 0;
          for (SDBdata sdbdata in _historydata) {
            if (sdbdata.date!.substring(0, 10) ==
                DateFormat('yyyy-MM-dd').format(
                    _toDay.subtract(Duration(days: _toDayKrInt() - i)))) {
              for (Exercises exercises in sdbdata.exercises) {
                for (workoutModel.Sets sets in exercises.sets) {
                  _historyWeight =
                      _historyWeight + (sets.weight * sets.reps).toInt();
                }
              }
            }
          }
          _chartData.add(_historyWeight.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 7; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 2:
        for (int i = 0; i < 4; i++) {
          var _historyWeight = 0;
          for (SDBdata sdbdata in _historydata) {
            if (DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(
                            DateTime.parse(sdbdata.date!.substring(0, 10)))
                        .inDays >
                    -7 &&
                DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(
                            DateTime.parse(sdbdata.date!.substring(0, 10)))
                        .inDays <=
                    0) {
              for (Exercises exercises in sdbdata.exercises) {
                for (workoutModel.Sets sets in exercises.sets) {
                  _historyWeight =
                      _historyWeight + (sets.weight * sets.reps).toInt();
                }
              }
            }
          }
          _chartData.add(_historyWeight.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 3:
        for (int i = 0; i < 6; i++) {
          var _historyWeight = 0;
          for (var sdbdata in _historydata) {
            if ((getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.date!.substring(0, 10)),
                        _toDay) <=
                    6 - i) &&
                (getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.date!.substring(0, 10)),
                        _toDay) >
                    (5 - i))) {
              for (Exercises exercises in sdbdata.exercises) {
                for (workoutModel.Sets sets in exercises.sets) {
                  _historyWeight =
                      _historyWeight + (sets.weight * sets.reps).toInt();
                }
              }
            }
          }
          _chartData.add(_historyWeight.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 6; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 4:
        for (int i = 0; i < 4; i++) {
          var _historyWeight = 0;
          for (var sdbdata in _historydata) {
            if (_getQuarter(DateTime(
                    _toDay.year, _toDay.month - (3) * (3 - i), _toDay.day)) ==
                _getQuarter(DateTime.parse(sdbdata.date!.substring(0, 10)))) {
              for (Exercises exercises in sdbdata.exercises) {
                for (workoutModel.Sets sets in exercises.sets) {
                  _historyWeight =
                      _historyWeight + (sets.weight * sets.reps).toInt();
                }
              }
            }
          }
          _chartData.add(_historyWeight.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 5:
        for (int i = 0; i < 1; i++) {
          var _historyWeight = 0;
          for (var sdbdata in _historydata) {
            if (_getYear(DateTime(_toDay.year, _toDay.month, _toDay.day)) ==
                _getYear(DateTime.parse(sdbdata.date!.substring(0, 10)))) {
              for (Exercises exercises in sdbdata.exercises) {
                for (workoutModel.Sets sets in exercises.sets) {
                  _historyWeight =
                      _historyWeight + (sets.weight * sets.reps).toInt();
                }
              }
            }
          }
          _chartData.add(_historyWeight.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 1; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(
        context,
        _dateStringCase(_dateCtrl),
        _historyWeight.toString() + _userProvider.userdata.weight_unit,
        " 들었어요!",
        2,
        40,
        _realIndex,
        _barChartGroupData);
  }

  Widget _countHistoryTimeWidget(context, _realIndex) {
    var _historyTime = 0;
    List<BarChartGroupData> _barChartGroupData = [];
    List<double> _chartData = [];
    var _chartDataBest;
    _dateController(_dateCtrl);
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        _historyTime = _historyTime + (sdbdata.workout_time / 60).toInt();
      }
    }
    switch (_dateCtrl) {
      case 1:
        for (int i = 0; i < 7; i++) {
          var _value = 0;
          for (SDBdata sdbdata in _historydata) {
            if (sdbdata.date!.substring(0, 10) ==
                DateFormat('yyyy-MM-dd').format(
                    _toDay.subtract(Duration(days: _toDayKrInt() - i)))) {
              _value = _value + (sdbdata.workout_time / 60).toInt();
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 7; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 2:
        for (int i = 0; i < 4; i++) {
          int _value = 0;
          for (SDBdata sdbdata in _historydata) {
            if (DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(
                            DateTime.parse(sdbdata.date!.substring(0, 10)))
                        .inDays >
                    -7 &&
                DateTime(_toDay.year, _toDay.month,
                            _toDay.day - (3 - i).toInt() * 7 - _toDayKrInt())
                        .difference(
                            DateTime.parse(sdbdata.date!.substring(0, 10)))
                        .inDays <=
                    0) {
              _value = _value + (sdbdata.workout_time / 60).toInt();
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 3:
        for (int i = 0; i < 6; i++) {
          int _value = 0;
          for (SDBdata sdbdata in _historydata) {
            if ((getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.date!.substring(0, 10)),
                        _toDay) <=
                    6 - i) &&
                (getMonthSizeBetweenDates(
                        DateTime.parse(sdbdata.date!.substring(0, 10)),
                        _toDay) >
                    (5 - i))) {
              _value = _value + (sdbdata.workout_time / 60).toInt();
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 6; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 4:
        for (int i = 0; i < 4; i++) {
          int _value = 0;
          for (SDBdata sdbdata in _historydata) {
            if (_getQuarter(DateTime(
                    _toDay.year, _toDay.month - (3) * (3 - i), _toDay.day)) ==
                _getQuarter(DateTime.parse(sdbdata.date!.substring(0, 10)))) {
              _value = _value + (sdbdata.workout_time / 60).toInt();
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 4; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
      case 5:
        for (int i = 0; i < 1; i++) {
          int _value = 0;
          for (SDBdata sdbdata in _historydata) {
            if (_getYear(DateTime(_toDay.year, _toDay.month, _toDay.day)) ==
                _getYear(DateTime.parse(sdbdata.date!.substring(0, 10)))) {
              _value = _value + (sdbdata.workout_time / 60).toInt();
            }
          }
          _chartData.add(_value.toDouble());
        }
        _chartDataBest = _chartData.reduce(max);
        for (int i = 0; i < 1; i++) {
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _chartData[i].toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  backDrawRodData: BackgroundBarChartRodData(
                      show: _chartData[i] != 0 ? false : true,
                      toY: _chartDataBest == 0 ? 1 : _chartDataBest,
                      color: Theme.of(context).cardColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _chartData[i] != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(context, _dateStringCase(_dateCtrl),
        "$_historyTime분", "운동했어요!", 2, 40, _realIndex, _barChartGroupData);
  }

  Widget _countHistoryExBestWidget(context, _realIndex) {
    List<BarChartGroupData> _barChartGroupData = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMap = {
      "바벨 스쿼트": 0,
      "바벨 데드리프트": 0,
      "바벨 벤치 프레스": 0,
      "밀리터리 프레스": 0
    };

    _dateController(_dateCtrl);
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        for (Exercises exercise in sdbdata.exercises) {
          if (_exerciseCountMap.containsKey(exercise.name)) {
            _exerciseCountMap[exercise.name] =
                _exerciseCountMap[exercise.name]! + 1;
          } else {
            _exerciseCountMap[exercise.name] = 1;
          }
        }
      }
    }
    _exerciseCountMap = Map.fromEntries(_exerciseCountMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value)));

    _exerciseCountMap.forEach((key, value) {
      if (value > thevalue) {
        thevalue = value;
        thekey = key;
      }
    });

    for (int i = 0; i < 4; i++) {
      _barChartGroupData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              toY: _exerciseCountMap.values.elementAt(3 - i).toDouble(),
              width: 12,
              gradient: _barsGradient,
              backDrawRodData: BackgroundBarChartRodData(
                  show: _exerciseCountMap.values.elementAt(3 - i) != 0
                      ? false
                      : true,
                  toY: _exerciseCountMap.values.elementAt(0) == 0
                      ? 1
                      : _exerciseCountMap.values.elementAt(0).toDouble(),
                  color: Theme.of(context).cardColor),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)))
        ],
        showingTooltipIndicators:
            _exerciseCountMap.values.elementAt(3 - i) != 0 ? [0] : [],
      ));
    }

    return _countHistoryCardCore(
        context,
        "${_dateStringCase(_dateCtrl)} 많이 한 운동은?",
        "$thekey!",
        "",
        9999,
        0,
        _realIndex,
        _barChartGroupData);
  }

  Widget _countHistoryExSetsWidget(context, _realIndex) {
    List<BarChartGroupData> _barChartGroupData = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMapOdd = {
      "바벨 스쿼트": 0,
      "바벨 데드리프트": 0,
      "바벨 벤치 프레스": 0,
      "밀리터리 프레스": 0
    };

    _dateController(_dateCtrl);
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        for (Exercises exercise in sdbdata.exercises) {
          if (_exerciseCountMapOdd.containsKey(exercise.name)) {
            // ignore: unused_local_variable
            for (workoutModel.Sets sets in exercise.sets) {
              _exerciseCountMapOdd[exercise.name] =
                  _exerciseCountMapOdd[exercise.name]! + 1;
            }
          } else {
            _exerciseCountMapOdd[exercise.name] = 0;
            // ignore: unused_local_variable
            for (workoutModel.Sets sets in exercise.sets) {
              _exerciseCountMapOdd[exercise.name] =
                  _exerciseCountMapOdd[exercise.name]! + 1;
            }
          }
        }
      }
    }
    _exerciseCountMapOdd = Map.fromEntries(_exerciseCountMapOdd.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value)));

    _exerciseCountMapOdd.forEach((key, value) {
      if (value > thevalue) {
        thevalue = value;
        thekey = key;
      }
    });

    for (int i = 0; i < 4; i++) {
      _barChartGroupData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              toY: _exerciseCountMapOdd.values.elementAt(3 - i).toDouble(),
              width: 12,
              gradient: _barsGradient,
              backDrawRodData: BackgroundBarChartRodData(
                  show: _exerciseCountMapOdd.values.elementAt(3 - i) != 0
                      ? false
                      : true,
                  toY: _exerciseCountMapOdd.values.elementAt(0) == 0
                      ? 1
                      : _exerciseCountMapOdd.values.elementAt(0).toDouble(),
                  color: Theme.of(context).cardColor),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)))
        ],
        showingTooltipIndicators:
            _exerciseCountMapOdd.values.elementAt(3 - i) != 0 ? [0] : [],
      ));
    }

    return _countHistoryCardCore(
        context,
        "${_dateStringCase(_dateCtrl)} 많은 세트 한 운동은?",
        "$thekey!",
        "",
        9999,
        0,
        _realIndex,
        _barChartGroupData);
  }

  Widget _countHistoryExWeightWidget(context, _realIndex) {
    List<BarChartGroupData> _barChartGroupData = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMapThird = {
      "바벨 스쿼트": 0,
      "바벨 데드리프트": 0,
      "바벨 벤치 프레스": 0,
      "밀리터리 프레스": 0
    };

    _dateController(_dateCtrl);
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        for (Exercises exercise in sdbdata.exercises) {
          if (_exerciseCountMapThird.containsKey(exercise.name)) {
            for (workoutModel.Sets sets in exercise.sets) {
              _exerciseCountMapThird[exercise.name] =
                  _exerciseCountMapThird[exercise.name]! +
                      (sets.weight * sets.reps).toInt();
            }
          } else {
            _exerciseCountMapThird[exercise.name] = 0;
            for (workoutModel.Sets sets in exercise.sets) {
              _exerciseCountMapThird[exercise.name] =
                  _exerciseCountMapThird[exercise.name]! +
                      (sets.weight * sets.reps).toInt();
            }
          }
        }
      }
    }
    _exerciseCountMapThird = Map.fromEntries(
        _exerciseCountMapThird.entries.toList()
          ..sort((e1, e2) => e2.value.compareTo(e1.value)));

    _exerciseCountMapThird.forEach((key, value) {
      if (value > thevalue) {
        thevalue = value;
        thekey = key;
      }
    });

    for (int i = 0; i < 4; i++) {
      _barChartGroupData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              toY: _exerciseCountMapThird.values.elementAt(3 - i).toDouble(),
              width: 12,
              backDrawRodData: BackgroundBarChartRodData(
                  show: _exerciseCountMapThird.values.elementAt(3 - i) != 0
                      ? false
                      : true,
                  toY: _exerciseCountMapThird.values.elementAt(0) == 0
                      ? 1
                      : _exerciseCountMapThird.values.elementAt(0).toDouble(),
                  color: Theme.of(context).cardColor),
              gradient: _barsGradient,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)))
        ],
        showingTooltipIndicators:
            _exerciseCountMapThird.values.elementAt(3 - i) != 0 ? [0] : [],
      ));
    }

    return _countHistoryCardCore(
        context,
        "${_dateStringCase(_dateCtrl)} 많은 무게를 든 운동은?",
        "$thekey!",
        "",
        9999,
        0,
        _realIndex,
        _barChartGroupData);
  }

  Widget _countHistoryPartWeightWidget(context, _realIndex) {
    List<BarChartGroupData> _barChartGroupData = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMapThird = {"가슴": 0, "등": 0, "다리": 0, "어깨": 0};

    _dateController(_dateCtrl);
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        for (Exercises exercise in sdbdata.exercises) {
          for (String target in _exProvider
              .exercisesdata
              .exercises[_exProvider.exercisesdata.exercises.indexWhere((ex) {
            if (ex.name == exercise.name) {
              return true;
            } else {
              return false;
            }
          })]
              .target) {
            if (_exerciseCountMapThird.containsKey(target)) {
              for (workoutModel.Sets sets in exercise.sets) {
                _exerciseCountMapThird[target] =
                    _exerciseCountMapThird[target]! +
                        (sets.weight * sets.reps).toInt();
              }
            } else {
              _exerciseCountMapThird[target] = 0;
              for (workoutModel.Sets sets in exercise.sets) {
                _exerciseCountMapThird[target] =
                    _exerciseCountMapThird[target]! +
                        (sets.weight * sets.reps).toInt();
              }
            }
          }
        }
      }
    }
    _exerciseCountMapThird = Map.fromEntries(
        _exerciseCountMapThird.entries.toList()
          ..sort((e1, e2) => e2.value.compareTo(e1.value)));

    _exerciseCountMapThird.forEach((key, value) {
      if (value > thevalue) {
        thevalue = value;
        thekey = key;
      }
    });

    for (int i = 0; i < 4; i++) {
      _barChartGroupData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              toY: _exerciseCountMapThird.values.elementAt(3 - i).toDouble(),
              width: 12,
              backDrawRodData: BackgroundBarChartRodData(
                  show: _exerciseCountMapThird.values.elementAt(3 - i) != 0
                      ? false
                      : true,
                  toY: _exerciseCountMapThird.values.elementAt(0) == 0
                      ? 1
                      : _exerciseCountMapThird.values.elementAt(0).toDouble(),
                  color: Theme.of(context).cardColor),
              gradient: _barsGradient,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)))
        ],
        showingTooltipIndicators:
            _exerciseCountMapThird.values.elementAt(3 - i) != 0 ? [0] : [],
      ));
    }

    return _countHistoryCardCore(
        context,
        "${_dateStringCase(_dateCtrl)} 많은 무게를 든 부위는?",
        "$thekey!",
        "",
        9999,
        0,
        _realIndex,
        _barChartGroupData);
  }

  Widget _countHistoryPartSetWidget(context, _realIndex) {
    List<BarChartGroupData> _barChartGroupData = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMapOdd = {"가슴": 0, "등": 0, "다리": 0, "어깨": 0};

    _dateController(_dateCtrl);
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        for (Exercises exercise in sdbdata.exercises) {
          for (String target in _exProvider
              .exercisesdata
              .exercises[_exProvider.exercisesdata.exercises.indexWhere((ex) {
            if (ex.name == exercise.name) {
              return true;
            } else {
              return false;
            }
          })]
              .target) {
            if (_exerciseCountMapOdd.containsKey(target)) {
              // ignore: unused_local_variable
              for (workoutModel.Sets sets in exercise.sets) {
                _exerciseCountMapOdd[target] =
                    _exerciseCountMapOdd[target]! + 1;
              }
            } else {
              _exerciseCountMapOdd[target] = 0;
              // ignore: unused_local_variable
              for (workoutModel.Sets sets in exercise.sets) {
                _exerciseCountMapOdd[target] =
                    _exerciseCountMapOdd[target]! + 1;
              }
            }
          }
        }
      }
    }
    _exerciseCountMapOdd = Map.fromEntries(_exerciseCountMapOdd.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value)));

    _exerciseCountMapOdd.forEach((key, value) {
      if (value > thevalue) {
        thevalue = value;
        thekey = key;
      }
    });

    for (int i = 0; i < 4; i++) {
      _barChartGroupData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              toY: _exerciseCountMapOdd.values.elementAt(3 - i).toDouble(),
              width: 12,
              backDrawRodData: BackgroundBarChartRodData(
                  show: _exerciseCountMapOdd.values.elementAt(3 - i) != 0
                      ? false
                      : true,
                  toY: _exerciseCountMapOdd.values.elementAt(0) == 0
                      ? 1
                      : _exerciseCountMapOdd.values.elementAt(0).toDouble(),
                  color: Theme.of(context).cardColor),
              gradient: _barsGradient,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)))
        ],
        showingTooltipIndicators:
            _exerciseCountMapOdd.values.elementAt(3 - i) != 0 ? [0] : [],
      ));
    }

    return _countHistoryCardCore(
        context,
        "${_dateStringCase(_dateCtrl)} 많은 세트를 한 부위는?",
        "$thekey!",
        "",
        9999,
        0,
        _realIndex,
        _barChartGroupData);
  }

  Widget _countHistoryPartCountWidget(context, _realIndex) {
    List<BarChartGroupData> _barChartGroupData = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMap = {"가슴": 0, "등": 0, "다리": 0, "어깨": 0};

    _dateController(_dateCtrl);
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        for (Exercises exercise in sdbdata.exercises) {
          for (String target in _exProvider
              .exercisesdata
              .exercises[_exProvider.exercisesdata.exercises.indexWhere((ex) {
            if (ex.name == exercise.name) {
              return true;
            } else {
              return false;
            }
          })]
              .target) {
            if (_exerciseCountMap.containsKey(target)) {
              _exerciseCountMap[target] = _exerciseCountMap[target]! + 1;
            } else {
              _exerciseCountMap[target] = 0;
              _exerciseCountMap[target] = _exerciseCountMap[target]! + 1;
            }
          }
        }
      }
    }
    _exerciseCountMap = Map.fromEntries(_exerciseCountMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value)));

    _exerciseCountMap.forEach((key, value) {
      if (value > thevalue) {
        thevalue = value;
        thekey = key;
      }
    });

    for (int i = 0; i < 4; i++) {
      _barChartGroupData.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              toY: _exerciseCountMap.values.elementAt(3 - i).toDouble(),
              width: 12,
              backDrawRodData: BackgroundBarChartRodData(
                  show: _exerciseCountMap.values.elementAt(3 - i) != 0
                      ? false
                      : true,
                  toY: _exerciseCountMap.values.elementAt(0) == 0
                      ? 1
                      : _exerciseCountMap.values.elementAt(0).toDouble(),
                  color: Theme.of(context).cardColor),
              gradient: _barsGradient,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)))
        ],
        showingTooltipIndicators:
            _exerciseCountMap.values.elementAt(3 - i) != 0 ? [0] : [],
      ));
    }

    return _countHistoryCardCore(
        context,
        "${_dateStringCase(_dateCtrl)} 많은 횟수를 한 부위는?",
        "$thekey!",
        "",
        9999,
        0,
        _realIndex,
        _barChartGroupData);
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              TextStyle(
                color: _mainFontColor,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget _countHistoryCardCore(
      context,
      _historyDateCore,
      _historyTextCore,
      _histroySideText,
      int _devicePaddingWidth,
      int _devicePaddingWidthAdd,
      int _realIndex,
      List<BarChartGroupData> _barChartGroupData) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
          color: Theme.of(context).canvasColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: deviceWidth / _devicePaddingWidth -
                                _devicePaddingWidthAdd),
                        child: Text(_historyDateCore,
                            textScaleFactor: 1.5,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _mainFontColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
              Consumer<HistorydataProvider>(
                  builder: (builder, provider, child) {
                _dateController(_dateCtrl);
                return Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_historyTextCore,
                          textScaleFactor: 2.0,
                          style: const TextStyle(
                              color: Color(0xFffc60a8),
                              fontWeight: FontWeight.w600)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(_histroySideText,
                            textScaleFactor: 1.4,
                            style: TextStyle(
                                color: _mainFontColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 40),
              // ignore: unnecessary_null_comparison
              _barChartGroupData != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                              height: 110,
                              child: BarChart(BarChartData(
                                barGroups: _barChartGroupData,
                                barTouchData: barTouchData,
                                titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                        sideTitles: _isbottomTitleEx
                                            ? _bottomExTitles(_realIndex)
                                            : _bottomTitles())),
                                alignment: BarChartAlignment.spaceAround,
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: false),
                              ))),
                        ),
                      ],
                    )
                  : Container()
            ]),
          )),
    );
  }

  void exselect(bool isadd, bool isex, context, [int where = 0]) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 2,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
            textScaleFactor: 2.0,
            style:
                TextStyle(color: _mainFontColor, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: TextField(
              style: TextStyle(color: _mainFontColor),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: _mainFontColor,
                ),
                hintText: "Exercise Name",
                hintStyle: TextStyle(fontSize: 20.0, color: _mainFontColor),
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
    final suggestions = _exProvider.exercisesdata.exercises.where((exercise) {
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
      child: Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
        return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
              const storage = FlutterSecureStorage();
              return GestureDetector(
                onTap: () {
                  _exProvider.addHomeExList(exuniq[index].name);
                  storage.write(
                      key: 'sdb_HomeExList',
                      value: jsonEncode((_exProvider.homeExList)));
                  Navigator.of(context).pop();
                },
                child: Container(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              textScaleFactor: 1.7,
                              style: TextStyle(color: _mainFontColor),
                            ),
                            Text(
                                "1RM: ${exuniq[index].onerm.toStringAsFixed(1)}/${exuniq[index].goal.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                                textScaleFactor: 1.1,
                                style:
                                    const TextStyle(color: Color(0xFF717171))),
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
                color: const Color(0xFF212121),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 1,
                  color: const Color(0xFF717171),
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
    return _exProvider.homeExList.length > index
        ? Padding(
            key: Key('$index'),
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: GestureDetector(
              onTap: () => {
                _chartIndex.change(
                    _exProvider.exercisesdata.exercises.indexWhere((exercise) {
                  if (exercise.name == _exProvider.homeExList[index]) {
                    return true;
                  } else {
                    return false;
                  }
                })),
                _chartIndex.changePageController(0),
                _staticPageState.change(true),
                _bodyStater.change(3),
              },
              child: Row(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 3 - 10,
                      child: Text(_exProvider.homeExList[index],
                          textScaleFactor: 1.0,
                          style: TextStyle(
                              color: _mainFontColor,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center)),
                  Expanded(
                    child: SizedBox(height: 16, child: Container()),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  void _displayBodyWeightDialog() {
    _userWeightController = TextEditingController(
        text: _userProvider.userdata.bodyStats.last.weight.toString());
    _userWeightGoalController = TextEditingController(
        text: _userProvider.userdata.bodyStats.last.weight_goal.toString());
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            buttonPadding: const EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.all(12.0),
            title: Text(
              '몸무게를 기록 할게요',
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: _mainFontColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('몸무게와 목표치를 바꿔보세요',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                TextField(
                  controller: _userWeightController,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                    fontSize: 21,
                    color: _mainFontColor,
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
                      labelText: "몸무게",
                      labelStyle:
                          const TextStyle(fontSize: 16.0, color: Colors.grey),
                      hintText: "몸무게",
                      hintStyle:
                          TextStyle(fontSize: 24.0, color: _mainFontColor)),
                  onChanged: (text) {},
                ),
                TextField(
                  controller: _userWeightGoalController,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                    fontSize: 21,
                    color: _mainFontColor,
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
                      labelText: "목표 몸무게",
                      labelStyle:
                          const TextStyle(fontSize: 16.0, color: Colors.grey),
                      hintText: "목표 몸무게",
                      hintStyle:
                          TextStyle(fontSize: 24.0, color: _mainFontColor)),
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
                      color: _mainFontColor,
                    ),
                    disabledForegroundColor:
                        const Color.fromRGBO(246, 58, 64, 20),
                    padding: const EdgeInsets.all(12.0),
                  ),
                  child: Text('오늘 몸무게 기록하기',
                      textScaleFactor: 1.7,
                      style: TextStyle(color: _mainFontColor)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    _displayBodyWeightPushDialog(
                        double.parse(_userWeightController.text),
                        double.parse(_userWeightGoalController.text));
                    _userProvider.setUserWeightAdd(
                        _toDay.toString(),
                        double.parse(_userWeightController.text),
                        double.parse(_userWeightGoalController.text));
                  },
                ),
              ),
            ],
          );
        });
  }

  void _displayBodyWeightPushDialog(_userWeight, _userGoal) {
    var _weightChange = "";
    var _weightSuccess = "";
    if ((_userWeight - _userProvider.userdata.bodyStats.last.weight) > 0) {
      _weightChange =
          "${"+" + (_userWeight - _userProvider.userdata.bodyStats.last.weight).toStringAsFixed(1)}kg 증가했어요";
      if (_userProvider.userdata.bodyStats.last.weight >
          _userProvider.userdata.bodyStats.last.weight_goal) {
        _weightSuccess = "감량에 분발이 필요해요";
      } else if (_userProvider.userdata.bodyStats.last.weight <
          _userProvider.userdata.bodyStats.last.weight_goal) {
        _weightSuccess = "증량이 성공중 이에요";
      } else if (_userProvider.userdata.bodyStats.last.weight ==
          _userProvider.userdata.bodyStats.last.weight_goal) {
        _weightSuccess = "현재 몸무게를 유지해주세요";
      }
    } else if ((_userWeight - _userProvider.userdata.bodyStats.last.weight) <
        0) {
      _weightChange =
          "${"" + (_userWeight - _userProvider.userdata.bodyStats.last.weight).toStringAsFixed(1)}kg 감소했어요";
      if (_userProvider.userdata.bodyStats.last.weight >
          _userProvider.userdata.bodyStats.last.weight_goal) {
        _weightSuccess = "감량에 성공중 이에요";
      } else if (_userProvider.userdata.bodyStats.last.weight <
          _userProvider.userdata.bodyStats.last.weight_goal) {
        _weightSuccess = "증량에 분발이 필요해요";
      } else if (_userProvider.userdata.bodyStats.last.weight ==
          _userProvider.userdata.bodyStats.last.weight_goal) {
        _weightSuccess = "현재 몸무게를 유지해주세요";
      }
    } else {
      _weightChange = "몸무게가 유지 되었어요";
      if (_userProvider.userdata.bodyStats.last.weight >
          _userProvider.userdata.bodyStats.last.weight_goal) {
        _weightSuccess = "감량에 분발이 필요해요";
      } else if (_userProvider.userdata.bodyStats.last.weight <
          _userProvider.userdata.bodyStats.last.weight_goal) {
        _weightSuccess = "증량에 분발이 필요해요";
      } else if (_userProvider.userdata.bodyStats.last.weight ==
          _userProvider.userdata.bodyStats.last.weight_goal) {
        _weightSuccess = "현재 몸무게를 유지해주세요";
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            buttonPadding: const EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.all(12.0),
            title: Text(
              _weightChange,
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: _mainFontColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_weightSuccess,
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
                _chartWidget(context),
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
                      color: _mainFontColor,
                    ),
                    disabledForegroundColor:
                        const Color.fromRGBO(246, 58, 64, 20),
                    padding: const EdgeInsets.all(12.0),
                  ),
                  child: Text('닫기',
                      textScaleFactor: 1.7,
                      style: TextStyle(color: _mainFontColor)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ),
            ],
          );
        });
  }

  Widget _chartWidget(context) {
    final List<Color> color = <Color>[];
    color.add(const Color(0xFffc60a8).withOpacity(0.7));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(const Color(0xFffc60a8).withOpacity(0.7));

    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.4);
    stops.add(0.6);
    stops.add(1.0);

    double deviceWidth = MediaQuery.of(context).size.width;

    return (Center(
      child: SizedBox(
          width: deviceWidth * 2 / 3,
          height: 200,
          child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: DateTimeAxis(
                majorGridLines: const MajorGridLines(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  majorGridLines: const MajorGridLines(width: 0),
                  minimum: _userProvider.userdata.bodyStats!.length == 0
                      ? 0
                      : _userProvider.userdata.bodyStats!.length > 1
                          ? _userProvider.userdata.bodyStats!
                              .reduce((BodyStat curr, BodyStat next) =>
                                  curr.weight! < next.weight! ? curr : next)
                              .weight
                          : _userProvider.userdata.bodyStats![0].weight),
              tooltipBehavior: _tooltipBehavior,
              zoomPanBehavior: _zoomPanBehavior,
              legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  textStyle: TextStyle(color: _mainFontColor)),
              series: [
                LineSeries<BodyStat, DateTime>(
                  isVisibleInLegend: true,
                  color: _mainFontColor,
                  name: "목표",
                  dataSource: _userProvider.userdata.bodyStats!,
                  xValueMapper: (BodyStat sales, _) =>
                      DateTime.parse(sales.date!),
                  yValueMapper: (BodyStat sales, _) => sales.weight_goal!,
                ),
                // Renders line chart
                LineSeries<BodyStat, DateTime>(
                  isVisibleInLegend: true,
                  onCreateShader: (ShaderDetails details) {
                    return ui.Gradient.linear(details.rect.topRight,
                        details.rect.bottomLeft, color, stops);
                  },
                  markerSettings: MarkerSettings(
                      isVisible: true,
                      height: 6,
                      width: 6,
                      borderWidth: 3,
                      color: Theme.of(context).primaryColor,
                      borderColor: Theme.of(context).primaryColor),
                  name: "몸무게",
                  color: Theme.of(context).primaryColor,
                  width: 5,
                  dataSource: _userProvider.userdata.bodyStats!,
                  xValueMapper: (BodyStat sales, _) =>
                      DateTime.parse(sales.date!),
                  yValueMapper: (BodyStat sales, _) => sales.weight!,
                ),
              ])),
    ));
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
                                textScaleFactor: 1.3,
                                style: TextStyle(
                                    color: _mainFontColor,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                "${_exunique.exercises[index].onerm.floor()}/${_exunique.exercises[index].goal.floor()}",
                                textScaleFactor: 1.3,
                                style: TextStyle(
                                    color: _mainFontColor,
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
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void onDeactivate() {
    super.deactivate();
    _timer?.cancel();
  }

  @override
  void deactivate() {
    print('deactivate');
    _timer?.cancel();
    super.deactivate();
  }
}
