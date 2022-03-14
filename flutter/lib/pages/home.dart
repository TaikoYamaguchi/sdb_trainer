import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  var _exercisesdataProvider;
  var _userdataProvider;
  var _bodyStater;
  var _staticPageState;
  var _chartIndex;

  PreferredSizeWidget _appbarWidget() {
    if (_userdataProvider.userdata != null) {
      return AppBar(
        title: Text(
          _userdataProvider.userdata.nickname + "님",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset("assets/svg/chart.svg"),
            onPressed: () {
              print("press!");
            },
          )
        ],
        backgroundColor: Colors.black,
      );
    }
    return PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: Container(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator())));
  }

  Widget _homeWidget(_exunique) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          children: <Widget>[
            Text("Total SDB",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 54,
                    fontWeight: FontWeight.w800)),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                      (_exunique.exercises[0].onerm +
                              _exunique.exercises[1].onerm +
                              _exunique.exercises[2].onerm)
                          .floor()
                          .toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 54,
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
              padding: const EdgeInsets.all(20),
              child: Text('''"Shut up & Squat!"''',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            Text('''Lifting Stats''',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              _homeGaugeChart(_exunique, 0, Color.fromRGBO(66, 0, 255, 100)),
              _homeGaugeChart(_exunique, 1, Color.fromRGBO(0, 255, 25, 100)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              _homeGaugeChart(_exunique, 2, Color.fromRGBO(235, 0, 255, 100)),
              _homeGaugeChart(_exunique, 3, Color.fromRGBO(0, 255, 240, 100))
            ])
          ],
        ),
      ),
    );
  }

  Widget _homeGaugeChart(_exunique, index, color) {
    return GestureDetector(
      onTap: () => {
        _bodyStater.change(2),
        _chartIndex.change(index),
        _staticPageState.change(true)
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
                          _exunique.exercises[index].onerm.floor().toString() +
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
    );
  }

  @override
  Widget build(BuildContext context) {
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercisesdataProvider.getdata();
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _userdataProvider.getdata();
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _staticPageState = Provider.of<StaticPageProvider>(context, listen: false);
    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);

    return Scaffold(
        appBar: _appbarWidget(),
        body: Consumer<ExercisesdataProvider>(
            builder: (context, provider, widget) {
          if (provider.exercisesdata != null) {
            return _homeWidget(provider.exercisesdata);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        }));
  }
}
