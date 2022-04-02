import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_workout.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:transition/transition.dart';

class Exercise extends StatefulWidget {
  final onPush;
  Exercise({Key? key, this.onPush}) : super(key: key);

  @override
  ExerciseState createState() => ExerciseState();
}

class ExerciseState extends State<Exercise> {
  var _exercisesdataProvider;
  var _workoutdataProvider;
  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  String _title = "Workout List";

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    if (swap == 1) {
      _title = "Workout List";
    } else {
      _title = "Exercise List";
    }
    ;
    return AppBar(
      title: Row(
        children: [
          Text(
            _title,
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          IconButton(
              iconSize: 30,
              onPressed: () {
                setState(() {
                  swap = swap * -1;
                });
              },
              icon: Icon(Icons.swap_horiz_outlined))
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
          itemBuilder: (BuildContext _context, int index) {
            if (index == 0) {
              top = 20;
              bottom = 0;
            } else if (index == _workoutdataProvider.workoutdata!.routinedatas.length - 1) {
              top = 0;
              bottom = 20;
            } else {
              top = 0;
              bottom = 0;
            }
            ;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    Transition(
                        child: EachWorkoutDetails(
                            workouttitle: _workoutdataProvider.workoutdata.routinedatas[index].name,
                            exerciselist:
                            _workoutdataProvider.workoutdata.routinedatas[index].exercises,
                            uniqueinfo: _exercisesdataProvider.exercisesdata.exercises),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
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
                          bottomLeft: Radius.circular(bottom))),
                  height: 52,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _workoutdataProvider.workoutdata.routinedatas[index].name,
                        style: TextStyle(fontSize: 21, color: Colors.white),
                      ),
                      Text(
                          "${_workoutdataProvider.workoutdata.routinedatas[index].exercises.length} Exercises",
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF717171)))
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext _context, int index) {
            return Container(
              alignment: Alignment.center,
              height: 1,
              color: Color(0xFF212121),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 1,
                color: Color(0xFF717171),
              ),
            );
          },
          itemCount: _workoutdataProvider.workoutdata.routinedatas.length),
    );
  }

  static Widget exercisesWidget(exuniq, bool shirink) {
    double top = 0;
    double bottom = 0;
    print("exercises");
    return Container(
      color: Colors.black,
      child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index) {
            if (index == 0) {
              top = 20;
              bottom = 0;
            } else if (index == exuniq.exercises.length - 1) {
              top = 0;
              bottom = 20;
            } else {
              top = 0;
              bottom = 0;
            }
            ;
            return Container(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Color(0xFF212121),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(top),
                        bottomRight: Radius.circular(bottom),
                        topLeft: Radius.circular(top),
                        bottomLeft: Radius.circular(bottom))),
                height: 52,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exuniq.exercises[index].name,
                      style: TextStyle(fontSize: 21, color: Colors.white),
                    ),
                    Container(
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Rest: need to set",
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF717171))),
                          Expanded(child: SizedBox()),
                          Text(
                              "1RM: ${exuniq.exercises[index].onerm}/${exuniq.exercises[index].goal} unit",
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF717171))),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext _context, int index) {
            return Container(
              alignment: Alignment.center,
              height: 1,
              color: Color(0xFF212121),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 1,
                color: Color(0xFF717171),
              ),
            );
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: shirink,
          itemCount: exuniq.exercises.length
      ),
    );
  }

  Widget _bodyWidget(edata) {
    switch (swap) {
      case 1:
        return _workoutWidget();

      case -1:
        return exercisesWidget(edata, false);
    }
    return Container();
  }


  @override
  Widget build(BuildContext context) {
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercisesdataProvider.getdata();
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _workoutdataProvider.getdata();

    return Scaffold(
      appBar: _appbarWidget(),
      body: Consumer2<ExercisesdataProvider,WorkoutdataProvider>(
          builder: (context, provider1, provider2, widget) {
            if (provider2.workoutdata != null) {
              return _bodyWidget(provider1.exercisesdata);
            }
            return Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          })

    );
  }
}
