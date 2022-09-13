import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  var _exercisesdataProvider;
  var _userdataProvider;
  var _bodyStater;
  var _staticPageState;
  var _chartIndex;
  var _historydataAll;

  PreferredSizeWidget _appbarWidget() {
    //if (_userdataProvider.userdata != null) {
    return AppBar(
      title: Consumer<UserdataProvider>(builder: (builder, provider, child) {
        if (provider.userdata != null) {
          return Text(
            provider.userdata.nickname + "님",
            style: TextStyle(color: Colors.white),
          );
        } else {
          return PreferredSize(
              preferredSize: Size.fromHeight(56.0),
              child: Container(
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator())));
        }
      }),
      actions: [
        IconButton(
          icon: SvgPicture.asset("assets/svg/chart.svg"),
          onPressed: () {
            _bodyStater.change(3);
            _staticPageState.change(false);
            _chartIndex.changePageController(1);
          },
        )
      ],
      backgroundColor: Colors.black,
    );
  }

  Widget _homeWidget(_exunique, context) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text("SDB ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.w600)),
                  Text(
                      (_exunique.exercises[0].onerm +
                              _exunique.exercises[1].onerm +
                              _exunique.exercises[2].onerm)
                          .floor()
                          .toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.w800)),
                  Text(
                      "/" +
                          (_exunique.exercises[0].goal +
                                  _exunique.exercises[1].goal +
                                  _exunique.exercises[2].goal)
                              .floor()
                              .toString() +
                          "kg",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600)),
                ]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _liftingStatWidget(_exunique, context),
            )
          ],
        ),
      ),
    );
  }

  Widget _liftingStatWidget(_exunique, context) {
    return Card(
        color: Theme.of(context).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Text('''Lifting Stats''',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 8.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _homeProgressiveBarChart(_exunique, 0, context),
                _homeProgressiveBarChart(_exunique, 1, context),
                _homeProgressiveBarChart(_exunique, 2, context),
                _homeProgressiveBarChart(_exunique, 3, context),
              ],
            )
          ]),
        ));
  }

  Widget _homeProgressiveBarChart(_exunique, index, context) {
    return _exunique.exercises.length > index
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () => {
                _chartIndex.change(index),
                _chartIndex.changePageController(0),
                _staticPageState.change(true),
                _bodyStater.change(3),
              },
              child: Container(
                height: 35,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width / 2 - 40,
                        child: Text(_exunique.exercises[index].name,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: LiquidLinearProgressIndicator(
                        value: _exunique.exercises[index].onerm /
                            _exunique.exercises[index].goal, // Defaults to 0.5.
                        borderColor: Theme.of(context).primaryColor,
                        valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).primaryColor),
                        backgroundColor: Colors.grey,
                        borderWidth: 0.0,
                        borderRadius: 15.0,
                        direction: Axis
                            .horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
                        center: Center(
                          child: Text(
                              _exunique.exercises[index].onerm
                                      .floor()
                                      .toString() +
                                  "/" +
                                  _exunique.exercises[index].goal
                                      .floor()
                                      .toString(),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  Path _buildBoatPath() {
    return Path()
      ..moveTo(15, 120)
      ..lineTo(0, 85)
      ..lineTo(50, 85)
      ..lineTo(50, 0)
      ..lineTo(105, 80)
      ..lineTo(60, 80)
      ..lineTo(60, 85)
      ..lineTo(120, 85)
      ..lineTo(105, 120)
      ..close();
  }

  Widget _homeGaugeChart(_exunique, index, color) {
    return _exunique.exercises.length > index
        ? GestureDetector(
            onTap: () => {
              _chartIndex.change(index),
              _chartIndex.changePageController(0),
              _staticPageState.change(true),
              _bodyStater.change(3),
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: SizedBox(
                width: 150,
                height: 150,
                child: SfRadialGauge(axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: _exunique.exercises[index].goal,
                    ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 0,
                          endValue: _exunique.exercises[index].onerm,
                          color: color)
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          widget: Container(
                              child: Column(children: <Widget>[
                            Text(_exunique.exercises[index].name,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                _exunique.exercises[index].onerm
                                        .floor()
                                        .toString() +
                                    "/" +
                                    _exunique.exercises[index].goal
                                        .floor()
                                        .toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ])),
                          angle: 90,
                          positionFactor: 0.5)
                    ],
                  )
                ]),
              ),
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    _historydataAll = Provider.of<HistorydataProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _staticPageState = Provider.of<StaticPageProvider>(context, listen: false);
    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);
    return Scaffold(
        appBar: _appbarWidget(),
        body: Consumer<ExercisesdataProvider>(
            builder: (context, provider, widget) {
          if (provider.exercisesdata != null) {
            return _homeWidget(provider.exercisesdata, context);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        }),
        backgroundColor: Colors.black);
  }
}
