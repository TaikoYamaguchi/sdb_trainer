import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? _user;

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget(_user) {
    return AppBar(
      title: Text(
        _user!.nickname,
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
    return Padding(
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
                            _exunique.exercises[index].goal.floor().toString(),
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

  PreferredSizeWidget _appbarFutureWidget() {
    return PreferredSize(
        child: FutureBuilder(
            future: Future.wait([UserService.loadUserdata()]),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                    color: Colors.black,
                    child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Container(
                    color: Colors.black,
                    child: Center(
                        child: Text("데이터 오류",
                            style: TextStyle(color: Colors.white))));
              }
              if (snapshot.hasData) {
                return _appbarWidget(snapshot.data![0]);
              }

              return Container();
            }),
        preferredSize: Size.fromHeight(50.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appbarFutureWidget(), body: _bodyWidget());
  }
}
