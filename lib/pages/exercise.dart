import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Exercise extends StatefulWidget {
  const Exercise({Key? key}) : super(key: key);

  @override
  _ExerciseState createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  List<Map<String, String>> datas = [];
  double top = 0;
  double bottom = 0;

  @override
  void initState() {
    super.initState();
    datas = [
      {
        "workout": "가슴삼두",
        "exercise": "벤치프레스",
        "number": "1"
      },
      {
        "workout": "어깨",
        "exercise": "숄더프레스,밀리터리 프레스",
        "number": "2"
      },
      {
        "workout": "하체",
        "exercise": "스쿼트,파워레그프레스,레그익스텐션",
        "number": "3"
      },
    ];
  }

/*
  switch (index) {
    case 0:
      return Home();
      break;
    case 1:
      return Exercise();
      break;
    case 2:
      return Calendar();
      break;
    case 3:
      return Container();
      break;
  }
*/

  PreferredSizeWidget _appbarWidget(){
    return AppBar(
      title: Text(
          "Workout List",
          style:TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset("assets/svg/add.svg"),
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
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 5),
        itemBuilder: (BuildContext _context, int index){
          if(index==0){top = 20; bottom = 0;} else if (index==datas.length-1){top = 0;bottom = 20;} else {top = 0;bottom = 0;};
          return Container(
            child: Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  color: Color(0xFF212121),
                  borderRadius: BorderRadius.only(
                  topRight: Radius.circular(top),
                  bottomRight: Radius.circular(bottom),
                  topLeft: Radius.circular(top),
                  bottomLeft: Radius.circular(bottom)
                  )
                ),
                height: 52,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      datas[index]["workout"].toString(),
                      style: TextStyle(fontSize: 21, color: Colors.white),
                    ),
                    Text(
                      "${datas[index]["number"].toString()} Exercises",
                      style: TextStyle(fontSize: 13, color: Color(0xFF717171))
                    )
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext _context, int index){
          return Container(height:1, color: Color(0xFF717171),);
        },
        itemCount: datas.length
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
