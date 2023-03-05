import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sdb_trainer/pages/static_exercise.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:sdb_trainer/src/utils/staticModule.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transition/transition.dart';
import '../repository/history_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import '../src/model/historydata.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:sdb_trainer/providers/themeMode.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  late Map<DateTime, List<SDBdata>> selectedEvents;
  List<Exercises>? _sdbChartData = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  var _userProvider;
  var _chartIndex;
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  PageController? _isPageController;
  var _tapPosition;
  var _hisProvider;
  var _exProvider;
  var _exSearchCtrlBool = false;
  var _exCalendarSearchCtrlBool = false;
  bool _bodyWeightChartIsOpen = true;
  bool _bodyExChartIsOpen = true;
  final TextEditingController _exSearchCtrl = TextEditingController(text: "");
  final TextEditingController _exCalendarSearchCtrl =
      TextEditingController(text: "");
  var _themeProvider;

  final TextEditingController _eventController = TextEditingController();

  late StreamSubscription<bool> keyboardSubscription;
  late FlutterGifController controller1;

  @override
  void initState() {
    controller1 = FlutterGifController(vsync: this);
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible == false) {
        FocusScope.of(context).unfocus();
      }
    });
    // TODO: implement initState
    _tapPosition = const Offset(0.0, 0.0);
    selectedEvents = {};
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
    super.initState();
  }

  Widget _staticControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<ChartIndexProvider>(builder: (builder, provider, child) {
        var page = provider.isPageController.hasClients
            ? provider.isPageController.page
            : provider.isPageController.initialPage;

        Map<int, Widget> staticList = <int, Widget>{
          /* 0: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("통계",
                textScaleFactor: 1.3,
                style: TextStyle(
                  color:
                      page == 0 ? Theme.of(context).buttonColor : Colors.grey,
                )),
          ),*/
          0: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("달력",
                  textScaleFactor: 1.3,
                  style: TextStyle(
                    color:
                        page == 0 ? Theme.of(context).buttonColor : Colors.grey,
                  ))),
          1: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("몸무게",
                  textScaleFactor: 1.3,
                  style: TextStyle(
                    color:
                        page == 1 ? Theme.of(context).buttonColor : Colors.grey,
                  ))),
        };
        return Container(
          child: CupertinoSlidingSegmentedControl(
              groupValue: page,
              children: staticList,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              thumbColor: Theme.of(context).primaryColor,
              onValueChanged: (i) {
                print(i);
                provider.changePageController(i as int);
              }),
        );
      }),
    );
  }

  initialHistorydataGet() async {
    final initHistorydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    final initExercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);

    initExercisesdataProvider.getdata();
    await initHistorydataProvider.getdata();
  }

  List<SDBdata> _getEventsfromDay(DateTime date) {
    String dateCalendar = DateFormat('yyyy-MM-dd').format(date);
    selectedEvents = {};
    if (_hisProvider.historydata != null && _chartIndex.staticIndex == 0) {
      for (int i = 0; i < _hisProvider.historydata!.sdbdatas.length; i++) {
        if (_hisProvider.historydata!.sdbdatas[i].date!.substring(0, 10) ==
            dateCalendar) {
          if (selectedEvents[date] != null) {
            selectedEvents[date]!.add(_hisProvider.historydata!.sdbdatas[i]);
          } else {
            selectedEvents[date] = [_hisProvider.historydata!.sdbdatas[i]];
          }
        }
      }
    } else if (_hisProvider.historydata != null &&
        _chartIndex.staticIndex != 0) {
      for (int i = 0; i < _hisProvider.historydata!.sdbdatas.length; i++) {
        if (_hisProvider.historydata!.sdbdatas[i].date!.substring(0, 10) ==
            dateCalendar) {
          if (selectedEvents[date] != null) {
            if (_hisProvider.historydata!.sdbdatas[i].exercises
                    .indexWhere((exercise) {
                  if (exercise.name ==
                      _exProvider.exercisesdata!
                          .exercises[_chartIndex.staticIndex - 1].name) {
                    return true;
                  } else {
                    return false;
                  }
                }) !=
                -1) {
              selectedEvents[date]!.add(_hisProvider.historydata!.sdbdatas[i]);
            }
          } else {
            if (_hisProvider.historydata!.sdbdatas[i].exercises
                    .indexWhere((exercise) {
                  if (exercise.name ==
                      _exProvider.exercisesdata!
                          .exercises[_chartIndex.staticIndex - 1].name) {
                    return true;
                  } else {
                    return false;
                  }
                }) !=
                -1) {
              selectedEvents[date] = [_hisProvider.historydata!.sdbdatas[i]];
            }
          }
        }
      }
    }
    return selectedEvents[date] ?? [];
  }

  void _getChartSourcefromDay() async {
    _sdbChartData = [];
    if (_hisProvider.historydata == null) {
      await initialHistorydataGet();
    }
    var sdbChartDataExample = _hisProvider.historydata.sdbdatas
        .map((name) => name.exercises
            .where((name) => name.name ==
                    _exProvider
                        .exercisesdata!.exercises[_chartIndex.chartIndex].name
                ? true
                : false)
            .toList())
        .toList();
    for (int i = 0; i < sdbChartDataExample.length; i++) {
      if (sdbChartDataExample[i].isEmpty) {
        null;
      } else {
        for (int k = 0; k < sdbChartDataExample[i].length; k++) {
          _sdbChartData!.add(sdbChartDataExample[i][k]);
        }
      }
    }
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  Widget _staticsPages() {
    return Consumer2<ChartIndexProvider, StaticPageProvider>(
        builder: (builder, provider1, provider2, child) {
      return Column(
        children: [
          _staticControllerWidget(),
          const SizedBox(height: 10),
          Expanded(
            child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: PageView(
                  controller: provider1.isPageController,
                  children: [
                    //_chartWidget(),
                    _calendarWidget(),
                    _weightWidget()
                  ],
                  onPageChanged: (page) {
                    _chartIndex.changePageController(page);
                  },
                )),
          ),
        ],
      );
    });
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          title: Consumer2<ChartIndexProvider, StaticPageProvider>(
              builder: (builder, provider1, provider2, child) {
            return Row(
              children: [
                Text("기록",
                    textScaleFactor: 1.7,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ],
            );
          }),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _weightWidget() {
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

    final LinearGradient gradientColors = LinearGradient(
        colors: color,
        stops: stops,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);

    return Consumer<UserdataProvider>(builder: (builder, provider, child) {
      return (Column(
        children: [
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
                      _showMyDialog_NewWeight();
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
                              color: Theme.of(context).buttonColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("몸무게를 기록해 보세요",
                                    textScaleFactor: 1.5,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                                const Text("목표치를 기록하고 달성 할 수 있어요",
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
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20))),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24.0, top: 4.0, bottom: 4.0),
                        child: Text("몸무게 차트",
                            textScaleFactor: 1.7,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                      ),
                      SizedBox(
                        width: 100,
                        child: CustomSlidingSegmentedControl(
                            height: 24.0,
                            children: {
                              true: Text("on",
                                  style: TextStyle(
                                      color: _bodyWeightChartIsOpen
                                          ? Theme.of(context).buttonColor
                                          : Theme.of(context)
                                              .primaryColorLight)),
                              false: Text("off",
                                  style: TextStyle(
                                      color: _bodyWeightChartIsOpen
                                          ? Theme.of(context).primaryColorLight
                                          : Theme.of(context).buttonColor))
                            },
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            innerPadding: const EdgeInsets.all(4),
                            thumbDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).primaryColor),
                            onValueChanged: (bool value) {
                              setState(() {
                                _bodyWeightChartIsOpen = value;
                              });
                            }),
                      )
                    ],
                  ),
                  _bodyWeightChartIsOpen
                      ? Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20))),
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
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  minimum: _userProvider
                                              .userdata.bodyStats!.length ==
                                          0
                                      ? 0
                                      : _userProvider.userdata.bodyStats!.length >
                                              1
                                          ? _userProvider.userdata.bodyStats!
                                              .reduce((BodyStat curr,
                                                      BodyStat next) =>
                                                  curr.weight! < next.weight!
                                                      ? curr
                                                      : next)
                                              .weight
                                          : _userProvider
                                              .userdata.bodyStats![0].weight),
                              tooltipBehavior: _tooltipBehavior,
                              zoomPanBehavior: _zoomPanBehavior,
                              legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom,
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColorLight)),
                              series: [
                                LineSeries<BodyStat, DateTime>(
                                  isVisibleInLegend: true,
                                  color: Theme.of(context).primaryColorLight,
                                  name: "목표",
                                  dataSource: _userProvider.userdata.bodyStats!,
                                  xValueMapper: (BodyStat sales, _) =>
                                      DateTime.parse(sales.date!),
                                  yValueMapper: (BodyStat sales, _) =>
                                      sales.weight_goal!,
                                ),
                                // Renders line chart
                                LineSeries<BodyStat, DateTime>(
                                  isVisibleInLegend: true,
                                  onCreateShader: (ShaderDetails details) {
                                    return ui.Gradient.linear(
                                        details.rect.topRight,
                                        details.rect.bottomLeft,
                                        color,
                                        stops);
                                  },
                                  markerSettings: MarkerSettings(
                                      isVisible: true,
                                      height: 6,
                                      width: 6,
                                      borderWidth: 3,
                                      color: Theme.of(context).primaryColor,
                                      borderColor:
                                          Theme.of(context).primaryColor),
                                  name: "몸무게",
                                  color: Theme.of(context).primaryColor,
                                  width: 5,
                                  dataSource: _userProvider.userdata.bodyStats!,
                                  xValueMapper: (BodyStat sales, _) =>
                                      DateTime.parse(sales.date!),
                                  yValueMapper: (BodyStat sales, _) =>
                                      sales.weight!,
                                ),
                              ]))
                      : Container(),
                ],
              )),
          const SizedBox(height: 12),
          _bodyWeightListWidget(_userProvider.userdata.bodyStats)
        ],
      ));
    });
  }

  _showMyDialog_NewWeight() async {
    var result = await bodyWeightCtrlAlert(context, 1);
    if (result.isNotEmpty) {
      DateTime toDay = DateTime.now();
      _displayBodyWeightPushDialog(
          double.parse(result[0].text), double.parse(result[1].text));
      _userProvider.setUserWeightAdd(toDay.toString(),
          double.parse(result[0].text), double.parse(result[1].text));
    }
  }

  _showMyDialog(historyId) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return showsimpleAlerts(
            layer: 7,
            eindex: -1,
            rindex: -1,
          );
        });
    if (result == true) {
      _hisProvider.deleteHistorydata(historyId);
      HistoryDelete(history_id: historyId).deleteHistory();
    }
  }

  _showMyDialog_EditWeight(index) async {
    var result = await bodyWeightCtrlAlert(context, 2);
    if (result.isNotEmpty) {
      _userProvider.setUserWeightEdit(
          index, double.parse(result[0].text), double.parse(result[1].text));
    }
  }

  void _displayBodyWeightPushDialog(userWeight, userGoal) {
    var weightChange = "";
    var weightSuccess = "";
    if ((userWeight - _userProvider.userdata.bodyStats.last.weight) > 0) {
      weightChange = "+" +
          (userWeight - _userProvider.userdata.bodyStats.last.weight)
              .toStringAsFixed(1) +
          "kg 증가했어요";
      if (_userProvider.userdata.bodyStats.last.weight >
          _userProvider.userdata.bodyStats.last.weight_goal) {
        weightSuccess = "감량에 분발이 필요해요";
      } else if (_userProvider.userdata.bodyStats.last.weight <
          _userProvider.userdata.bodyStats.last.weight_goal) {
        weightSuccess = "증량이 성공중 이에요";
      } else if (_userProvider.userdata.bodyStats.last.weight ==
          _userProvider.userdata.bodyStats.last.weight_goal) {
        weightSuccess = "현재 몸무게를 유지해주세요";
      }
    } else if ((userWeight - _userProvider.userdata.bodyStats.last.weight) <
        0) {
      weightChange = "" +
          (userWeight - _userProvider.userdata.bodyStats.last.weight)
              .toStringAsFixed(1) +
          "kg 감소했어요";
      if (_userProvider.userdata.bodyStats.last.weight >
          _userProvider.userdata.bodyStats.last.weight_goal) {
        weightSuccess = "감량에 성공중 이에요";
      } else if (_userProvider.userdata.bodyStats.last.weight <
          _userProvider.userdata.bodyStats.last.weight_goal) {
        weightSuccess = "증량에 분발이 필요해요";
      } else if (_userProvider.userdata.bodyStats.last.weight ==
          _userProvider.userdata.bodyStats.last.weight_goal) {
        weightSuccess = "현재 몸무게를 유지해주세요";
      }
    } else {
      weightChange = "몸무게가 유지 되었어요";
      if (_userProvider.userdata.bodyStats.last.weight >
          _userProvider.userdata.bodyStats.last.weight_goal) {
        weightSuccess = "감량에 분발이 필요해요";
      } else if (_userProvider.userdata.bodyStats.last.weight <
          _userProvider.userdata.bodyStats.last.weight_goal) {
        weightSuccess = "증량에 분발이 필요해요";
      } else if (_userProvider.userdata.bodyStats.last.weight ==
          _userProvider.userdata.bodyStats.last.weight_goal) {
        weightSuccess = "현재 몸무게를 유지해주세요";
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
              weightChange,
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(weightSuccess,
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
                _bodyWeightChartWidget(context),
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
                      color: Theme.of(context).primaryColorLight,
                    ),
                    disabledForegroundColor:
                        const Color.fromRGBO(246, 58, 64, 20),
                    padding: const EdgeInsets.all(12.0),
                  ),
                  child: Text('닫기',
                      textScaleFactor: 1.7,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ),
            ],
          );
        });
  }

  Widget _bodyWeightChartWidget(context) {
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

    final LinearGradient gradientColors = LinearGradient(
        colors: color,
        stops: stops,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);
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
                  textStyle:
                      TextStyle(color: Theme.of(context).primaryColorLight)),
              series: [
                LineSeries<BodyStat, DateTime>(
                  isVisibleInLegend: true,
                  color: Theme.of(context).primaryColorLight,
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

  Widget _calendarWidget() {
    return Consumer<HistorydataProvider>(builder: (builder, provider, child) {
      return Column(children: [
        SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: _exCalendarSearchCtrlBool ? 150 : 50,
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Focus(
                      child: TextField(
                          controller: _exCalendarSearchCtrl,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            isDense: true,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor,
                            ),
                            hintText: "운동 검색",
                            hintStyle: TextStyle(
                                fontSize: 16.0,
                                color: Theme.of(context).primaryColorLight),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1.5,
                                  color: Theme.of(context).cardColor),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onChanged: (text) {
                            setState(() {});
                          }),
                      onFocusChange: (hasFocus) {
                        setState(() {
                          if (_exCalendarSearchCtrl.text != "") {
                            _exCalendarSearchCtrlBool = true;
                          } else {
                            _exCalendarSearchCtrlBool = hasFocus;
                          }
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                      height: 40,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _calendartechChips())),
                ),
              ],
            ),
            TableCalendar(
              rowHeight: 40,
              firstDay: DateTime(1990),
              lastDay: DateTime(2050),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              daysOfWeekVisible: true,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: _getEventsfromDay,
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              locale: "ko-KR",
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                outsideDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                markerDecoration: const BoxDecoration(
                    color: Color(0xFffc60a8), shape: BoxShape.circle),
                selectedTextStyle: TextStyle(
                    color: Theme.of(context).buttonColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                defaultTextStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight),
                withinRangeTextStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight),
                weekendTextStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight),
                outsideTextStyle:
                    const TextStyle(color: Color.fromRGBO(113, 113, 113, 100)),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                todayTextStyle:
                    TextStyle(color: Theme.of(context).primaryColorLight),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle:
                      TextStyle(color: Theme.of(context).primaryColorLight),
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.arrow_left,
                      color: Theme.of(context).primaryColorLight),
                  rightChevronIcon: Icon(Icons.arrow_right,
                      color: Theme.of(context).primaryColorLight),
                  headerPadding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 3.0)),
            ),
          ]),
        ),
        _getEventsfromDay(_selectedDay).isEmpty != true
            ? _allchartExercisesWidget(
                List.from(_getEventsfromDay(_selectedDay).reversed))
            : Container()
      ]);
    });
  }

  Widget _allchartExercisesWidget(exercises) {
    return Expanded(
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return _chartExercisesWidget(exercises[index].exercises,
                  exercises[index].id, _userProvider.userdata, true, index);
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container();
            },
            shrinkWrap: true,
            itemCount: exercises.length,
            scrollDirection: Axis.vertical));
  }

  Widget _onechartExercisesWidget(exercises) {
    return Expanded(
      child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return _onechartExerciseWidget(
                exercises[index], 0, _userProvider.userdata, true, index);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Container(
              alignment: Alignment.center,
              height: 0,
              color: const Color(0xFF212121),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 0,
                color: const Color(0xFF717171),
              ),
            );
          },
          shrinkWrap: true,
          itemCount: exercises.length,
          scrollDirection: Axis.vertical),
    );
  }

  Widget _bodyWeightListWidget(List<BodyStat> bodyStats) {
    double deviceWidth = MediaQuery.of(context).size.width - 8;
    double top = 20;
    double bottom = 20;
    return Expanded(
      child: SingleChildScrollView(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(top),
                bottomRight: Radius.circular(bottom),
                topLeft: Radius.circular(top),
                bottomLeft: Radius.circular(bottom))),
        child: Column(
          children: [
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: deviceWidth / 3 - 20,
                  child: const Text(
                    "날짜",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: deviceWidth / 3 - 20,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "몸무게",
                      textScaleFactor: 1.1,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: deviceWidth / 3 - 20,
                  child: const Text(
                    "목표",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 16)
              ],
            )),
            ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return _bodyWeightListItemWidget(
                      List.from(bodyStats.reversed)[index],
                      _userProvider.userdata,
                      true,
                      bodyStats.length - index - 1);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 0.5,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 0.5,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  );
                },
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: bodyStats.length,
                scrollDirection: Axis.vertical),
          ],
        ),
      )),
    );
  }

  Widget _bodyWeightListItemWidget(bodyStat, userdata, bool shirink, index) {
    double top = 0;
    double bottom = 0;

    double deviceWidth = MediaQuery.of(context).size.width - 8;
    return Container(
        child: GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(top),
                bottomRight: Radius.circular(bottom),
                topLeft: Radius.circular(top),
                bottomLeft: Radius.circular(bottom))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: deviceWidth / 3 - 20,
                    child: Text(bodyStat.date.substring(0, 10),
                        textScaleFactor: 1.3,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    width: deviceWidth / 3 - 20,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          bodyStat.weight.toStringAsFixed(1) +
                              "${userdata.weight_unit}",
                          textScaleFactor: 1.3,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                          textAlign: TextAlign.center),
                    ),
                  ),
                  SizedBox(
                    width: deviceWidth / 3 - 20,
                    child: Text(
                        bodyStat.weight_goal.toStringAsFixed(1) +
                            "${userdata.weight_unit}",
                        textScaleFactor: 1.3,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight),
                        textAlign: TextAlign.center),
                  ),
                  GestureDetector(
                    onTapDown: _storePosition,
                    onTap: () {
                      showMenu(
                          context: context,
                          position: RelativeRect.fromRect(
                              _tapPosition & const Size(30, 30),
                              Offset.zero & const Size(0, 0)),
                          items: [
                            PopupMenuItem(
                                onTap: () {
                                  Future<void>.delayed(
                                      const Duration(), // OR const Duration(milliseconds: 500),
                                      () => _showMyDialog_EditWeight(index));
                                },
                                padding: const EdgeInsets.all(0.0),
                                child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 0.0),
                                    leading: Icon(Icons.edit,
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    title: Text("수정",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight)))),
                            PopupMenuItem(
                                onTap: () {
                                  Future<void>.delayed(
                                      const Duration(), // OR const Duration(milliseconds: 500),
                                      () => _userProvider
                                          .setUserWeightDelete(index));
                                },
                                padding: const EdgeInsets.all(0.0),
                                child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 0.0),
                                    leading: Icon(Icons.delete,
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    title: Text("삭제",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight)))),
                          ]);
                    },
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 18.0,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  Widget _onechartExerciseWidget(
      exuniq, historyId, userdata, bool shirink, index) {
    double top = 20;
    double bottom = 20;

    double totalDistance = 0;
    num totalTime = 0;
    exuniq.sets.forEach((value) {
      totalDistance += value.weight;
      totalTime += value.reps;
    });
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(exuniq.date,
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(top),
                      bottomRight: Radius.circular(bottom),
                      topLeft: Radius.circular(top),
                      bottomLeft: Radius.circular(bottom))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  exuniq.isCardio
                      ? _chartCardioExerciseSetsWidget(exuniq.sets)
                      : _chartExerciseSetsWidget(exuniq.sets),
                  Container(
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text("",
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Color(0xFF717171))),
                        const Expanded(child: SizedBox()),
                        Text(
                            exuniq.isCardio
                                ? "Total: ${totalDistance}km/${Duration(seconds: totalTime.toInt()).toString().split('.')[0]}"
                                : "${"1RM: " + exuniq.onerm.toStringAsFixed(1)}/${exuniq.goal.toStringAsFixed(1)}${userdata.weight_unit}",
                            textScaleFactor: 1.0,
                            style: const TextStyle(color: Color(0xFF717171))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _chartExercisesWidget(
      exuniq, historyId, userdata, bool shirink, index) {
    double top = 0;
    double bottom = 0;

    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("훈련 ${index + 1}",
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTapDown: _storePosition,
                  onTap: () {
                    showMenu(
                        context: context,
                        position: RelativeRect.fromRect(
                            _tapPosition & const Size(30, 30),
                            Offset.zero & const Size(0, 0)),
                        items: [
                          PopupMenuItem(
                              onTap: () {
                                Future<void>.delayed(
                                    const Duration(), // OR const Duration(milliseconds: 500),
                                    () => _showMyDialog(historyId));
                              },
                              padding: const EdgeInsets.all(0.0),
                              child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0, vertical: 0.0),
                                  leading: Icon(Icons.delete,
                                      color:
                                          Theme.of(context).primaryColorLight),
                                  title: Text("삭제",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)))),
                        ]);
                  },
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 18.0,
                  ),
                ),
              )
            ],
          ),
          ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              itemBuilder: (BuildContext context, int index) {
                if (exuniq.length == 1) {
                  top = 20;
                  bottom = 20;
                } else if (index == 0) {
                  top = 20;
                  bottom = 0;
                } else if (index == exuniq.length - 1) {
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
                              (element) => element.name == exuniq[index].name)]
                      .image;
                  if (_exImage == null) {
                    _exImage = "";
                  }
                } catch (e) {
                  _exImage = "";
                }
                double totalDistance = 0;
                num totalTime = 0;
                exuniq[index].sets.forEach((value) {
                  totalDistance += value.weight;
                  totalTime += value.reps;
                });
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        Transition(
                            child: StaticsExerciseDetails(
                                exercise: exuniq[index],
                                index: index,
                                origin_exercises: exuniq,
                                history_id: historyId),
                            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(top),
                            bottomRight: Radius.circular(bottom),
                            topLeft: Radius.circular(top),
                            bottomLeft: Radius.circular(bottom))),
                    height: 52,
                    child: Row(
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
                                child: Icon(Icons.image_not_supported,
                                    color: Theme.of(context).primaryColorDark),
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle),
                              ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exuniq[index].name,
                                textScaleFactor: 1.3,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight),
                              ),
                              Container(
                                child: Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    const Expanded(child: SizedBox()),
                                    Text(
                                        exuniq[index].isCardio
                                            ? "Total: ${totalDistance}km/${Duration(seconds: totalTime.toInt()).toString().split('.')[0]}"
                                            : "${"1RM: " + exuniq[index].onerm.toStringAsFixed(1)}/${exuniq[index].goal.toStringAsFixed(1)}${userdata.weight_unit}",
                                        textScaleFactor: 1.0,
                                        style: const TextStyle(
                                            color: Color(0xFF717171))),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  height: 0.5,
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 0.5,
                    color: Theme.of(context).primaryColorDark,
                  ),
                );
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: shirink,
              itemCount: exuniq.length),
        ],
      ),
    );
  }

  Widget _chartExerciseSetsWidget(sets) {
    return Container(
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(5.0),
              height: 28,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 25,
                          child: const Text(
                            "Set",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
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
                        textScaleFactor: 1.1,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Container(width: 35),
                  SizedBox(
                      width: 40,
                      child: const Text(
                        "Reps",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  SizedBox(
                      width: 70,
                      child: const Text(
                        "1RM",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ],
              )),
          SizedBox(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  textScaleFactor: 1.3,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
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
                            textScaleFactor: 1.3,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                            width: 35,
                            child: SvgPicture.asset("assets/svg/multiply.svg",
                                color: Theme.of(context).primaryColorLight,
                                height:
                                    19 * _themeProvider.userFontSize / 0.8)),
                        SizedBox(
                          width: 40,
                          child: Text(
                            sets[index].reps.toString(),
                            textScaleFactor: 1.3,
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
                                    textScaleFactor: 1.3,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    "${sets[index].weight}",
                                    textScaleFactor: 1.3,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    textAlign: TextAlign.center,
                                  )),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 0,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 0,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  );
                },
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: sets.length),
          ),
        ],
      ),
    );
  }

  Widget _chartCardioExerciseSetsWidget(sets) {
    return Container(
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(5.0),
              height: 28,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 80,
                      padding: EdgeInsets.only(right: 4),
                      child: Text(
                        "Set",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Container(
                      width: 80,
                      child: Text(
                        "거리(Km)",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Container(
                      width: 140,
                      child: Text(
                        "시간(시:분:초)",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ],
              )),
          SizedBox(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  Duration _time = Duration(seconds: sets[index].reps);
                  return Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 85,
                          child: Text(
                            "${index + 1}",
                            textScaleFactor: 1.3,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            sets[index].weight.toStringAsFixed(1),
                            textScaleFactor: 1.3,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: Text(
                            "${_time.inHours.toString().length == 1 ? "0" + _time.inHours.toString() : _time.inHours}:${_time.inMinutes.remainder(60).toString().length == 1 ? "0" + _time.inMinutes.remainder(60).toString() : _time.inMinutes.remainder(60)}:${_time.inSeconds.remainder(60).toString().length == 1 ? "0" + _time.inSeconds.remainder(60).toString() : _time.inSeconds.remainder(60)}",
                            textScaleFactor: 1.3,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 0,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 0,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  );
                },
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: sets.length),
          ),
        ],
      ),
    );
  }

  Widget _chartWidget() {
    return (Center(
      child: Column(
        children: [StaticModule()],
      ),
    ));
  }

  List<Widget> techChips() {
    List<Widget> chips = [];
    if (_exProvider.exercisesdata != null && _exSearchCtrl.text == "") {
      for (int i = 0; i < _exProvider.exercisesdata!.exercises.length; i++) {
        Widget item = Padding(
            padding: const EdgeInsets.only(left: 3, right: 3),
            child: ChoiceChip(
              label: Text(_exProvider.exercisesdata!.exercises[i].name),
              labelStyle: TextStyle(
                  color: _chartIndex.chartIndex == i
                      ? Theme.of(context).buttonColor
                      : Theme.of(context).primaryColorLight),
              selected: _chartIndex.chartIndex == i,
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).cardColor,
              onSelected: (bool value) {
                _chartIndex.change(i);
                _getChartSourcefromDay();

                FocusScope.of(context).unfocus();
              },
            ));
        chips.add(item);
      }
    } else if (_exProvider.exercisesdata != null && _exSearchCtrl.text != "") {
      for (int i = 0; i < _exProvider.exercisesdata!.exercises.length; i++) {
        Widget item = Padding(
          padding: const EdgeInsets.only(left: 3, right: 3),
          child: ChoiceChip(
            label: Text(_exProvider.exercisesdata!.exercises[i].name),
            labelStyle: TextStyle(
                color: _chartIndex.chartIndex == i
                    ? Theme.of(context).buttonColor
                    : Theme.of(context).primaryColorLight),
            selected: _chartIndex.chartIndex == i,
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onSelected: (bool value) {
              _chartIndex.change(i);
              _getChartSourcefromDay();
            },
          ),
        );
        if (_exProvider.exercisesdata!.exercises[i].name
            .contains(_exSearchCtrl.text)) {
          chips.add(item);
        }
      }
    } else {
      _exProvider.getdata();
    }
    return chips;
  }

  List<Widget> _calendartechChips() {
    List<Widget> chips = [
      Padding(
        padding: const EdgeInsets.only(left: 3, right: 3),
        child: ChoiceChip(
          label: const Text("All"),
          labelStyle: TextStyle(
              color: _chartIndex.staticIndex == 0
                  ? Theme.of(context).buttonColor
                  : Theme.of(context).primaryColorLight),
          selected: _chartIndex.staticIndex == 0,
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onSelected: (bool value) {
            _chartIndex.changeStaticIndex(0);
            _getChartSourcefromDay();
            FocusScope.of(context).unfocus();
          },
        ),
      )
    ];
    if (_exProvider.exercisesdata != null && _exCalendarSearchCtrl.text == "") {
      for (int i = 1;
          i < _exProvider.exercisesdata!.exercises.length + 1;
          i++) {
        Widget item = Padding(
          padding: const EdgeInsets.only(left: 3, right: 3),
          child: ChoiceChip(
            label: Text(_exProvider.exercisesdata!.exercises[i - 1].name),
            labelStyle: TextStyle(
                color: _chartIndex.staticIndex == i
                    ? Theme.of(context).buttonColor
                    : Theme.of(context).primaryColorLight),
            selected: _chartIndex.staticIndex == i,
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onSelected: (bool value) {
              _chartIndex.changeStaticIndex(i);
              _getChartSourcefromDay();
              FocusScope.of(context).unfocus();
            },
          ),
        );
        chips.add(item);
      }
    } else if (_exProvider.exercisesdata != null &&
        _exCalendarSearchCtrl.text != "") {
      for (int i = 1;
          i < _exProvider.exercisesdata!.exercises.length + 1;
          i++) {
        Widget item = Padding(
          padding: const EdgeInsets.only(left: 10, right: 5),
          child: ChoiceChip(
            label: Text(_exProvider.exercisesdata!.exercises[i - 1].name),
            labelStyle: TextStyle(color: Theme.of(context).primaryColorLight),
            selected: _chartIndex.staticIndex == i,
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onSelected: (bool value) {
              _chartIndex.changeStaticIndex(i);
              _getChartSourcefromDay();
            },
          ),
        );
        if (_exProvider.exercisesdata!.exercises[i - 1].name
            .contains(_exCalendarSearchCtrl.text)) {
          chips.add(item);
        }
      }
    } else {
      _exProvider.getdata();
    }
    return chips;
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    initializeDateFormatting('pt_BR', null);
    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _getChartSourcefromDay();
    return Scaffold(
        appBar: _appbarWidget(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: _staticsPages(),
        ));
  }
}
