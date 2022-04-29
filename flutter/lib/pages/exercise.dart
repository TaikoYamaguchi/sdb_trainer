import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_workout.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';

class Exercise extends StatefulWidget {
  final onPush;
  Exercise({Key? key, this.onPush}) : super(key: key);

  @override
  ExerciseState createState() => ExerciseState();
}

class ExerciseState extends State<Exercise> {
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  var _userdataProvider;
  var _exercisesdataProvider;
  var _workoutdataProvider;
  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  String _title = "Workout List";

  List<Sets> setslist = [
    Sets(index:0, weight: 100.0, reps: 1 , ischecked: false)
  ];

  late List<Exercises> exerciseList = [
    Exercises(name: "스쿼트", sets: setslist , onerm: 0.0, rest: 1),
  ];



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
            _displayTextInputDialog(context);
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

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                   print(value);
                });
              },
              controller: _workoutNameCtrl,
              decoration: InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[_workoutSubmitButton(context),],
          );
        });
  }

  Widget _workoutSubmitButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => _postWorkoutCheck(),
            child: Text("workout 이름 제출",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _postWorkoutCheck() async {

    WorkoutPost(user_email: _userdataProvider.userdata.email, name: _workoutNameCtrl.text,  exercises: exerciseList)
        .postWorkout()
        .then((data) => data["user_email"] != null
        ? Navigator.pop(context)
        : showToast("입력을 확인해주세요"));
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context);
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