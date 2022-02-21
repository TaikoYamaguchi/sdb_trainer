import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    return Scaffold(
      body: TableCalendar(
        firstDay: DateTime(1990),
        lastDay: DateTime(2050),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        daysOfWeekVisible: true,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
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
          selectedTextStyle: TextStyle(
            color: Colors.white,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.purpleAccent,
            borderRadius: BorderRadius.circular(5.0),
            shape: BoxShape.rectangle,
          ),
        ),
        headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            headerPadding:
                EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0)),
      ),
    );
  }
}
