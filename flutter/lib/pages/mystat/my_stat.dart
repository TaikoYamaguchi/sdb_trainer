import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sdb_trainer/pages/feed/friendHistory.dart';
import 'package:sdb_trainer/pages/mystat/calendar_card.dart';
import 'package:sdb_trainer/pages/mystat/weight_card.dart';
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
                Text("분석",
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
      WeightCard(),
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
      )),
    );
  }



}
