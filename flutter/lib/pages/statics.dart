import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sdb_trainer/pages/static_exercise.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
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

class _CalendarState extends State<Calendar> {
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
  TextEditingController _exSearchCtrl = TextEditingController(text: "");
  TextEditingController _exCalendarSearchCtrl = TextEditingController(text: "");
  var _themeProvider;

  TextEditingController _eventController = TextEditingController();

  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible == false) {
        FocusScope.of(context).unfocus();
      }
    });
    // TODO: implement initState
    _tapPosition = Offset(0.0, 0.0);
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

        Map<int, Widget> _staticList = <int, Widget>{
          0: Padding(
            child: Text("운동",
                textScaleFactor: 1.3,
                style: TextStyle(
                  color:
                      page == 0 ? Theme.of(context).buttonColor : Colors.grey,
                )),
            padding: const EdgeInsets.all(5.0),
          ),
          1: Padding(
              child: Text("달력",
                  textScaleFactor: 1.3,
                  style: TextStyle(
                    color:
                        page == 1 ? Theme.of(context).buttonColor : Colors.grey,
                  )),
              padding: const EdgeInsets.all(5.0)),
          2: Padding(
              child: Text("몸무게",
                  textScaleFactor: 1.3,
                  style: TextStyle(
                    color:
                        page == 2 ? Theme.of(context).buttonColor : Colors.grey,
                  )),
              padding: const EdgeInsets.all(5.0)),
        };
        return Container(
          child: CupertinoSlidingSegmentedControl(
              groupValue: page,
              children: _staticList,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
    final _initHistorydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    final _initExercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);

    _initExercisesdataProvider.getdata();
    await _initHistorydataProvider.getdata();
  }

  initialProviderGet() async {
    final _initUserdataProvider =
        Provider.of<UserdataProvider>(context, listen: false);
    final _initHistorydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    final _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);

    final _initExercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    final _initworkoutProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);

    await [
      _initUserdataProvider.getdata(),
      _initUserdataProvider.getUsersFriendsAll(),
      _initHistorydataProvider.getdata(),
      _famousdataProvider.getdata(),
      _initworkoutProvider.getdata(),
      _initExercisesdataProvider.getdata(),
    ];
    _initHistorydataProvider.getFriendsHistorydata();
    _initUserdataProvider.getFriendsdata();
    _initUserdataProvider.getUsersFriendsAll();
    _initHistorydataProvider.getHistorydataAll();
    _initHistorydataProvider.getCommentAll();

    _initUserdataProvider.userdata != null
        ? [
            _initUserdataProvider.getFriendsdata(),
            _initHistorydataProvider.getFriendsHistorydata()
          ]
        : null;
  }

  List<SDBdata> _getEventsfromDay(DateTime date) {
    String date_calendar = DateFormat('yyyy-MM-dd').format(date);
    selectedEvents = {};
    if (_hisProvider.historydata != null && _chartIndex.staticIndex == 0) {
      for (int i = 0; i < _hisProvider.historydata!.sdbdatas.length; i++) {
        if (_hisProvider.historydata!.sdbdatas[i].date!.substring(0, 10) ==
            date_calendar) {
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
            date_calendar) {
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
    var _sdbChartDataExample = _hisProvider.historydata.sdbdatas
        .map((name) => name.exercises
            .where((name) => name.name ==
                    _exProvider
                        .exercisesdata!.exercises[_chartIndex.chartIndex].name
                ? true
                : false)
            .toList())
        .toList();
    for (int i = 0; i < _sdbChartDataExample.length; i++) {
      if (_sdbChartDataExample[i].isEmpty) {
        null;
      } else {
        for (int k = 0; k < _sdbChartDataExample[i].length; k++) {
          _sdbChartData!.add(_sdbChartDataExample[i][k]);
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
          SizedBox(height: 10),
          Expanded(
            child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: PageView(
                  controller: provider1.isPageController,
                  children: [
                    _chartWidget(),
                    _calendarWidget(),
                    _weightWidget()
                  ],
                  onPageChanged: (page) {
                    _chartIndex.changePageController(page as int);
                  },
                )),
          ),
        ],
      );
    });
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
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
    color.add(Color(0xFffc60a8).withOpacity(0.7));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Color(0xFffc60a8).withOpacity(0.7));

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
                      _displayBodyWeightDialog();
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
                                Text("목표치를 기록하고 달성 할 수 있어요",
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
                  borderRadius: BorderRadius.only(
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
                      Container(
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
                              borderRadius: BorderRadius.only(
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
          SizedBox(height: 12),
          _bodyWeightListWidget(_userProvider.userdata.bodyStats)
        ],
      ));
    });
  }

  void _displayBodyWeightDialog() {
    var _userWeightController = TextEditingController(
        text: _userProvider.userdata.bodyStats.last.weight.toString());
    var _userWeightGoalController = TextEditingController(
        text: _userProvider.userdata.bodyStats.last.weight_goal.toString());

    DateTime _toDay = DateTime.now();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            buttonPadding: EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.all(12.0),
            title: Text(
              '몸무게를 기록 할게요',
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('몸무게와 목표치를 바꿔보세요',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 20),
                TextField(
                  controller: _userWeightController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                    fontSize: 21,
                    color: Theme.of(context).primaryColorLight,
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
                      labelStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                      hintText: "몸무게",
                      hintStyle: TextStyle(
                          fontSize: 24.0,
                          color: Theme.of(context).primaryColorLight)),
                  onChanged: (text) {},
                ),
                TextField(
                  controller: _userWeightGoalController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                    fontSize: 21,
                    color: Theme.of(context).primaryColorLight,
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
                      labelStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                      hintText: "목표 몸무게",
                      hintStyle: TextStyle(
                          fontSize: 24.0,
                          color: Theme.of(context).primaryColorLight)),
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
                      color: Theme.of(context).primaryColorLight,
                    ),
                    disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                    padding: EdgeInsets.all(12.0),
                  ),
                  child: Text('오늘 몸무게 기록하기',
                      textScaleFactor: 1.7,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
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

  void _displayEditBodyWeightDialog(index) {
    var _userWeightController = TextEditingController(
        text: _userProvider.userdata.bodyStats[index].weight.toString());
    var _userWeightGoalController = TextEditingController(
        text: _userProvider.userdata.bodyStats[index].weight_goal.toString());

    DateTime _toDay = DateTime.now();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            buttonPadding: EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.all(12.0),
            title: Text(
              '몸무게를 수정 할게요',
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('몸무게와 목표치를 수정해보세요',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 20),
                TextField(
                  controller: _userWeightController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                    fontSize: 21,
                    color: Theme.of(context).primaryColorLight,
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
                      labelStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                      hintText: "몸무게",
                      hintStyle: TextStyle(
                          fontSize: 24.0,
                          color: Theme.of(context).primaryColorLight)),
                  onChanged: (text) {},
                ),
                TextField(
                  controller: _userWeightGoalController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                    fontSize: 21,
                    color: Theme.of(context).primaryColorLight,
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
                      labelStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                      hintText: "목표 몸무게",
                      hintStyle: TextStyle(
                          fontSize: 24.0,
                          color: Theme.of(context).primaryColorLight)),
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
                      color: Theme.of(context).primaryColorLight,
                    ),
                    disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                    padding: EdgeInsets.all(12.0),
                  ),
                  child: Text('몸무게 수정 하기',
                      textScaleFactor: 1.7,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    _userProvider.setUserWeightEdit(
                        index,
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
      _weightChange = "+" +
          (_userWeight - _userProvider.userdata.bodyStats.last.weight)
              .toStringAsFixed(1) +
          "kg 증가했어요";
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
      _weightChange = "" +
          (_userWeight - _userProvider.userdata.bodyStats.last.weight)
              .toStringAsFixed(1) +
          "kg 감소했어요";
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
            buttonPadding: EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.all(12.0),
            title: Text(
              _weightChange,
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_weightSuccess,
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
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
                    disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                    padding: EdgeInsets.all(12.0),
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
    color.add(Color(0xFffc60a8).withOpacity(0.7));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Color(0xFffc60a8).withOpacity(0.7));

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
      child: Container(
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
                Container(
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
                  child: Container(
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
                markerDecoration: BoxDecoration(
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
                    TextStyle(color: Color.fromRGBO(113, 113, 113, 100)),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
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
                  headerPadding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0)),
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
            itemBuilder: (BuildContext _context, int index) {
              return _chartExercisesWidget(exercises[index].exercises,
                  exercises[index].id, _userProvider.userdata, true, index);
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
            shrinkWrap: true,
            itemCount: exercises.length,
            scrollDirection: Axis.vertical));
  }

  Widget _onechartExercisesWidget(exercises) {
    return Expanded(
      child: ListView.separated(
          itemBuilder: (BuildContext _context, int index) {
            return _onechartExerciseWidget(
                exercises[index], 0, _userProvider.userdata, true, index);
          },
          separatorBuilder: (BuildContext _context, int index) {
            return Container(
              alignment: Alignment.center,
              height: 0,
              color: Color(0xFF212121),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 0,
                color: Color(0xFF717171),
              ),
            );
          },
          shrinkWrap: true,
          itemCount: exercises.length,
          scrollDirection: Axis.vertical),
    );
  }

  Widget _bodyWeightListWidget(List<BodyStat> bodyStats) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double top = 20;
    double bottom = 20;
    return Expanded(
      child: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
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
                Container(
                  width: deviceWidth / 3 - 20,
                  child: Text(
                    "날짜",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: deviceWidth / 3 - 20,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                Container(
                  width: deviceWidth / 3 - 20,
                  child: Text(
                    "목표",
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 16)
              ],
            )),
            ListView.separated(
                itemBuilder: (BuildContext _context, int index) {
                  return _bodyWeightListItemWidget(
                      List.from(bodyStats.reversed)[index],
                      _userProvider.userdata,
                      true,
                      bodyStats.length - index - 1);
                },
                separatorBuilder: (BuildContext _context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 0.5,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height: 0.5,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  );
                },
                physics: NeverScrollableScrollPhysics(),
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

    double deviceWidth = MediaQuery.of(context).size.width;
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
                  Container(
                    width: deviceWidth / 3 - 20,
                    child: Text(bodyStat.date.substring(0, 10),
                        textScaleFactor: 1.3,
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center),
                  ),
                  Container(
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
                  Container(
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
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 18.0,
                    ),
                    onTapDown: _storePosition,
                    onTap: () {
                      showMenu(
                          context: context,
                          position: RelativeRect.fromRect(
                              _tapPosition & Size(30, 30),
                              Offset.zero & Size(0, 0)),
                          items: [
                            PopupMenuItem(
                                onTap: () {
                                  Future<void>.delayed(
                                      const Duration(), // OR const Duration(milliseconds: 500),
                                      () =>
                                          _displayEditBodyWeightDialog(index));
                                },
                                padding: EdgeInsets.all(0.0),
                                child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
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
                                  ;
                                },
                                padding: EdgeInsets.all(0.0),
                                child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
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
      exuniq, history_id, userdata, bool shirink, index) {
    double top = 20;
    double bottom = 20;
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  _chartExerciseSetsWidget(exuniq.sets),
                  Container(
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("",
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Color(0xFF717171))),
                        Expanded(child: SizedBox()),
                        Text(
                            "1RM: " +
                                exuniq.onerm.toStringAsFixed(1) +
                                "/${exuniq.goal.toStringAsFixed(1)}${userdata.weight_unit}",
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Color(0xFF717171))),
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
      exuniq, history_id, userdata, bool shirink, index) {
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
                child: Text("훈련 " + (index + 1).toString(),
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 18.0,
                  ),
                  onTapDown: _storePosition,
                  onTap: () {
                    showMenu(
                        context: context,
                        position: RelativeRect.fromRect(
                            _tapPosition & Size(30, 30),
                            Offset.zero & Size(0, 0)),
                        items: [
                          PopupMenuItem(
                              onTap: () {
                                Future<void>.delayed(
                                    const Duration(), // OR const Duration(milliseconds: 500),
                                    () => _displayDeleteAlert(history_id));
                              },
                              padding: EdgeInsets.all(0.0),
                              child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
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
                ),
              )
            ],
          ),
          ListView.separated(
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
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        Transition(
                            child: StaticsExerciseDetails(
                                exercise: exuniq[index],
                                index: index,
                                origin_exercises: exuniq,
                                history_id: history_id),
                            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  },
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
                              Expanded(child: SizedBox()),
                              Text(
                                  "1RM: " +
                                      exuniq[index].onerm.toStringAsFixed(1) +
                                      "/${exuniq[index].goal.toStringAsFixed(1)}${userdata.weight_unit}",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(color: Color(0xFF717171))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext _context, int index) {
                return Container(
                  alignment: Alignment.center,
                  height: 0.5,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 0.5,
                    color: Theme.of(context).primaryColorDark,
                  ),
                );
              },
              physics: NeverScrollableScrollPhysics(),
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
              padding: EdgeInsets.all(5.0),
              height: 28,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 25,
                          child: Text(
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
                  Container(
                      width: 70,
                      child: Text(
                        "Weight(${_userProvider.userdata.weight_unit})",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Container(width: 35),
                  Container(
                      width: 40,
                      child: Text(
                        "Reps",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Container(
                      width: 70,
                      child: Text(
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
                itemBuilder: (BuildContext _context, int index) {
                  return Container(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
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
                        Container(
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
                        Container(
                            width: 35,
                            child: SvgPicture.asset("assets/svg/multiply.svg",
                                color: Theme.of(context).primaryColorLight,
                                height:
                                    19 * _themeProvider.userFontSize / 0.8)),
                        Container(
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
                        Container(
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
                separatorBuilder: (BuildContext _context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 0,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height: 0,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  );
                },
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: sets.length),
          ),
        ],
      ),
    );
  }

  Widget _chartWidget() {
    final List<Color> color = <Color>[];
    color.add(Color(0xFffc60a8).withOpacity(0.7));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Color(0xFffc60a8).withOpacity(0.7));

    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.4);
    stops.add(0.6);
    stops.add(1.0);

    final LinearGradient gradientColors = LinearGradient(
        colors: color,
        stops: stops,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);
    return (Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: _exSearchCtrlBool ? 150 : 50,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Focus(
                    child: TextField(
                        controller: _exSearchCtrl,
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
                                width: 1.5, color: Theme.of(context).cardColor),
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
                        if (_exSearchCtrl.text != "") {
                          _exSearchCtrlBool = true;
                        } else {
                          _exSearchCtrlBool = hasFocus;
                        }
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                    height: 40,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: techChips())),
              ),
            ],
          ),
          SizedBox(height: 5),
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20))),
              child: Column(children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24.0, top: 4.0, bottom: 4.0),
                      child: Text(
                          _exProvider.exercisesdata!
                              .exercises[_chartIndex.chartIndex].name,
                          textScaleFactor: 1.7,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                    ),
                    Container(
                      width: 100,
                      child: CustomSlidingSegmentedControl(
                          height: 24.0,
                          children: {
                            true: Text("on",
                                style: TextStyle(
                                    color: _bodyExChartIsOpen
                                        ? Theme.of(context).buttonColor
                                        : Theme.of(context).primaryColorLight)),
                            false: Text("off",
                                style: TextStyle(
                                    color: _bodyExChartIsOpen
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
                              _bodyExChartIsOpen = value;
                            });
                          }),
                    )
                  ],
                ),
                _bodyExChartIsOpen
                    ? Container(
                        height: 250,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.only(
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
                                majorGridLines: const MajorGridLines(width: 0),
                                minimum: _sdbChartData!.length == 0
                                    ? 0
                                    : _sdbChartData!.length > 1
                                        ? _sdbChartData!
                                                .reduce((curr, next) =>
                                                    curr.onerm! < next.onerm!
                                                        ? curr
                                                        : next)
                                                .onerm! *
                                            0.9
                                        : _sdbChartData![0].onerm),
                            tooltipBehavior: _tooltipBehavior,
                            zoomPanBehavior: _zoomPanBehavior,
                            legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom,
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).primaryColorLight)),
                            series: [
                              // Renders line chart
                              LineSeries<Exercises, DateTime>(
                                isVisibleInLegend: true,
                                color: Theme.of(context).primaryColorLight,
                                name: "goal",
                                dataSource: _sdbChartData!,
                                xValueMapper: (Exercises sales, _) =>
                                    DateTime.parse(sales.date!),
                                yValueMapper: (Exercises sales, _) =>
                                    sales.goal,
                              ),

                              LineSeries<Exercises, DateTime>(
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
                                name: "1rm",
                                color: Theme.of(context).primaryColor,
                                width: 5,
                                dataSource: _sdbChartData!,
                                xValueMapper: (Exercises sales, _) =>
                                    DateTime.parse(sales.date!),
                                yValueMapper: (Exercises sales, _) =>
                                    sales.onerm,
                              ),
                            ]))
                    : Container()
              ])),
          SizedBox(height: 12),
          _onechartExercisesWidget(_sdbChartData)
        ],
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
          label: Text("All"),
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

  void _displayDeleteAlert(history_id) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            title: Text('운동을 삭제 할 수 있어요',
                textScaleFactor: 2.0,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).primaryColorLight)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('정말로 운동을 지우시나요?',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                Text('외부를 터치하면 취소 할 수 있어요',
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            actions: <Widget>[
              _deleteConfirmButton(history_id),
            ],
          );
        });
  }

  Widget _deleteConfirmButton(history_id) {
    return SizedBox(
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
              padding: EdgeInsets.all(8.0),
            ),
            onPressed: () {
              _hisProvider.deleteHistorydata(history_id);
              HistoryDelete(history_id: history_id).deleteHistory();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("삭제",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
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
    return Scaffold(appBar: _appbarWidget(), body: _staticsPages());
  }
}
