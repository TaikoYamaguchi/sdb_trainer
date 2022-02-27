import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/pages/each_workout.dart';
import 'package:sdb_trainer/repository/contents_repository.dart';
import 'package:transition/transition.dart';


class Exercise extends StatefulWidget {
  const Exercise({Key? key}) : super(key: key);

  @override
  _ExerciseState createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  final ContentsRepository contentsRepository = ContentsRepository();
  int _currentPageIndex = 0;
  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  String _title = "Workout List";

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 1;
    datas = [
      {
        "workout": "가슴삼두",
        "exercise": ["벤치프레스"],
      },
      {
        "workout": "어깨",
        "exercise": ["숄더프레스","밀리터리 프레스"],
      },
      {
        "workout": "하체",
        "exercise": ["스쿼트","파워레그프레스","레그익스텐션"],
      },
    ];

  }

  PreferredSizeWidget _appbarWidget(){
    if ( swap ==1) { _title = "Workout List";} else{_title = "Exercise List";};
    return AppBar(
      title: Row(
        children: [
          Text(
              _title,
              style:TextStyle(color: Colors.white, fontSize: 30),
          ),
          IconButton(
            iconSize: 30,
            onPressed: () {
              setState(() {
                swap= swap*-1;
              });
            },
            icon: Icon(Icons.swap_horiz_outlined)
          )
        ],
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

  Widget _workoutWidget() {
    return Container(
      color: Colors.black,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 5),
        itemBuilder: (BuildContext _context, int index){
          if(index==0){top = 20; bottom = 0;} else if (index==datas.length-1){top = 0;bottom = 20;} else {top = 0;bottom = 0;};
          return GestureDetector(
            onTap: () {
              Navigator.push(context,Transition(
                child: EachWorkoutDetails(workouttitle: datas[index]["workout"].toString(), exerciselist: datas[index]["exercise"]),
                transitionEffect: TransitionEffect.RIGHT_TO_LEFT
              ));
            },
            child: Container(
              child: Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
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
                          "${datas[index]["exercise"].length} Exercises",
                          style: TextStyle(fontSize: 13, color: Color(0xFF717171))
                      )
                    ],
                  ),
                ),
              ),
            ),
          );


        },
        separatorBuilder: (BuildContext _context, int index){
          return Container(
            alignment: Alignment.center,
            height:1, color: Color(0xFF212121),
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 10),
              height:1, color: Color(0xFF717171),
            ),
          );

        },
        itemCount: datas.length
      ),
    );
  }


  Future<Map<String, dynamic>> _loadContents() async {
    Map<String, dynamic> responseData =
      await contentsRepository.loadContentsFromLocation();
    return responseData;
  }


  Widget _exercisesWidget(Map<String, dynamic>datas2) {
    return Container(
      color: Colors.black,
      child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index){
            if(index==0){top = 20; bottom = 0;} else if (index==datas2.keys.toList().length-1){top = 0;bottom = 20;} else {top = 0;bottom = 0;};
            return Container(
              child: Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
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
                        datas2.keys.toList()[index],
                        style: TextStyle(fontSize: 21, color: Colors.white),
                      ),

                      Container(
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                                "Rest: ${datas2[datas2.keys.toList()[index]][0]["rest"]}",
                                style: TextStyle(fontSize: 13, color: Color(0xFF717171))
                            ),
                            Expanded(child: SizedBox()),
                            Text(
                                "1RM: ${datas2[datas2.keys.toList()[index]][0]["1rm"]}/${datas2[datas2.keys.toList()[index]][0]["goal"]}${datas2[datas2.keys.toList()[index]][0]["unit"]}",
                                style: TextStyle(fontSize: 13, color: Color(0xFF717171))
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext _context, int index){
            return Container(
              alignment: Alignment.center,
              height:1, color: Color(0xFF212121),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10),
                height:1, color: Color(0xFF717171),
              ),
            );

          },
          itemCount: datas2.keys.toList().length
      ),
    );
  }

  Widget _bodyWidget() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadContents(),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        switch (swap) {
          case 1:
            return _workoutWidget();

          case -1:
            return _exercisesWidget(snapshot.data ?? {});
        }
        return Container();
      }
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
