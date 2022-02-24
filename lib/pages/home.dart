import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> datas = [];
  @override
  void initState() {
    super.initState();
    datas = [
      {
        "workout": "가슴삼두",
        "exercise": "벤치프레스",
        "goal": 130,
        "stat": 105,
        "number": "1"
      },
      {
        "workout": "어깨",
        "exercise": "밀리터리 프레스",
        "goal": 100,
        "stat": 60,
        "number": "2"
      },
      {
        "workout": "하체",
        "exercise": "스쿼트",
        "goal": 160,
        "stat": 140,
        "number": "3"
      },
      {
        "workout": "등",
        "exercise": "데드리프트",
        "goal": 180,
        "stat": 155,
        "number": "4"
      },
    ];
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
                      (datas[0]["stat"] +
                              datas[1]["stat"] +
                              datas[2]["stat"] +
                              datas[3]["stat"])
                          .toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.w800)),
                  Text(
                      "/" +
                          (datas[0]["goal"] +
                                  datas[1]["goal"] +
                                  datas[2]["goal"] +
                                  datas[3]["goal"])
                              .toString() +
                          "kg",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600)),
                ]),
            Padding(
              padding: const EdgeInsets.all(41.0),
              child: Text('''"Shut up & Squat!"''',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            Text('''Lifting Stats''',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
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
