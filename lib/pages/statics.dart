import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../src/blocs/statics_event.dart';
import '../repository/history_repository.dart';
import '../src/model/historydata.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late Map<DateTime, List<SDBdata>> selectedEvents;
  SDBdataList? _sdbData;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  bool _isChartWidget = false;
  bool _isLoading = true;

  TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    selectedEvents = {};
    ExerciseService.loadSDBdata().then((sdbdatas) {
      _sdbData = sdbdatas;
      print(_sdbData);
      setState(() {
        _isLoading = false;
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

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _isChartWidget
            ? (<Widget>[
                IconButton(
                  icon: SvgPicture.asset("assets/svg/chart_statics_on.svg"),
                  onPressed: () {
                    print("chart");
                  },
                ),
                SizedBox(width: 150),
                IconButton(
                  icon: SvgPicture.asset("assets/svg/calendar_statics_off.svg"),
                  onPressed: () {
                    setState(() {
                      _isChartWidget = false;
                    });
                    print("calendar");
                  },
                ),
              ])
            : (<Widget>[
                IconButton(
                  icon: SvgPicture.asset("assets/svg/chart_statics_off.svg"),
                  onPressed: () {
                    setState(() {
                      _isChartWidget = true;
                    });
                    print("chart");
                  },
                ),
                SizedBox(width: 150),
                IconButton(
                  icon: SvgPicture.asset("assets/svg/calendar_statics_on.svg"),
                  onPressed: () {
                    print("calendar");
                  },
                ),
              ]),
      ),
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
        ..._getEventsfromDay(_selectedDay).map((SDBdata row) => Column(
              children: row.exercises
                  .map((e) => ListTile(
                      title:
                          Text(e.name, style: TextStyle(color: Colors.white))))
                  .toList(),
            ))
      ],
    );
  }

  Widget _chartWidget() {
    return Text(
      "this is chart",
      style: TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    return Scaffold(
      appBar: _appbarWidget(),
      backgroundColor: Colors.black,
      body: _isChartWidget
          ? _chartWidget()
          : (_isLoading ? null : _staticsWidget()),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: const Text("Add Exercise"),
                      content: TextFormField(controller: _eventController),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text("Ok"),
                          onPressed: () {
                            if (_eventController.text.isEmpty) {
                            } else {
                              print(_selectedDay);
                              print(_eventController);
                            }
                            Navigator.pop(context);
                            _eventController.clear();
                            setState(() {});
                            return;
                          },
                        )
                      ])),
          label: const Text("Add Exercise"),
          icon: const Icon(Icons.add)),
    );
  }
}
