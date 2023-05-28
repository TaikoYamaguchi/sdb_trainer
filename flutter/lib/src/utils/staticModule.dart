import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/model/historydata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart' as workoutModel;
import 'package:sdb_trainer/src/utils/indicator.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class StaticModule extends StatefulWidget {
  StaticModule({Key? key}) : super(key: key);

  @override
  State<StaticModule> createState() => _StaticModuleState();
}

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}

class _StaticModuleState extends State<StaticModule> {
  int _historyCardIndexCtrl = 4242;
  int _historyPieCardIndexCtrl = 4242;
  var _dateCtrl = 1;
  final _historyCardcontroller =
      PageController(viewportFraction: 0.9, initialPage: 4242, keepPage: true);
  final _historyPieCardcontroller =
      PageController(viewportFraction: 0.9, initialPage: 4242, keepPage: true);
  var _isbottomTitleEx = false;
  var _mainFontColor;
  var _hisProvider;
  var _userProvider;
  var _exProvider;
  DateTime _toDay = DateTime.now();
  var _historydata;
  var _barsGradient;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _mainFontColor = Theme.of(context).primaryColorLight;
    _barsGradient = LinearGradient(
      colors: [
        const Color(0xFffc60a8),
        Theme.of(context).primaryColor,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    return Consumer<HistorydataProvider>(builder: (builder, provider, child) {
      _dateController(1);
      return _historyCard(context);
    });
  }

  Widget _historyCard(context) {
    var _cardPage = 8;
    var _cardPiePage = 3;
    return Expanded(
      child: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.min,
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
                    child: _historyCardCase(i, _cardPage, context),
                  );
                }),
          ),
          _dateControllerWidget(),
          const SizedBox(height: 6.0),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: SmoothPageIndicator(
              controller: _historyCardcontroller,
              count: _cardPage,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                type: WormType.thin,
                activeDotColor: Theme.of(context).primaryColor,
                dotColor: Colors.grey,
                // strokeWidth: 5,
              ),
            ),
          ),
          SizedBox(
            height: 340,
            child: PageView.builder(
                controller: _historyPieCardcontroller,
                onPageChanged: (int index) =>
                    setState(() => _historyPieCardIndexCtrl = index),
                itemBuilder: (_, i) {
                  return Transform.scale(
                    scale: i == _historyPieCardIndexCtrl ? 1.03 : 0.97,
                    child: _historyPieCard(i, _cardPiePage, context),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: SmoothPageIndicator(
              controller: _historyPieCardcontroller,
              count: _cardPiePage,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                type: WormType.thin,
                activeDotColor: Theme.of(context).primaryColor,
                dotColor: Colors.grey,
                // strokeWidth: 5,
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _dateControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        child: CupertinoSlidingSegmentedControl(
            groupValue: _dateCtrl,
            children: <int, Widget>{
              1: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("1주",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: _dateCtrl == 1
                          ? Theme.of(context).highlightColor
                          : Colors.grey,
                    )),
              ),
              2: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("1달",
                      textScaleFactor: 1.1,
                      style: TextStyle(
                        color: _dateCtrl == 2
                            ? Theme.of(context).highlightColor
                            : Colors.grey,
                      ))),
              3: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("6달",
                      textScaleFactor: 1.1,
                      style: TextStyle(
                        color: _dateCtrl == 3
                            ? Theme.of(context).highlightColor
                            : Colors.grey,
                      ))),
              4: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("1년",
                      textScaleFactor: 1.1,
                      style: TextStyle(
                        color: _dateCtrl == 4
                            ? Theme.of(context).highlightColor
                            : Colors.grey,
                      ))),
              5: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("모두",
                      textScaleFactor: 1.1,
                      style: TextStyle(
                        color: _dateCtrl == 5
                            ? Theme.of(context).highlightColor
                            : Colors.grey,
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
      ),
    );
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
    return date.year.toString().substring(2, 4) +
        "'" +
        ((date.month + 2) / 3).toInt().toString() +
        "Q";
  }

  static String _getYear(DateTime date) {
    return date.year.toString() + "년";
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

      default:
        _isbottomTitleEx = false;
        return _countHistoryNoWidget(context, 0);
    }
  }

  Widget _historyPieCard(_historyCardIndexCtrl, length, context) {
    var _realIndex = _historyCardIndexCtrl % length;
    switch (_realIndex) {
      case 0:
        _isbottomTitleEx = false;
        return _partPieChartWidget(context, 0);
      case 1:
        _isbottomTitleEx = false;
        return _partPieChartSetWidget(context, 0);

      case 2:
        _isbottomTitleEx = false;
        return _partPieChartWeightWidget(context, 0);
      default:
        _isbottomTitleEx = false;
        return _partPieChartWidget(context, 0);
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
                text = DateFormat('yyyy').format(
                        DateTime(_toDay.year, _toDay.month, _toDay.day)) +
                    "년";
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
        _historyDate.length.toString() + "회",
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
        _historyDate.length.toString() + "일",
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

    return _countHistoryCardCore(
        context,
        _dateStringCase(_dateCtrl),
        _historySet.toString() + "세트",
        " 수행했어요!",
        2,
        40,
        _realIndex,
        _barChartGroupData);
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

    return _countHistoryCardCore(
        context,
        _dateStringCase(_dateCtrl),
        _historyTime.toString() + "분",
        "운동했어요!",
        2,
        40,
        _realIndex,
        _barChartGroupData);
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
        _dateStringCase(_dateCtrl) + " 많이 한 운동은?",
        thekey.toString() + "!",
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
        _dateStringCase(_dateCtrl) + " 많은 세트 한 운동은?",
        thekey.toString() + "!",
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
        _dateStringCase(_dateCtrl) + " 많은 무게를 든 운동은?",
        thekey.toString() + "!",
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
        _dateStringCase(_dateCtrl) + " 많은 무게를 든 부위는?",
        thekey.toString() + "!",
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
        _dateStringCase(_dateCtrl) + " 많은 세트를 한 부위는?",
        thekey.toString() + "!",
        "",
        9999,
        0,
        _realIndex,
        _barChartGroupData);
  }

  Widget _partPieChartWeightWidget(context, _realIndex) {
    List<PieChartSectionData> _pieDataSets = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMapThird = {"가슴": 0, "등": 0, "다리": 0, "어깨": 0};
    var _pieColor = [
      AppColors.contentColorBlue,
      AppColors.contentColorYellow,
      AppColors.contentColorOrange,
      AppColors.contentColorGreen,
      AppColors.contentColorPurple,
      AppColors.contentColorPink,
      AppColors.contentColorRed,
      AppColors.contentColorCyan
    ];

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
          ..sort((e1, e2) => e1.value.compareTo(e2.value)));

    _exerciseCountMapThird.forEach((key, value) {
      if (value > thevalue) {
        thevalue = value;
        thekey = key;
      }
    });

    for (int i = 0; i < _exerciseCountMapThird.length; i++) {
      _pieDataSets.add(
        PieChartSectionData(
            color: _pieColor[i],
            value: _exerciseCountMapThird.values
                .elementAt(_exerciseCountMapThird.length - 1 - i)
                .toDouble(),
            title: _exerciseCountMapThird.keys
                .elementAt(_exerciseCountMapThird.length - 1 - i)),
      );
    }

    return _historyCardPieChart(
        context,
        _dateStringCase(_dateCtrl) + " 많은 무게를 든 부위는?",
        thekey.toString() + "!",
        "",
        9999,
        0,
        _realIndex,
        _pieDataSets);
  }

  Widget _partPieChartSetWidget(context, _realIndex) {
    List<PieChartSectionData> _pieDataSets = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMapOdd = {"가슴": 0, "등": 0, "다리": 0, "어깨": 0};
    var _pieColor = [
      AppColors.contentColorBlue,
      AppColors.contentColorYellow,
      AppColors.contentColorOrange,
      AppColors.contentColorGreen,
      AppColors.contentColorPurple,
      AppColors.contentColorPink,
      AppColors.contentColorRed,
      AppColors.contentColorCyan
    ];

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
      ..sort((e1, e2) => e1.value.compareTo(e2.value)));

    _exerciseCountMapOdd.forEach((key, value) {
      if (value > thevalue) {
        thevalue = value;
        thekey = key;
      }
    });

    for (int i = 0; i < _exerciseCountMapOdd.length; i++) {
      _pieDataSets.add(
        PieChartSectionData(
            color: _pieColor[i],
            value: _exerciseCountMapOdd.values
                .elementAt(_exerciseCountMapOdd.length - 1 - i)
                .toDouble(),
            title: _exerciseCountMapOdd.keys
                .elementAt(_exerciseCountMapOdd.length - 1 - i)),
      );
    }

    return _historyCardPieChart(
        context,
        _dateStringCase(_dateCtrl) + " 많은 세트를 한 부위는?",
        thekey.toString() + "!",
        "",
        9999,
        0,
        _realIndex,
        _pieDataSets);
  }

  Widget _partPieChartWidget(context, _realIndex) {
    List<PieChartSectionData> _pieDataSets = [];
    var thevalue = 0;
    var thekey = "운동을 시작해봐요";
    _isbottomTitleEx = true;
    _exerciseCountMap = {"가슴": 0, "등": 0, "다리": 0, "어깨": 0};
    var _pieColor = [
      AppColors.contentColorBlue,
      AppColors.contentColorYellow,
      AppColors.contentColorOrange,
      AppColors.contentColorGreen,
      AppColors.contentColorPurple,
      AppColors.contentColorPink,
      AppColors.contentColorRed,
      AppColors.contentColorCyan
    ];

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
      ..sort((e1, e2) => e1.value.compareTo(e2.value)));

    _exerciseCountMap.forEach((key, value) {
      if (value > thevalue) {
        thevalue = value;
        thekey = key;
      }
    });

    for (int i = 0; i < _exerciseCountMap.length; i++) {
      _pieDataSets.add(
        PieChartSectionData(
            color: _pieColor[i],
            value: _exerciseCountMap.values
                .elementAt(_exerciseCountMap.length - 1 - i)
                .toDouble(),
            title: _exerciseCountMap.keys
                .elementAt(_exerciseCountMap.length - 1 - i)),
      );
    }

    return _historyCardPieChart(
        context,
        _dateStringCase(_dateCtrl) + " 많은 횟수를 한 부위는?",
        thekey.toString() + "!",
        "",
        9999,
        0,
        _realIndex,
        _pieDataSets);
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
        _dateStringCase(_dateCtrl) + " 많은 횟수를 한 부위는?",
        thekey.toString() + "!",
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

  PieTouchData get pieTouchData => PieTouchData(
        touchCallback: (FlTouchEvent event, pieTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) {
              return;
            }
          });
        },
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
                          child: Container(
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

  Widget _historyCardPieChart(
      context,
      _historyDateCore,
      _historyTextCore,
      _histroySideText,
      int _devicePaddingWidth,
      int _devicePaddingWidthAdd,
      int _realIndex,
      List<PieChartSectionData> _pieDataSets) {
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
              _pieDataSets != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                              height: 170,
                              child: PieChart(PieChartData(
                                sections: _pieDataSets,
                                pieTouchData: pieTouchData,
                                borderData: FlBorderData(show: false),
                              ))),
                        ),
                        Container(
                            width: 100,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _pieDataSets.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(children: [
                                    Indicator(
                                      size: 12,
                                      color: _pieDataSets[index].color,
                                      text: _pieDataSets[index].title +
                                          "(${_pieDataSets[index].value.toInt()})",
                                      isSquare: true,
                                      textColor:
                                          Theme.of(context).primaryColorLight,
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                  ]);
                                }))
                      ],
                    )
                  : Container()
            ]),
          )),
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
