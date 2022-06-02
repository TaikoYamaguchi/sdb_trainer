import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  var _isChartWidget;
  var _chartIndex;
  bool _isLoading = true;

  TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    selectedEvents = {};

    ExerciseService.loadSDBdata().then((sdbdatas) {
      _sdbData = sdbdatas;
      ExercisesRepository.loadExercisesdata().then((exercisesData) {
        _exercisesData = exercisesData;
        print("111??");
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
            ? ExerciseState.exercisesWidget(
                _getEventsfromDay(_selectedDay).first.exercises, true)
            : Container()
      ],
    );
  }

  Widget _chartWidget() {
    return (Center(
        child: Column(
      children: [
        Container(child: Row(children: techChips())),
        Container(
            child: SfCartesianChart(
                title: ChartTitle(
                    text: "SBD Chart",
                    textStyle: TextStyle(color: Colors.white)),
                primaryXAxis: DateTimeAxis(),
                legend: Legend(
                    isVisible: true, textStyle: TextStyle(color: Colors.white)),
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
    initializeDateFormatting('pt_BR', null);
    _chartIndex = Provider.of<ChartIndexProvider>(context);
    _isChartWidget = Provider.of<StaticPageProvider>(context);
    return Scaffold(
        appBar: _appbarWidget(),
        backgroundColor: Colors.black,
        body: _isChartWidget.isChartWidget
            ? (_isLoading ? null : _chartWidget())
            : (_isLoading ? null : _staticsWidget()));
  }
}
