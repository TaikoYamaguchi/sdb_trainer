import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sdb_trainer/pages/feed/friendHistory.dart';
import 'package:sdb_trainer/pages/mystat/calendar_card.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:transition/transition.dart';
import '../../repository/history_repository.dart';
import '../../src/model/historydata.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class MyStat extends StatefulWidget {
  const MyStat({Key? key}) : super(key: key);

  @override
  _MyStatState createState() => _MyStatState();
}

class _MyStatState extends State<MyStat> with TickerProviderStateMixin {

  final flip_ctrl = FlipCardController();
  List<Widget> statSliders = [];
  TooltipBehavior? _tooltipBehavior;
  ZoomPanBehavior? _zoomPanBehavior;
  var _userProvider;
  var _tapPosition;
  bool _bodyWeightChartIsOpen = true;


  late Map<DateTime, List<SDBdata>> selectedEvents;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  final TextEditingController _exSearchCtrl = TextEditingController(text: "");


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
    _tapPosition = const Offset(0.0, 0.0);
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


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
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
                Text("Stat",
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ],
            );
          }),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);

    List<Widget> statSliders = [
      CalendarCard(),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Text("나의 체중",textScaler: TextScaler.linear(2),),
                  SizedBox(width: 15,),
                  Icon(Icons.open_in_new,
                    color: Colors.white.withOpacity(0.7),
                  )
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
                      child: _weightWidget(),
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
        appBar: _appbarWidget(),
        body: Container(
          child: CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 0.87,
              height: MediaQuery.of(context).size.height,
              enlargeFactor: 0.25,
              autoPlay: false,
              aspectRatio: 1,
              enlargeCenterPage: true,
            ),
            items: statSliders,
          )
          ),
        );
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
                              color: Theme.of(context).highlightColor,
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
                                          ? Theme.of(context).highlightColor
                                          : Theme.of(context)
                                          .primaryColorLight)),
                              false: Text("off",
                                  style: TextStyle(
                                      color: _bodyWeightChartIsOpen
                                          ? Theme.of(context).primaryColorLight
                                          : Theme.of(context).highlightColor))
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


  Widget _bodyWeightListWidget(List<BodyStat> bodyStats) {
    double deviceWidth = (MediaQuery.of(context).size.width - 8)*0.87;
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
                Row(
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
                ),
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

    double deviceWidth = (MediaQuery.of(context).size.width - 8)*0.87;
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(top),
                bottomRight: Radius.circular(bottom),
                topLeft: Radius.circular(top),
                bottomLeft: Radius.circular(bottom))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      style:
                      TextStyle(color: Theme.of(context).primaryColorLight),
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
                                      color:
                                      Theme.of(context).primaryColorLight),
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
                                      color:
                                      Theme.of(context).primaryColorLight),
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
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _showMyDialog_EditWeight(index) async {
    var result = await bodyWeightCtrlAlert(context, 2);
    if (result.isNotEmpty) {
      _userProvider.setUserWeightEdit(
          index, double.parse(result[0].text), double.parse(result[1].text));
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
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
  }




  initialHistorydataGet() async {
    final initHistorydataProvider =
    Provider.of<HistorydataProvider>(context, listen: false);
    final initExercisesdataProvider =
    Provider.of<ExercisesdataProvider>(context, listen: false);

    initExercisesdataProvider.getdata();
    await initHistorydataProvider.getdata();
  }




}
