import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/pages/each_workout.dart';

import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:transition/transition.dart';


class Exercise extends StatefulWidget {
  const Exercise({Key? key}) : super(key: key);

  @override
  _ExerciseState createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {

  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  String _title = "Workout List";

  @override
  void initState() {
    super.initState();
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

  Widget _workoutWidget(routinedata) {
    return Container(
      color: Colors.black,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 5),
        itemBuilder: (BuildContext _context, int index){
          if(index==0){top = 20; bottom = 0;} else if (index==routinedata.routinedatas.length-1){top = 0;bottom = 20;} else {top = 0;bottom = 0;};
          return GestureDetector(
            onTap: () {
              Navigator.push(context,Transition(
                child: EachWorkoutDetails(workouttitle: routinedata.routinedatas[index].name, exerciselist: routinedata.routinedatas[index].exercises),
                transitionEffect: TransitionEffect.RIGHT_TO_LEFT
              ));
            },
            child: Container(
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
                      routinedata.routinedatas[index].name,
                      style: TextStyle(fontSize: 21, color: Colors.white),
                    ),
                    Text(
                        "${routinedata.routinedatas[index].exercises.length} Exercises",
                        style: TextStyle(fontSize: 13, color: Color(0xFF717171))
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
        itemCount: routinedata!.routinedatas.length
      ),
    );
  }


  Widget _exercisesWidget(datas2) {
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
    return FutureBuilder<RoutinedataList>(
      future: RoutineRepository.loadRoutinedata(),
      builder: (BuildContext context, AsyncSnapshot<RoutinedataList> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(color: Colors.black,child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Container(color: Colors.black,child: Center(child: Text("데이터 오류")));
        }
        if (snapshot.hasData) {
          return _workoutWidget(snapshot.data!);;
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
