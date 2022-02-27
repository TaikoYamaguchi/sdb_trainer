import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class SDBdata {
  SDBdata(this.workout, this.exercise, this.goal, this.stat, this.number);
  final String workout;
  final String exercise;
  final double goal;
  final double stat;
  final int number;
}

class _HomeState extends State<Home> {
  late List<SDBdata> _sdbData;
  @override
  void initState() {
    super.initState();
    _sdbData = getSDBdata();
  }

  List<SDBdata> getSDBdata() {
    final List<SDBdata> sdbData = [
      SDBdata("가슴삼두", "벤치", 130, 105, 1),
      SDBdata("어깨", "밀리터리", 100, 60, 2),
      SDBdata("하체", "스쿼트", 160, 140, 3),
      SDBdata("등", "데드", 180, 155, 4),
    ];
    return sdbData;
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text(
        "",
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

  Widget _bodyWidget() {
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
                      (_sdbData[0].stat +
                              _sdbData[1].stat +
                              _sdbData[2].stat +
                              _sdbData[3].stat)
                          .floor()
                          .toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.w800)),
                  Text(
                      "/" +
                          (_sdbData[0].goal +
                                  _sdbData[1].goal +
                                  _sdbData[2].goal +
                                  _sdbData[3].goal)
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: SfRadialGauge(axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: _sdbData[0].goal,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0,
                            endValue: _sdbData[0].stat,
                            color: Color.fromRGBO(66, 0, 255, 100)),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Column(children: <Widget>[
                              Text(_sdbData[0].exercise,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  _sdbData[0].stat.floor().toString() +
                                      "/" +
                                      _sdbData[0].goal.floor().toString(),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: SfRadialGauge(axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: _sdbData[1].goal,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0,
                            endValue: _sdbData[1].stat,
                            color: Color.fromRGBO(0, 255, 25, 100)),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Column(children: <Widget>[
                              Text(_sdbData[1].exercise,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  _sdbData[1].stat.floor().toString() +
                                      "/" +
                                      _sdbData[1].goal.floor().toString(),
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
              )
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: SfRadialGauge(axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: _sdbData[2].goal,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0,
                            endValue: _sdbData[2].stat,
                            color: Color.fromRGBO(235, 0, 255, 100)),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Column(children: <Widget>[
                              Text(_sdbData[2].exercise,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  _sdbData[2].stat.floor().toString() +
                                      "/" +
                                      _sdbData[2].goal.floor().toString(),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: SfRadialGauge(axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: _sdbData[3].goal,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0,
                            endValue: _sdbData[3].stat,
                            color: Color.fromRGBO(0, 255, 240, 100)),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Column(children: <Widget>[
                              Text(_sdbData[3].exercise,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  _sdbData[3].stat.floor().toString() +
                                      "/" +
                                      _sdbData[3].goal.floor().toString(),
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
              )
            ])
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appbarWidget(), body: _bodyWidget());
  }
}
