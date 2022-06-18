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
import 'package:sdb_trainer/repository/exercises_repository.dart';
import '../src/model/historydata.dart';
import '../src/model/exercisesdata.dart' as ExercisesData;
import 'package:sdb_trainer/pages/exercise.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/unique_exercise.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late Map<DateTime, List<SDBdata>> selectedEvents;
  SDBdataList? _sdbData;
  List<Exercises>? _sdbChartData = [];
  ExercisesData.Exercisesdata? _exercisesData;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  var _userdataProvider;
  var _isChartWidget;
  var _chartIndex;
  TooltipBehavior? _tooltipBehavior;
  bool _isLoading = true;

  TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    selectedEvents = {};
    _tooltipBehavior = TooltipBehavior(enable: true);

    ExerciseService.loadSDBdata().then((sdbdatas) {
      _sdbData = sdbdatas;
      ExercisesRepository.loadExercisesdata().then((exercisesData) {
        _exercisesData = exercisesData;
        _getChartSourcefromDay();
        setState(() {
          _isLoading = false;
        });
      });
    });

    super.initState();
  }

  List<SDBdata> _getEventsfromDay(DateTime date) {
    String date_calendar = DateFormat('yyyy-MM-dd').format(date);
    selectedEvents = {};
    for (int i = 0; i < _sdbData!.sdbdatas.length; i++) {
      if (_sdbData!.sdbdatas[i].date!.substring(0, 10) == date_calendar) {
        if (selectedEvents[date] != null) {
          selectedEvents[date]!.add(_sdbData!.sdbdatas[i]);
        } else {
          selectedEvents[date] = [_sdbData!.sdbdatas[i]];
        }
      }
    }

    return selectedEvents[date] ?? [];
  }

  void _getChartSourcefromDay() async {
    _sdbChartData = [];
    var _sdbChartDataExample = _sdbData!.sdbdatas
        .map((name) => name.exercises
            .where((name) => name.name.contains(
                _exercisesData!.exercises[_chartIndex.chartIndex].name))
            .toList())
        .toList();
    print(_sdbChartDataExample);
    for (int i = 0; i < _sdbChartDataExample.length; i++) {
      print(_sdbChartDataExample.length);
      print(_sdbChartDataExample[i]);
      if (_sdbChartDataExample[i].isEmpty) {
        print(null);
        null;
      } else {
        print("not null");
        _sdbChartData!.add(_sdbChartDataExample[i][0]);
      }
    }
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        IconButton(
          icon: _isChartWidget.isChartWidget
              ? SvgPicture.asset("assets/svg/chart_statics_on.svg")
              : SvgPicture.asset("assets/svg/chart_statics_off.svg"),
          onPressed: () {
            _isChartWidget.change(true);
          },
        ),
        SizedBox(width: 150),
        IconButton(
          icon: _isChartWidget.isChartWidget
              ? SvgPicture.asset("assets/svg/calendar_statics_off.svg")
              : SvgPicture.asset("assets/svg/calendar_statics_on.svg"),
          onPressed: () {
            _isChartWidget.change(false);
          },
        ),
      ]),
      backgroundColor: Color(0xFF212121),
    );
  }

  Widget _staticsWidget() {
    return Column(
      children: [
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
              borderRadius: BorderRadius.circular(5.0),
              shape: BoxShape.rectangle,
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
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(5.0),
              shape: BoxShape.rectangle,
            ),
            defaultDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              shape: BoxShape.rectangle,
            ),
            weekendDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              shape: BoxShape.rectangle,
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
      ],
    );
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
          scrollDirection: Axis.vertical),
    );
  }

  Widget _onechartExercisesWidget(exercises) {
    print("thiissssssssss chart");
    print(exercises);
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
                        Text("Rest: need to set",
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
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("훈련 " + (index + 1).toString(),
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
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
                print("historyyyyyyy");
                print(exuniq);
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
                              Text("Rest: need to set",
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF717171))),
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
                  legend: Legend(
                      isVisible: true,
                      textStyle: TextStyle(color: Colors.white)),
                  series: <ChartSeries>[
                // Renders line chart
                LineSeries<Exercises, DateTime>(
                    isVisibleInLegend: true,
                    name: "1rm",
                    dataSource: _sdbChartData!,
                    xValueMapper: (Exercises sales, _) =>
                        DateTime.parse(sales.date!),
                    yValueMapper: (Exercises sales, _) => sales.onerm),
                LineSeries<Exercises, DateTime>(
                    isVisibleInLegend: true,
                    name: "goal",
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

    print("1111");
    print(_exercisesData);
    print("1111");
    for (int i = 0; i < _exercisesData!.exercises.length; i++) {
      Widget item = Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: ChoiceChip(
          label: Text(_exercisesData!.exercises[i].name),
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

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    initializeDateFormatting('pt_BR', null);
    _chartIndex = Provider.of<ChartIndexProvider>(context);
    _isChartWidget = Provider.of<StaticPageProvider>(context);
    _getChartSourcefromDay();
    return Scaffold(
        appBar: _appbarWidget(),
        backgroundColor: Colors.black,
        body: _isChartWidget.isChartWidget
            ? (_isLoading ? null : _chartWidget())
            : (_isLoading ? null : _staticsWidget()));
  }
}
