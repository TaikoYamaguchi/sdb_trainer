import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/src/model/historydata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart' as workoutModel;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:transition/transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _exercisesdataProvider;
  var _PopProvider;
  var _userdataProvider;
  var _bodyStater;
  var _staticPageState;
  var _chartIndex;
  var _historydataProvider;
  var _testdata0;
  var allEntries;
  var _historydata;
  int _historyCardIndexCtrl = 4242;
  var _dateCtrl = 1;
  var _barsGradient;
  final _historyCardcontroller =
      PageController(viewportFraction: 0.9, initialPage: 4242, keepPage: true);
  var _prefs;
  String _addexinput = '';
  late var _testdata = _testdata0.exercises;
  var _timer;
  late List<BarChartGroupData> _cardCoreBarChartGroupData;
  var _isbottomTitleEx = false;
  Map<String, int> _exerciseCountMap = {
    "스쿼트": 0,
    "데드리프트": 0,
    "벤치프레스": 0,
    "밀리터리프레스": 0
  };

  DateTime _toDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 30)).then((value) {
      _timer = Timer.periodic(Duration(seconds: 30), (Timer timer) {
        _historyCardIndexCtrl++;

        _historyCardcontroller.animateToPage(
          _historyCardIndexCtrl,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      });
    });
  }

  PreferredSizeWidget _appbarWidget() {
    //if (_userdataProvider.userdata != null) {
    return AppBar(
      title: Consumer<UserdataProvider>(builder: (builder, provider, child) {
        if (provider.userdata != null) {
          return Text(
            provider.userdata.nickname + "님 반가워요",
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
      backgroundColor: Colors.black,
    );
  }

  Widget _dateControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        color: Colors.black,
        child: CupertinoSlidingSegmentedControl(
            groupValue: _dateCtrl,
            children: <int, Widget>{
              1: Padding(
                child: Text("1주",
                    style: TextStyle(
                        color: _dateCtrl == 1 ? Colors.white : Colors.grey,
                        fontSize: 14)),
                padding: const EdgeInsets.all(4.0),
              ),
              2: Padding(
                  child: Text("1달",
                      style: TextStyle(
                          color: _dateCtrl == 2 ? Colors.white : Colors.grey,
                          fontSize: 14)),
                  padding: const EdgeInsets.all(4.0)),
              3: Padding(
                  child: Text("6달",
                      style: TextStyle(
                          color: _dateCtrl == 3 ? Colors.white : Colors.grey,
                          fontSize: 14)),
                  padding: const EdgeInsets.all(4.0)),
              4: Padding(
                  child: Text("1년",
                      style: TextStyle(
                          color: _dateCtrl == 4 ? Colors.white : Colors.grey,
                          fontSize: 14)),
                  padding: const EdgeInsets.all(4.0)),
              5: Padding(
                  child: Text("모두",
                      style: TextStyle(
                          color: _dateCtrl == 5 ? Colors.white : Colors.grey,
                          fontSize: 14)),
                  padding: const EdgeInsets.all(4.0))
            },
            padding: EdgeInsets.symmetric(horizontal: 6),
            backgroundColor: Colors.black,
            thumbColor: Theme.of(context).primaryColor,
            onValueChanged: (i) {
              setState(() {
                _dateCtrl = i as int;
                _dateController(_dateCtrl);
              });
            }),
      ),
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

  int _toMonthInt() {
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
    return date.year.toString().substring(2, 4) +
        "'" +
        ((date.month + 2) / 3).toInt().toString() +
        "Q";
  }

  static String _getYear(DateTime date) {
    return date.year.toString() + "년";
  }

  void _dateController(_dateCtrl) async {
    DateTime _fourWeekDay = DateTime(
        _toDay.year, _toDay.month, _toDay.day - (21 + 1 + _toDayKrInt()));

    if (_historydataProvider.historydata != null) {
      if (_dateCtrl == 1) {
        _historydata =
            await _historydataProvider.historydata.sdbdatas.where((sdbdata) {
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
        _historydata =
            await _historydataProvider.historydata.sdbdatas.where((sdbdata) {
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
        _historydata =
            await _historydataProvider.historydata.sdbdatas.where((sdbdata) {
          if (getMonthSizeBetweenDates(
                  DateTime.parse(sdbdata.date.substring(0, 10)), _toDay) <=
              6) {
            return true;
          } else {
            return false;
          }
        }).toList();
      } else if (_dateCtrl == 4) {
        _historydata =
            await _historydataProvider.historydata.sdbdatas.where((sdbdata) {
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
        _historydata = await _historydataProvider.historydata.sdbdatas;
      }
    }
  }

  Widget _homeWidget(_exunique, context) {
    return Container(
      color: Colors.black,
      child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 1.0),
                  child: _lastRoutineWidget(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 1.0),
                  child: _liftingStatWidget(_exunique, context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _dateControllerWidget(),
                      SizedBox(height: 2.0),
                      _historyCard(context),
                    ],
                  ),
                ),
              ],
            ),
          )),
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
          child: Consumer<PrefsProvider>(builder: (builder, provider, child) {
            return Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: deviceWidth / 2 - 40),
                      child: Text(
                          provider.prefs.getString('lastroutine') == ''
                              ? "최근 루틴이 없어요"
                              : '''최근 수행한 루틴은''',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: provider.prefs.getString('lastroutine') ==
                                      null
                                  ? Colors.grey
                                  : Colors.white,
                              fontSize:
                                  provider.prefs.getString('lastroutine') ==
                                          null
                                      ? 18
                                      : 20,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  provider.prefs.getString('lastroutine') == null
                      ? _bodyStater.change(1)
                      : [_PopProvider.gotoonlast(), _bodyStater.change(1)];
                },
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          provider.prefs.getString('lastroutine') == ''
                              ? '눌러서 루틴을 수행 해보세요!'
                              : '${provider.prefs.getString('lastroutine')}',
                          style: TextStyle(
                              color: Color(0xFffc60a8),
                              fontSize:
                                  provider.prefs.getString('lastroutine') == ''
                                      ? 18
                                      : 28,
                              fontWeight: FontWeight.w600)),
                      provider.prefs.getString('lastroutine') == ''
                          ? Container()
                          : Text('에요',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
              ),
            ]);
          }),
        ));
  }

  Widget _historyCard(context) {
    var _page = 6;
    return Column(
      children: [
        SizedBox(
          height: 270,
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
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SmoothPageIndicator(
            controller: _historyCardcontroller,
            count: _page,
            effect: WormEffect(
              dotHeight: 12,
              dotWidth: 12,
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
        return _countHistoryNoWidget(context);
      case 1:
        _isbottomTitleEx = false;
        return _countHistoryDateWidget(context);
      case 2:
        _isbottomTitleEx = false;
        return _countHistorySetWidget(context);
      case 3:
        _isbottomTitleEx = false;
        return _countHistoryWeightWidget(context);
      case 4:
        _isbottomTitleEx = false;
        return _countHistoryTimeWidget(context);
      case 5:
        _countHistoryBestCore(context);
        _isbottomTitleEx = true;
        return _countHistoryBestWidget(context);
      default:
        _isbottomTitleEx = false;
        return _countHistoryNoWidget(context);
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
                style: TextStyle(fontSize: 12, color: Colors.white));
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
                style: TextStyle(fontSize: 12, color: Colors.white));
          case 3:
            switch (value.toInt()) {
              case 0:
                text = _toDay.month - 5 > 0
                    ? (_toDay.month - 5).toString() + "월"
                    : (_toDay.month - 5 + 12).toString() + "월";
                break;
              case 1:
                text = _toDay.month - 4 > 0
                    ? (_toDay.month - 4).toString() + "월"
                    : (_toDay.month - 4 + 12).toString() + "월";
                break;
              case 2:
                text = _toDay.month - 3 > 0
                    ? (_toDay.month - 3).toString() + "월"
                    : (_toDay.month - 3 + 12).toString() + "월";
                break;
              case 3:
                text = _toDay.month - 2 > 0
                    ? (_toDay.month - 2).toString() + "월"
                    : (_toDay.month - 2 + 12).toString() + "월";
                break;
              case 4:
                text = _toDay.month - 1 > 0
                    ? (_toDay.month - 1).toString() + "월"
                    : (_toDay.month - 1 + 12).toString() + "월";
                break;
              case 5:
                text = _toDay.month.toString() + "월";
                break;
            }
            return Text(text,
                style: TextStyle(fontSize: 12, color: Colors.white));
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
                style: TextStyle(fontSize: 12, color: Colors.white));
          case 5:
            switch (value.toInt()) {
              case 0:
                text = DateFormat('yyyy').format(
                        DateTime(_toDay.year, _toDay.month, _toDay.day)) +
                    "년";
                break;
            }
            return Text(text,
                style: TextStyle(fontSize: 12, color: Colors.white));

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
                style: TextStyle(fontSize: 12, color: Colors.white));
        }
      },
    );
  }

  SideTitles _bottomExTitles() {
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
              style: TextStyle(fontSize: 12, color: Colors.white));
        });
  }

  Widget _countHistoryNoWidget(context) {
    var _historyDate = [];
    List<BarChartGroupData> _barChartGroupData = [];

    _dateController(_dateCtrl);
    if (_historydata != null) {
      double deviceWidth = MediaQuery.of(context).size.width;
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(
        context,
        _dateStringCase(_dateCtrl),
        _historyDate.length.toString() + "회",
        " 운동했어요!",
        2,
        40,
        _barChartGroupData);
  }

  Widget _countHistoryDateWidget(context) {
    var _historyDate = <DuplicateHistoryDate>{};
    List<BarChartGroupData> _barChartGroupData = [];
    _dateController(_dateCtrl);
    double deviceWidth = MediaQuery.of(context).size.width;
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(
        context,
        _dateStringCase(_dateCtrl),
        _historyDate.length.toString() + "일",
        " 운동했어요!",
        2,
        40,
        _barChartGroupData);
  }

  Widget _countHistorySetWidget(context) {
    List<BarChartGroupData> _barChartGroupData = [];
    _dateController(_dateCtrl);
    var _historySet = 0;
    double deviceWidth = MediaQuery.of(context).size.width;
    if (_historydata != null) {
      for (SDBdata sdbdata in _historydata) {
        for (Exercises exercises in sdbdata.exercises) {
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
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historySet.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historySet != 0 ? [0] : [],
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
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historySet.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historySet != 0 ? [0] : [],
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
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historySet.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historySet != 0 ? [0] : [],
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
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historySet.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historySet != 0 ? [0] : [],
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
                for (workoutModel.Sets sets in exercises.sets) {
                  _historySet++;
                }
              }
            }
          }
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historySet.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historySet != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(context, _dateStringCase(_dateCtrl),
        _historySet.toString() + "세트", " 수행했어요!", 2, 40, _barChartGroupData);
  }

  Widget _countHistoryWeightWidget(context) {
    var _historyWeight = 0;
    List<BarChartGroupData> _barChartGroupData = [];
    _dateController(_dateCtrl);
    double deviceWidth = MediaQuery.of(context).size.width;
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historyWeight.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historyWeight != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historyWeight.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historyWeight != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historyWeight.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historyWeight != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historyWeight.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historyWeight != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _historyWeight.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _historyWeight != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(
        context,
        _dateStringCase(_dateCtrl),
        _historyWeight.toString() + _userdataProvider.userdata.weight_unit,
        " 들었어요!",
        2,
        40,
        _barChartGroupData);
  }

  Widget _countHistoryTimeWidget(context) {
    var _historyTime = 0;
    List<BarChartGroupData> _barChartGroupData = [];
    _dateController(_dateCtrl);
    double deviceWidth = MediaQuery.of(context).size.width;
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
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
          _barChartGroupData.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: _value.toDouble(),
                  width: 12,
                  gradient: _barsGradient,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)))
            ],
            showingTooltipIndicators: _value != 0 ? [0] : [],
          ));
        }
        break;
    }

    return _countHistoryCardCore(context, _dateStringCase(_dateCtrl),
        _historyTime.toString() + "분", "운동했어요!", 2, 40, _barChartGroupData);
  }

  Widget _countHistoryBestWidget(context) {
    List<BarChartGroupData> _barChartGroupData = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMap = {"스쿼트": 0, "데드리프트": 0, "벤치프레스": 0, "밀리터리프레스": 0};

    _dateController(_dateCtrl);
    double deviceWidth = MediaQuery.of(context).size.width;
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
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)))
        ],
        showingTooltipIndicators:
            _exerciseCountMap.values.elementAt(3 - i) != 0 ? [0] : [],
      ));
    }

    return _countHistoryCardCore(
        context,
        _dateStringCase(_dateCtrl) + " 많이 한 운동은?",
        thekey.toString() + "!",
        "",
        9999,
        0,
        _barChartGroupData);
  }

  void _countHistoryBestCore(context) async {}

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
              const TextStyle(
                color: Colors.white,
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
      List<BarChartGroupData> _barChartGroupData) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Card(
        color: Theme.of(context).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
            Consumer<HistorydataProvider>(builder: (builder, provider, child) {
              _dateController(_dateCtrl);
              return Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_historyTextCore,
                        style: TextStyle(
                            color: Color(0xFffc60a8),
                            fontSize: 28,
                            fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(_histroySideText,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 50),
            _barChartGroupData != null
                ? AspectRatio(
                    aspectRatio: 3,
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
                                  ? _bottomExTitles()
                                  : _bottomTitles())),
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    )))
                : Container()
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
                    child: Icon(Icons.settings, color: Colors.grey, size: 18.0))
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
                _chartIndex.change(_exercisesdataProvider
                    .exercisesdata.exercises
                    .indexWhere((exercise) {
                  if (exercise.name ==
                      _exercisesdataProvider.homeExList[index]) {
                    return true;
                  } else {
                    return false;
                  }
                })),
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
    _historydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _staticPageState = Provider.of<StaticPageProvider>(context, listen: false);
    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);
    _testdata0 = Provider.of<ExercisesdataProvider>(context, listen: false)
        .exercisesdata;
    _barsGradient = LinearGradient(
      colors: [
        Color(0xFffc60a8),
        Theme.of(context).primaryColor,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

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

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
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
