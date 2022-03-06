import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';

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
  @override
  void initState() {
    super.initState();
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: SfRadialGauge(axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: _exunique.exercises[0].goal,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0,
                            endValue: _exunique.exercises[0].onerm,
                            color: Color.fromRGBO(66, 0, 255, 100)),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Column(children: <Widget>[
                              Text(_exunique.exercises[0].name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  _exunique.exercises[0].onerm
                                          .floor()
                                          .toString() +
                                      "/" +
                                      _exunique.exercises[0].goal
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: SfRadialGauge(axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: _exunique.exercises[1].goal,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0,
                            endValue: _exunique.exercises[1].onerm,
                            color: Color.fromRGBO(0, 255, 25, 100)),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Column(children: <Widget>[
                              Text(_exunique.exercises[1].name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  _exunique.exercises[1].onerm
                                          .floor()
                                          .toString() +
                                      "/" +
                                      _exunique.exercises[1].goal
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
                      maximum: _exunique.exercises[2].goal,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0,
                            endValue: _exunique.exercises[2].onerm,
                            color: Color.fromRGBO(235, 0, 255, 100)),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Column(children: <Widget>[
                              Text(_exunique.exercises[2].name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  _exunique.exercises[2].onerm
                                          .floor()
                                          .toString() +
                                      "/" +
                                      _exunique.exercises[2].goal
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: SfRadialGauge(axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: _exunique.exercises[3].goal,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0,
                            endValue: _exunique.exercises[3].onerm,
                            color: Color.fromRGBO(0, 255, 240, 100)),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Column(children: <Widget>[
                              Text(_exunique.exercises[3].name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  _exunique.exercises[3].onerm
                                          .floor()
                                          .toString() +
                                      "/" +
                                      _exunique.exercises[3].goal
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
              )
            ])
          ],
        ),
      ),
    );
  }

  Widget _bodyWidget() {
    return FutureBuilder(
        future: Future.wait([ExercisesRepository.loadExercisesdata()]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(
                color: Colors.black,
                child: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Container(
                color: Colors.black,
                child: Center(
                    child:
                        Text("데이터 오류", style: TextStyle(color: Colors.white))));
          }
          if (snapshot.hasData) {
            return _homeWidget(snapshot.data![0]);
          }

          return Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appbarWidget(), body: _bodyWidget());
  }
}
