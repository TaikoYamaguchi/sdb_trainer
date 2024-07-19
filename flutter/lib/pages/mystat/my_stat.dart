import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
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
  List<Widget> statSliders = [];

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
    List<Widget> statSliders = [
      GestureFlipCard(
        animationDuration: const Duration(milliseconds: 300),
        axis: FlipAxis.vertical,
        controller: flip_ctrl,
        enableController: false,
        frontWidget: Center(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width*1.585*0.95,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius:
                    const BorderRadius.all(Radius.circular(25))),
              ),
            ),
          ),
        ),
        backWidget: Center(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width*1.585*0.95,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius:
                    const BorderRadius.all(Radius.circular(25))),
                child: Column(
                  children: [
                    Text("나의 몸 상태")
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      GestureFlipCard(
        animationDuration: const Duration(milliseconds: 300),
        axis: FlipAxis.vertical,
        controller: flip_ctrl,
        enableController: false,
        frontWidget: Center(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width*1.585*0.95,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius:
                    const BorderRadius.all(Radius.circular(25))),
              ),
            ),
          ),
        ),
        backWidget: Center(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width*1.585*0.95,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius:
                    const BorderRadius.all(Radius.circular(25))),
                child: Column(
                  children: [
                    Text("달력")
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
        appBar: _appbarWidget(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            child: Stack(
              children: [
                Positioned(
                    top: MediaQuery.of(context).size.width * 0.1,
                    left: 220,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [
                            Color(0xff7a28cb),
                            Color(0xff8369de),
                            Color(0xff8da0cb)
                          ])),
                    )),
                Positioned(
                    bottom: MediaQuery.of(context).size.width * 0.1,
                    right: 150,
                    child: Transform.rotate(
                      angle: 8,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [
                              Color(0xff7a28cb),
                              Color(0xff7369de),
                              Color(0xff7da0cb)
                            ])),
                      ),
                    )),
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 1/1.585,
                    enlargeCenterPage: true,
                  ),
                  items: statSliders,
                ),
              ],
            )
            )
          ),
        );
  }
}
