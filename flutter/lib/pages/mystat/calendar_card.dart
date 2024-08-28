import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/feed/friendHistory.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/historydata.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:transition/transition.dart';

class CalendarCard extends StatefulWidget {
  const CalendarCard({Key? key}) : super(key: key);

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  var _chartIndex;
  var _hisProvider;
  var _exProvider;
  var _userProvider;
  var _tapPosition;
  late Map<DateTime, List<SDBdata>> selectedEvents;
  List<Exercises>? _sdbChartData = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  var _exCalendarSearchCtrlBool = false;
  final TextEditingController _exSearchCtrl = TextEditingController(text: "");
  final TextEditingController _exCalendarSearchCtrl =
  TextEditingController(text: "");
  final TextEditingController _eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    initializeDateFormatting('pt_BR', null);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);
    _getChartSourcefromDay();
    return _calendarCard();
  }

  Widget _calendarCard(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10,),
                Text("나의 운동 기록",textScaler: TextScaler.linear(2),),
                SizedBox(width: 15,),
                Icon(Icons.open_in_new,
                  color: Colors.white.withOpacity(0.7),)
              ],
            ),
            Center(
              child: ClipRRect(

                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.87,
                    height: MediaQuery.of(context).size.height* 0.87 * 0.78,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(15))),
                    child: Consumer<ChartIndexProvider>(
                        builder: (builder, provider, child) {
                        return _calendarWidget();
                      }
                    ),
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
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
                    color: Theme.of(context).highlightColor,
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

  Widget _allchartExercisesWidget(sdbdata) {
    return Expanded(
        child: ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return _chartExercisesWidget(sdbdata[index], sdbdata[index].id,
                  _userProvider.userdata, true, index);
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container();
            },
            shrinkWrap: true,
            itemCount: sdbdata.length,
            scrollDirection: Axis.vertical));
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

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Widget _chartExercisesWidget(
      sdbdata, historyId, userdata, bool shirink, index) {
    double top = 0;
    double bottom = 0;
    var exuniq = sdbdata.exercises;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("훈련 ${index + 1}",
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Theme.of(context).primaryColorLight)),
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
                                    color: Theme.of(context).primaryColorLight),
                                title: Text("삭제",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight)))),
                      ]);
                },
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                  size: 18.0,
                ),
              ),
            )
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                Transition(
                    child: FriendHistory(sdbdata: sdbdata),
                    transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
          },
          child: ListView.separated(
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
                  _exImage ??= "";
                } catch (e) {
                  _exImage = "";
                }
                double totalDistance = 0;
                num totalTime = 0;
                exuniq[index].sets.forEach((value) {
                  totalDistance += value.weight;
                  totalTime += value.reps;
                });
                return Container(
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
                        decoration:
                        const BoxDecoration(shape: BoxShape.circle),
                        child: Icon(Icons.image_not_supported,
                            color: Theme.of(context).primaryColorDark),
                      ),
                      const SizedBox(width: 8.0),
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
                            Row(
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
                            )
                          ],
                        ),
                      ),
                    ],
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
        )
      ],
    );
  }

  List<Widget> techChips() {
    List<Widget> chips = [];
    if (_exProvider.exercisesdata != null && _exSearchCtrl.text == "") {
      for (int i = 0; i < _exProvider.exercisesdata!.exercises.length; i++) {
        Widget item = Padding(
            padding: const EdgeInsets.only(left: 3, right: 3),
            child: ChoiceChip(
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.transparent,
                    width: 0.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0)),
              label: Text(_exProvider.exercisesdata!.exercises[i].name),
              labelStyle: TextStyle(
                  color: _chartIndex.chartIndex == i
                      ? Theme.of(context).highlightColor
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
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent, width: 0.0),
                borderRadius: BorderRadius.circular(8.0)),
            label: Text(_exProvider.exercisesdata!.exercises[i].name),
            labelStyle: TextStyle(
                color: _chartIndex.chartIndex == i
                    ? Theme.of(context).highlightColor
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
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent, width: 0.0),
              borderRadius: BorderRadius.circular(8.0)),
          label: const Text("All"),
          labelStyle: TextStyle(
              color: _chartIndex.staticIndex == 0
                  ? Theme.of(context).highlightColor
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
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent, width: 0.0),
                borderRadius: BorderRadius.circular(8.0)),
            label: Text(_exProvider.exercisesdata!.exercises[i - 1].name),
            labelStyle: TextStyle(
                color: _chartIndex.staticIndex == i
                    ? Theme.of(context).highlightColor
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
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent, width: 0.0),
                borderRadius: BorderRadius.circular(8.0)),
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


}
