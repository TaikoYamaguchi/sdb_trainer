import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../src/blocs/statics_event.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late Map<DateTime, List<Event>> selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isChartWidget = false;

  TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    selectedEvents = {};
    _isChartWidget = false;
    super.initState();
  }

  List<Event> _getEventsfromDay(DateTime date) {
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

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    return Scaffold(
      appBar: _appbarWidget(),
      backgroundColor: Colors.black,
      body: Column(
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
                headerPadding:
                    EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0)),
          ),
          ..._getEventsfromDay(_selectedDay)
              .map((Event event) => ListTile(title: Text(event.title)))
        ],
      ),
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
                              if (selectedEvents[_selectedDay] != null) {
                                selectedEvents[_selectedDay]!
                                    .add(Event(title: _eventController.text));
                              } else {
                                selectedEvents[_selectedDay] = [
                                  Event(title: _eventController.text)
                                ];
                              }
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
