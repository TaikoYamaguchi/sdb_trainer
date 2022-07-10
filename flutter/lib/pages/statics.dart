import 'package:flutter/material.dart';
import 'package:sdb_trainer/pages/static_exercise.dart';
import 'package:sdb_trainer/providers/userdata.dart';
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
  var _userdataProvider;
  var _isChartWidget;
  var _chartIndex;
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  PageController? _isPageController;
  var _tapPosition;
  var _historydataProvider;
  var _exercisesdataProvider;

  TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
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

  List<SDBdata> _getEventsfromDay(DateTime date) {
    String date_calendar = DateFormat('yyyy-MM-dd').format(date);
    selectedEvents = {};
    for (int i = 0;
        i < _historydataProvider.historydata!.sdbdatas.length;
        i++) {
      if (_historydataProvider.historydata!.sdbdatas[i].date!
              .substring(0, 10) ==
          date_calendar) {
        if (selectedEvents[date] != null) {
          selectedEvents[date]!
              .add(_historydataProvider.historydata!.sdbdatas[i]);
        } else {
          selectedEvents[date] = [
            _historydataProvider.historydata!.sdbdatas[i]
          ];
        }
      }
    }

    return selectedEvents[date] ?? [];
  }

  void _getChartSourcefromDay() async {
    _sdbChartData = [];
    var _sdbChartDataExample = _historydataProvider.historydata!.sdbdatas
        .map((name) => name.exercises
            .where((name) => name.name.contains(_exercisesdataProvider
                    .exercisesdata!.exercises[_chartIndex.chartIndex].name)
                ? true
                : false)
            .toList())
        .toList();
    for (int i = 0; i < _sdbChartDataExample.length; i++) {
      if (_sdbChartDataExample[i].isEmpty) {
        null;
      } else {
        _sdbChartData!.add(_sdbChartDataExample[i][0]);
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
      return PageView(
        controller: provider1.isPageController,
        children: [_chartWidget(), _staticsWidget()],
        onPageChanged: (page) {
          if (page == 1) {
            _isChartWidget.change(false);
          } else if (page == 0) {
            _isChartWidget.change(true);
          }
        },
      );
    });
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Consumer2<ChartIndexProvider, StaticPageProvider>(
          builder: (builder, provider1, provider2, child) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: _isChartWidget.isChartWidget
                    ? SvgPicture.asset("assets/svg/chart_statics_on.svg")
                    : SvgPicture.asset("assets/svg/chart_statics_off.svg"),
                onPressed: () {
                  _chartIndex.changePageController(0);
                  _isChartWidget.change(true);
                },
              ),
              SizedBox(width: 150),
              IconButton(
                icon: _isChartWidget.isChartWidget
                    ? SvgPicture.asset("assets/svg/calendar_statics_off.svg")
                    : SvgPicture.asset("assets/svg/calendar_statics_on.svg"),
                onPressed: () {
                  _chartIndex.changePageController(1);
                  _isChartWidget.change(false);
                },
              ),
            ]);
      }),
      backgroundColor: Color(0xFF212121),
    );
  }

  Widget _staticsWidget() {
    return Consumer<HistorydataProvider>(builder: (builder, provider, child) {
      return Column(children: [
        TableCalendar(
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
              color: Colors.blue,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5.0),
            ),
            outsideDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5.0),
            ),
            markerDecoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
            ),
            defaultTextStyle: const TextStyle(color: Colors.white),
            withinRangeTextStyle: TextStyle(color: Colors.white),
            weekendTextStyle: TextStyle(color: Colors.white),
            outsideTextStyle:
                TextStyle(color: Color.fromRGBO(113, 113, 113, 100)),
            todayDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.green[600],
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
          headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(color: Colors.white),
              titleCentered: true,
              leftChevronIcon: Icon(Icons.arrow_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.arrow_right, color: Colors.white),
              headerPadding:
                  EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0)),
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
                  exercises[index].id, _userdataProvider.userdata, true, index);
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
            itemCount: exercises.length,
            scrollDirection: Axis.vertical));
  }

  Widget _onechartExercisesWidget(exercises) {
    return Expanded(
      child: ListView.separated(
          itemBuilder: (BuildContext _context, int index) {
            return _onechartExerciseWidget(
                exercises[index], 0, _userdataProvider.userdata, true, index);
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
          scrollDirection: Axis.vertical),
    );
  }

  Widget _onechartExerciseWidget(
      exuniq, history_id, userdata, bool shirink, index) {
    double top = 0;
    double bottom = 0;
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(exuniq.date,
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Color(0xFF212121),
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
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF717171))),
                        Expanded(child: SizedBox()),
                        Text(
                            "1RM: " +
                                exuniq.onerm.toStringAsFixed(1) +
                                "/${exuniq.goal.toStringAsFixed(1)}${userdata.weight_unit}",
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF717171))),
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
    print(history_id);
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("훈련 " + (index + 1).toString(),
                    style: TextStyle(fontSize: 18, color: Colors.white)),
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
                                  leading: Icon(Icons.delete),
                                  title: Text("삭제"))),
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
                        color: Color(0xFF212121),
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
                          style: TextStyle(fontSize: 21, color: Colors.white),
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
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF717171))),
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
                                  style: TextStyle(
                                    fontSize: 21,
                                    color: Colors.white,
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
                            style: TextStyle(
                              fontSize: 21,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            width: 35,
                            child: SvgPicture.asset("assets/svg/multiply.svg",
                                color: Colors.white, height: 19)),
                        Container(
                          width: 40,
                          child: Text(
                            sets[index].reps.toString(),
                            style: TextStyle(
                              fontSize: 21,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            width: 70,
                            child: (sets[index].reps != 1)
                                ? Text(
                                    "${(sets[index].weight * (1 + sets[index].reps / 30)).toStringAsFixed(1)}",
                                    style: TextStyle(
                                        fontSize: 21, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    "${sets[index].weight}",
                                    style: TextStyle(
                                        fontSize: 21, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  )),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext _context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 1,
                    color: Colors.black,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height: 1,
                      color: Color(0xFF717171),
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
    return (Center(
        child: Column(
      children: [
        Container(child: Row(children: techChips())),
        Expanded(
          flex: 1,
          child: Container(
              child: SfCartesianChart(
                  title: ChartTitle(
                      text: "SBD Chart",
                      textStyle: TextStyle(color: Colors.white)),
                  primaryXAxis: DateTimeAxis(),
                  tooltipBehavior: _tooltipBehavior,
                  zoomPanBehavior: _zoomPanBehavior,
                  legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: TextStyle(color: Colors.white)),
                  series: <SplineSeries>[
                // Renders line chart
                SplineSeries<Exercises, DateTime>(
                    isVisibleInLegend: true,
                    name: "1rm",
                    width: 3,
                    enableTooltip: true,
                    color: Colors.blue[600],
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle:
                            TextStyle(color: Colors.white, fontSize: 10)),
                    dataSource: _sdbChartData!,
                    xValueMapper: (Exercises sales, _) =>
                        DateTime.parse(sales.date!),
                    yValueMapper: (Exercises sales, _) => sales.onerm),

                SplineSeries<Exercises, DateTime>(
                    isVisibleInLegend: true,
                    color: Colors.orange,
                    name: "goal",
                    width: 2,
                    dataSource: _sdbChartData!,
                    xValueMapper: (Exercises sales, _) =>
                        DateTime.parse(sales.date!),
                    yValueMapper: (Exercises sales, _) => sales.goal),
              ])),
        ),
        _onechartExercisesWidget(_sdbChartData)
      ],
    )));
  }

  List<Widget> techChips() {
    List<Widget> chips = [];
    for (int i = 0;
        i < _exercisesdataProvider.exercisesdata!.exercises.length;
        i++) {
      Widget item = Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: ChoiceChip(
          label: Text(_exercisesdataProvider.exercisesdata!.exercises[i].name),
          labelStyle: TextStyle(color: Colors.black),
          selected: _chartIndex.chartIndex == i,
          selectedColor: Colors.deepOrange,
          onSelected: (bool value) {
            _chartIndex.change(i);
            _getChartSourcefromDay();
          },
        ),
      );
      chips.add(item);
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
            title: Text('운동을 지우시겠습니까?'),
            content: Text('정말로 운동을 지우시나요?'),
            actions: <Widget>[
              _deleteConfirmButton(history_id),
            ],
          );
        });
  }

  Widget _deleteConfirmButton(history_id) {
    print(history_id);
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () {
              _historydataProvider.deleteHistorydata(history_id);
              HistoryDelete(history_id: history_id).deleteHistory();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("Confirm",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    initializeDateFormatting('pt_BR', null);
    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);
    _isChartWidget = Provider.of<StaticPageProvider>(context, listen: false);
    _historydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _getChartSourcefromDay();
    print("this is sttttttttatics");
    return Scaffold(
        appBar: _appbarWidget(),
        backgroundColor: Colors.black,
        body: _staticsPages());
  }
}
