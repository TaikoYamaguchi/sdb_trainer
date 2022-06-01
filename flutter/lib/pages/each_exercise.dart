import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart';

class EachExerciseDetails extends StatefulWidget {
  dynamic exercisedetail;
  List eachuniqueinfo;
  EachExerciseDetails(
      {Key? key, required this.exercisedetail, required this.eachuniqueinfo})
      : super(key: key);

  @override
  _EachExerciseDetailsState createState() => _EachExerciseDetailsState();
}

class _EachExerciseDetailsState extends State<EachExerciseDetails> {
  var _userdataProvider;
  var _historydataProvider;
  var _workoutdataProvider;
  var _routinetimeProvider;
  bool _isstarted = false;
  bool _isChecked = false;
  double top = 0;
  double bottom = 0;
  double? weight;
  int? reps;
  List<TextEditingController> weightController = [];
  List<TextEditingController> repsController = [];
  var _start_date ;
  var _finish_date ;
  var runtime = 0;
  Timer? timer1;

  late List<hisdata.Exercises> exerciseList = [];

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined),
        onPressed: (){
          //_editWorkoutCheck();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }

  void _editWorkoutCheck() async {
    print(_workoutdataProvider.name);
    WorkoutEdit(user_email: _userdataProvider.userdata.email, name: _workoutdataProvider.name,  exercises: _workoutdataProvider.exercises)
        .editWorkout()
        .then((data) => data["user_email"] != null
        ? showToast("done!")
        : showToast("입력을 확인해주세요"));
  }

  Widget _exercisedetailWidget() {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      color: Colors.black,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Rest Timer off",
                  style: TextStyle(
                    color: Color(0xFF717171),
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Rest: ${widget.exercisedetail.rest}",
                  style: TextStyle(
                    color: Color(0xFF717171),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )),
            Container(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.exercisedetail.name,
                      style: TextStyle(color: Colors.white, fontSize: 48),
                    ),
                    Text(
                      "Best 1RM: ${widget.eachuniqueinfo[0].onerm}/${widget.eachuniqueinfo[0].goal}unit",
                      style: TextStyle(color: Color(0xFF717171), fontSize: 21),
                    ),
                  ],
                )),
            Container(
                padding: EdgeInsets.only(right: 10),
                height: 25,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 80,
                        padding: EdgeInsets.only(right: 4),
                        child: Text(
                          "Set",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        )),
                    Container(
                        width: 70,
                        child: Text(
                          "Weight()",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
                    Container(width: 35),
                    Container(
                        width: 40,
                        child: Text(
                          "Reps",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
                    Container(
                        width: 70,
                        child: Text(
                          "1RM",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ],
                )),
            Expanded(
              child: ListView.separated(
                  itemBuilder: (BuildContext _context, int index) {
                    weightController.add(new TextEditingController());
                    repsController.add(new TextEditingController());
                    return Container(
                      padding: EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                      checkColor: Colors.black,
                                      fillColor:
                                          MaterialStateProperty.resolveWith(
                                              getColor),
                                      value: widget.exercisedetail!.sets[index]
                                          .ischecked,
                                      onChanged: (newvalue) {
                                        setState(() {
                                          widget.exercisedetail.sets[index]
                                              .ischecked = newvalue!;
                                        });
                                        print(widget.exercisedetail!.sets[index]
                                            .ischecked!);
                                      }),
                                ),
                                Container(
                                  width: 25,
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontSize: 21,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 70,
                            child: TextField(
                              controller: weightController[index],
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 21,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText:
                                    "${widget.exercisedetail.sets[index].weight}",
                                hintStyle: TextStyle(
                                  fontSize: 21,
                                  color: Colors.white,
                                ),
                              ),
                              onChanged: (text) {
                                double changeweight;
                                if (text == "") {
                                  changeweight = 0.0;
                                } else {
                                  changeweight = double.parse(text);
                                }
                                setState(() {
                                  widget.exercisedetail.sets[index].weight =
                                      changeweight;
                                });
                                print(text);
                                print(widget.exercisedetail.sets[index].weight);
                              },
                            ),
                          ),
                          Container(
                              width: 35,
                              child: SvgPicture.asset("assets/svg/multiply.svg",
                                  color: Colors.white, height: 19)),
                          Container(
                            width: 40,
                            child: TextField(
                              controller: repsController[index],
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 21,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText:
                                    "${widget.exercisedetail.sets[index].reps}",
                                hintStyle: TextStyle(
                                  fontSize: 21,
                                  color: Colors.white,
                                ),
                              ),
                              onChanged: (text) {
                                int changereps;
                                if (text == "") {
                                  changereps = 1;
                                } else {
                                  changereps = int.parse(text);
                                }
                                setState(() {
                                  widget.exercisedetail.sets[index].reps =
                                      changereps;
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 70,
                            child: (widget.exercisedetail.sets[index].reps != 1)
                                ? Text(
                                    "${(widget.exercisedetail.sets[index].weight * (1 + widget.exercisedetail.sets[index].reps / 30)).toStringAsFixed(1)}",
                                    style: TextStyle(
                                        fontSize: 21, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    "${widget.exercisedetail.sets[index].weight}",
                                    style: TextStyle(
                                        fontSize: 21, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext _context, int index) {
                    return Container(
                      alignment: Alignment.center,
                      height: 1,
                      color: Colors.black,
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        height: 1,
                        color: Color(0xFF717171),
                      ),
                    );
                  },
                  itemCount: widget.exercisedetail.sets.length),
            ),
            Container(
                padding: EdgeInsets.only(bottom: 10),
                child:  Column(
                  children: [
                    Container(
                      child: Consumer<RoutineTimeProvider>(builder: (context, provider, child){
                        return Text(provider.routineTime.toString(), style: TextStyle(fontSize: 25, color: Colors.white));
                      })
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.exercisedetail.sets.removeLast();
                                });
                              },
                              icon: Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 40,
                              )),
                        ),
                        Container(
                          child:
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                              onPressed: (){
                                setState(() {
                                  _isstarted = !_isstarted;
                                });
                                _start_date = DateTime.now();
                                print(_start_date.toString().substring(0,10));
                                if (_routinetimeProvider.isstarted){
                                  recordExercise();
                                  _editHistoryCheck();
                                }
                                _routinetimeProvider.routinecheck();

                              },
                              child: Consumer<RoutineTimeProvider>(builder: (builder, provider, child){
                                return Text(provider.routineButton);
                              }),
                            )

                        ),
                        Container(
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.exercisedetail.sets.add(new Sets(
                                      index: widget.exercisedetail.sets.length + 1,
                                      weight: 0.0,
                                      reps: 1,
                                      ischecked: false));
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 40,
                              )),
                        )
                      ],
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }


  void recordExercise(){
    final suggestions = widget.exercisedetail.sets.where((sets){
      return sets.ischecked as bool;
    }).toList();
    double monerm=0;
    for (int i = 0; i< suggestions.length; i++){
      if(suggestions[i].reps != 1){
        if(monerm < suggestions[i].weight * (1 + suggestions[i].reps / 30)){
          monerm = suggestions[i].weight * (1 + suggestions[i].reps / 30);
        }

      }else if(monerm < suggestions[i].weight){
        monerm = suggestions[i].weight;
      }

    }

    exerciseList.add(hisdata.Exercises(name: widget.exercisedetail.name, sets: suggestions , onerm: monerm, goal: widget.eachuniqueinfo[0].goal, date: DateTime.now().toString().substring(0,10)));

  }

  void _editHistoryCheck() async {
    print(_userdataProvider.userdata.email);
    HistoryPost(user_email: _userdataProvider.userdata.email, exercises: exerciseList, new_record: 120, workout_time: _routinetimeProvider.routineTime)
        .postHistory()
        .then((data) => data["user_email"] != null
        ? _historydataProvider.getdata()
        : showToast("입력을 확인해주세요"));
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _historydataProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _workoutdataProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _routinetimeProvider = Provider.of<RoutineTimeProvider>(context, listen: false);
    return Scaffold(
      appBar: _appbarWidget(),
      body: _exercisedetailWidget(),
    );
  }
}
