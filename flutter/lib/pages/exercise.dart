import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/pages/each_workout.dart';
import 'package:sdb_trainer/pages/unique_exercise.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
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

  late List<Exercises> exerciseList = [
    Exercises(name: "스쿼트", sets: Setslist().setslist, onerm: 0.0, rest: 1),
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
      actions: swap == 1
          ? [
              IconButton(
                icon: SvgPicture.asset("assets/svg/add.svg"),
                onPressed: () {
                  _displayTextInputDialog();
                },
              )
            ]
          : null,
      backgroundColor: Colors.black,
    );
  }

  Widget _workoutWidget() {
    return Container(
      color: Colors.black,
      child: Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
        List routinelist = provider.workoutdata.routinedatas;
        return ReorderableListView.builder(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = routinelist.removeAt(oldIndex);
                routinelist.insert(newIndex, item);
                _editWorkoutCheck();
              });
            },
            padding: EdgeInsets.symmetric(horizontal: 5),
            itemBuilder: (BuildContext _context, int index) {
              if (index == 0) {
                top = 20;
                bottom = 0;
              } else if (index == routinelist.length - 1) {
                top = 0;
                bottom = 20;
              } else {
                top = 0;
                bottom = 0;
              }
              ;
              return GestureDetector(
                key: Key('$index'),
                onTap: () {
                  Navigator.push(
                      context,
                      Transition(
                          child: EachWorkoutDetails(
                            exerciselist: routinelist[index].exercises,
                            rindex: index,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                },
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            color: Color(0xFF212121),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(top),
                                bottomRight: Radius.circular(bottom),
                                topLeft: Radius.circular(top),
                                bottomLeft: Radius.circular(bottom))),
                        height: 52,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  routinelist[index].name,
                                  style: TextStyle(
                                      fontSize: 21, color: Colors.white),
                                ),
                                Text(
                                    "${routinelist[index].exercises.length} Exercises",
                                    style: TextStyle(
                                        fontSize: 13, color: Color(0xFF717171)))
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                _displayDeleteAlert(index);
                              },
                              icon: Icon(Icons.delete),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      index == routinelist.length - 1
                          ? Container()
                          : Container(
                              alignment: Alignment.center,
                              height: 1,
                              color: Color(0xFF212121),
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 1,
                                color: Color(0xFF717171),
                              ),
                            )
                    ],
                  ),
                ),
              );
            },
            /*
              separatorBuilder: (BuildContext _context, int index) {
                return Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 1,
                  color: Color(0xFF212121),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 1,
                    color: Color(0xFF717171),
                  ),
                );
              },*/
            itemCount: routinelist.length);
      }),
    );
  }

  void _displayDeleteAlert(rindex) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Alert',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('이 루틴을 지우시겠습니까?'),
            actions: <Widget>[
              _DeleteConfirmButton(rindex),
            ],
          );
        });
  }

  Widget _DeleteConfirmButton(rindex) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () {
              _workoutdataProvider.removeroutineAt(rindex);
              _editWorkoutCheck();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("Confirm",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _deleteWorkoutCheck(int id) async {
    WorkoutDelete(id: id).deleteWorkout().then((data) =>
        data["user_email"] != null
            ? _workoutdataProvider.getdata()
            : showToast("입력을 확인해주세요"));
  }

  static Widget exercisesWidget(exuniq, userdata, bool shirink) {
    double top = 0;
    double bottom = 0;
    return Container(
      color: Colors.black,
      child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index) {
            if (index == 0) {
              top = 20;
              bottom = 0;
            } else if (index == exuniq.length - 1) {
              top = 0;
              bottom = 20;
            } else {
              top = 0;
              bottom = 0;
            }
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
                      exuniq[index].name,
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
                              "1RM: " +
                                  exuniq[index].onerm.toStringAsFixed(1) +
                                  "/${exuniq[index].goal.toStringAsFixed(1)}${userdata.weight_unit}",
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
          itemCount: exuniq.length),
    );
  }

  Widget exercisesWidget2(bool shirink) {
    double top = 0;
    double bottom = 0;
    return Container(
      color: Colors.black,
      child: Consumer2<ExercisesdataProvider, UserdataProvider>(
          builder: (builer, exercise, user, child) {
        var _userdata = user.userdata;
        var _exunique = exercise.exercisesdata.exercises;

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index) {
            if (index == 0) {
              top = 20;
              bottom = 0;
            } else if (index == _exunique.length - 1) {
              top = 0;
              bottom = 20;
            } else {
              top = 0;
              bottom = 0;
            }
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    Transition(
                        child: UniqueExerciseDetails(
                          ueindex: index,
                        ),
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
                        _exunique[index].name,
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
                                "1RM: ${_exunique[index].onerm}/${_exunique[index].goal.toStringAsFixed(1)}${_userdata.weight_unit}",
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF717171))),
                          ],
                        ),
                      )
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
          scrollDirection: Axis.vertical,
          shrinkWrap: shirink,
          itemCount: _exunique.length,
        );
      }),
    );
  }

  Widget _bodyWidget() {
    switch (swap) {
      case 1:
        return _workoutWidget();

      case -1:
        return exercisesWidget2(false);
    }
    return Container();
  }

  void _displayTextInputDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: TextField(
              onChanged: (value) {},
              controller: _workoutNameCtrl,
              decoration: InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              _workoutSubmitButton(context),
            ],
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
            onPressed: () {
              _workoutdataProvider.addroutine(new Routinedatas(
                  name: _workoutNameCtrl.text,
                  exercises: exerciseList,
                  routine_time: 0));

              _editWorkoutCheck();
              _workoutNameCtrl.clear();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("workout 이름 제출",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _editWorkoutCheck() async {
    WorkoutEdit(
            user_email: _userdataProvider.userdata.email,
            id: _workoutdataProvider.workoutdata.id,
            routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? [showToast("done!"), _workoutdataProvider.getdata()]
            : showToast("입력을 확인해주세요"));
  }

  void _postWorkoutCheck() async {
    WorkoutPost(
            user_email: _userdataProvider.userdata.email,
            routinedatas: _workoutdataProvider.routinedatas)
        .postWorkout()
        .then((data) => data["user_email"] != null
            ? _workoutdataProvider.getdata()
            : showToast("입력을 확인해주세요"));
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    return Scaffold(
        appBar: _appbarWidget(),
        body: Consumer2<ExercisesdataProvider, WorkoutdataProvider>(
            builder: (context, provider1, provider2, widget) {
          if (provider2.workoutdata != null) {
            return _bodyWidget();
          }
          return Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }));
  }
}
