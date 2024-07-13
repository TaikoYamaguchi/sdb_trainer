import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sdb_trainer/pages/feed/friendHistory.dart';
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

  final flip_ctrl = GestureFlipCardController();

  @override
  void initState() {

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

    return Scaffold(
        appBar: _appbarWidget(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            child: GestureFlipCard(
              animationDuration: const Duration(milliseconds: 300),
                axis: FlipAxis.vertical,
                controller: flip_ctrl,
                enableController: false,
                frontWidget: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: Colors.blueAccent,
                      child: Column(
                        children: [
                          Text("운동 밸런스:"),
                          Text("전신 피로도:"),
                          Text("최근 7일간 운동 빈도"),
                          Text("내가 모은 카드 수: 4/30"),
                          Text("나의 3대 무제: "),
                          Text("나의 최애 운동: "),
                          Text("나의 3대 추세(M/Q/Y): "),
                          Text("나이"),
                          Text("체중"),
                          Text("평균 수행 볼륨"),
                          Text("오늘의 운동조언"),

                        ],
                      ),
                    )
                ),
                backWidget: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: Colors.redAccent,
                    )
                  ),
                )
            )
          ),
        );
  }
}
