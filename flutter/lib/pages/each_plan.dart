
import 'dart:ui';

import 'package:expandable/expandable.dart';
import 'package:sdb_trainer/pages/exercise_done.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:transition/transition.dart';

class EachPlanDetails extends StatefulWidget {
  int rindex;
  EachPlanDetails({Key? key, required this.rindex}) : super(key: key);

  @override
  State<EachPlanDetails> createState() => _EachPlanDetailsState();
}


class _EachPlanDetailsState extends State<EachPlanDetails> {

  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  TextEditingController _weightctrl = TextEditingController(text: "");
  TextEditingController _repsctrl = TextEditingController(text: "");
  var _workoutdataProvider;
  var _historydataProvider;
  var _routinetimeProvider;
  var _userdataProvider;
  var _exercisesdataProvider;
  var _testdata0;
  late var _testdata = _testdata0;
  String _addexinput = '';
  late List<hisdata.Exercises> exerciseList = [];
  var _exercises;

  Plans sample = new Plans(exercises: []);
  Plan_Exercises exsample = new Plan_Exercises(name: '벤치프레스', ref_name: '벤치프레스', sets: [Sets(index: 0, weight: 100, reps: 10, ischecked: false)], rest: 0);

  ExpandableController Controller = ExpandableController(initialExpanded: true,);
  List<ExpandableController> Controllerlist = [];



  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined),
        onPressed: () {
          _editWorkoutCheck();
          Navigator.of(context).pop();
        },
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              _displayTextInputDialog();
            },
            child: Container(
              child: Consumer<WorkoutdataProvider>(
                  builder: (builder, provider, child) {
                    return Text(
                      provider.workoutdata.routinedatas[widget.rindex].name,
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    );
                  }),
            ),
          ),
        ],
      ),
      actions: [IconButton(
          onPressed: (){
            
          },
          icon: Icon(Icons.settings,))
      ],
      backgroundColor: Colors.black,
    );
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
              _editWorkoutNameCheck(_workoutNameCtrl.text);
              _workoutNameCtrl.clear();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("workout 이름 제출",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _editWorkoutNameCheck(newname) async {
    _workoutdataProvider.namechange(widget.rindex, newname);

    WorkoutEdit(
        user_email: _userdataProvider.userdata.email,
        id: _workoutdataProvider.workoutdata.id,
        routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
        ? {showToast("done!"), _workoutdataProvider.getdata()}
        : showToast("입력을 확인해주세요"));
  }
  
  Widget _Nday_RoutineWidget(){
    return Consumer2<WorkoutdataProvider, ExercisesdataProvider>(
        builder: (builder, workout,exinfo, child) {
          var plandata = workout.workoutdata.routinedatas[widget.rindex].exercises[0];
          var inplandata = plandata.plans[plandata.progress].exercises;
          var uniqexinfo =  exinfo.exercisesdata.exercises;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 30,
                  child: Row(
                    children: [
                      Container(width: 10,),
                      IconButton(
                          padding: EdgeInsets.all(3),
                          constraints: BoxConstraints(),
                          onPressed: () {
                            if(plandata.progress==0){
                              _workoutdataProvider.setplanprogress(widget.rindex, plandata.plans.length-1);
                            }else{
                              _workoutdataProvider.setplanprogress(widget.rindex, plandata.progress-1);
                            }
                            _editWorkoutCheck();
                          },
                          icon: Icon(
                            Icons
                                .arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 20,
                          )),
                      Container(width: 10,),
                      Container(
                        child: Text('${plandata.progress+1}/${plandata.plans.length}day', style: TextStyle(color: Colors.white, fontSize: 25), ),
                      ),
                      Container(width: 10,),
                      IconButton(
                          padding: EdgeInsets.all(3),
                          constraints: BoxConstraints(),
                          onPressed: () {
                            if(plandata.progress==plandata.plans.length-1){
                              _workoutdataProvider.setplanprogress(widget.rindex, 0);
                            }else{
                              _workoutdataProvider.setplanprogress(widget.rindex, plandata.progress+1);
                            }
                            _editWorkoutCheck();
                          },
                          icon: Icon(
                            Icons
                                .arrow_forward_ios_outlined,
                            color: Colors.white,
                            size: 20,
                          )),
                      Container(width: 10,),
                      Transform.scale(
                        scale: 1.2,
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              if(plandata.plans.length != 1){
                                _workoutdataProvider.removeplanAt(widget.rindex);
                                if(plandata.progress!=0){
                                  _workoutdataProvider.setplanprogress(widget.rindex, plandata.progress-1);
                                }
                                _editWorkoutCheck();
                              }
                            },
                            icon: Icon(
                              Icons.remove_circle_outlined,
                              color: Colors.white,
                              size: 20,
                            )),
                      ),

                      Container(
                        child: Text(' /', style: TextStyle(color: Colors.white, fontSize: 20), ),),
                      Transform.scale(
                        scale: 1.2,
                        child: IconButton(
                            padding: EdgeInsets.all(5),
                            constraints: BoxConstraints(),
                            onPressed: () {
                              _workoutdataProvider.addplanAt(widget.rindex,sample);
                              _workoutdataProvider.setplanprogress(widget.rindex, plandata.progress+1);
                              _editWorkoutCheck();
                            },
                            icon: Icon(
                              Icons.add_circle_outlined,
                              color: Colors.white,
                              size: 20,
                            )),
                      ),
                    ],
                  ),
                ),
                Divider(
                  indent: 10,
                  thickness: 1.3,
                  color: Colors.grey,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      inplandata.isEmpty
                      ? Center(child: Container(
                          child: Column(
                            children: [
                              Container(height: 30,),
                              Text('오늘은 휴식데이!', style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),),
                              Container(height: 20,),
                              Text('운동을 추가 하지 않으면 휴식일입니다.', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),),
                              Container(height: 30,),
                        ],
                      )))
                      :Container(
                        child: ListView.builder(
                          physics: new NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext _context, int index) {
                            Controllerlist.add(ExpandableController(initialExpanded: true,));
                            return Container(
                              child: Column(
                                children: [
                                  ExpandablePanel(
                                    controller: Controllerlist[index],
                                      theme: const ExpandableThemeData(
                                        headerAlignment: ExpandablePanelHeaderAlignment.center,
                                        hasIcon: true,
                                        iconColor: Colors.white,
                                      ),
                                      header:Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                                child: Text(inplandata[index].name, style: TextStyle(color: Colors.white, fontSize: 20),),
                                              onTap: (){
                                                exselect(false, true, index);
                                              },
                                            ),
                                            Container(width: 10,),
                                            inplandata[index].sets.isEmpty
                                            ? Transform.scale(
                                              scale: 1.2,
                                              child: IconButton(
                                                  padding: EdgeInsets.all(5),
                                                  constraints: BoxConstraints(),
                                                  onPressed: () {
                                                    workout.plansetsplus(widget.rindex, index);
                                                    _editWorkoutCheck();
                                                  },
                                                  icon: Icon(
                                                    Icons.add_circle_outlined,
                                                    color: Colors.white,
                                                    size: 20,
                                                  )),
                                            )
                                            : Container(
                                              child: GestureDetector(
                                                child: Text('기준: ${inplandata[index].ref_name}', style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),),
                                                onTap: (){
                                                  exselect(false, false, index);

                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      collapsed: Container(), // body when the widget is Collapsed, I didnt need anything here.
                                      expanded:  Container(
                                        child: ListView.builder(
                                          physics: new NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext _context, int setindex) {
                                            var refinfo = uniqexinfo[uniqexinfo.indexWhere((element) => element.name == inplandata[index].ref_name)];
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                setindex ==0
                                                ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(width: 10,),
                                                    Container(width: 10,),
                                                    Transform.scale(
                                                      scale:1.2,
                                                      child: IconButton(
                                                          padding: EdgeInsets.all(5),
                                                          constraints: BoxConstraints(),
                                                          onPressed: () {
                                                            workout.plansetsminus(widget.rindex, index);

                                                          },
                                                          icon: Icon(
                                                            Icons.remove_circle_outlined,
                                                            color: Colors.white,
                                                            size: 20,
                                                          )),
                                                    ),
                                                    Container(width: 10,),
                                                    Transform.scale(
                                                      scale: 1.2,
                                                      child: IconButton(
                                                          padding: EdgeInsets.all(5),
                                                          constraints: BoxConstraints(),
                                                          onPressed: () {
                                                            workout.plansetsplus(widget.rindex, index);

                                                          },
                                                          icon: Icon(
                                                            Icons.add_circle_outlined,
                                                            color: Colors.white,
                                                            size: 20,
                                                          )),
                                                    ),
                                                  ],
                                                )
                                                : Container()
                                                ,

                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      child: Container(
                                                        child: Text(
                                                          '${(inplandata[index].sets[setindex].weight * refinfo.onerm/100).toStringAsFixed(1)}kg  X  ${inplandata[index].sets[setindex].reps}',
                                                          style: TextStyle(color: Colors.white, fontSize:20 ),),
                                                      ),
                                                      onTap: (){
                                                        setSetting(index, setindex);
                                                      },
                                                    ),
                                                    Theme(
                                                      data: ThemeData(unselectedWidgetColor: Colors.white),
                                                      child: Checkbox(
                                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          activeColor: Colors.white,
                                                          checkColor: Colors.black,

                                                          value: inplandata[index].sets[setindex].ischecked,
                                                          onChanged: (newvalue) {
                                                            workout.planboolcheck(widget.rindex, index, setindex, newvalue);

                                                        }
                                                      ),
                                                    )
                                                  ],
                                                ),


                                              ],
                                            );
                                          },
                                          shrinkWrap: true,
                                          itemCount: inplandata[index].sets.length,
                                        ),
                                      ) // body when the widget is Expanded
                                  ),
                                  Divider(
                                    indent: 10,
                                    thickness: 1.3,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            );

                          },
                          shrinkWrap: true,
                          itemCount: inplandata.length,
                        ),
                      ),
                      Container(height: 10,),
                      Container(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Transform.scale(
                              scale: 1.2,
                              child: IconButton(
                                  padding: EdgeInsets.all(5),
                                  constraints: BoxConstraints(),
                                  onPressed: () {
                                    workout.planremoveexAt(widget.rindex);
                                    _editWorkoutCheck();
                                  },
                                  icon: Icon(
                                    Icons.remove_circle_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  )),
                            ),


                            Container(width: 10,),
                            Container(
                                child: Text('/', style: TextStyle(color: Colors.white, fontSize: 20), )
                            ),
                            Container(width: 10,),
                            Transform.scale(
                              scale: 1.2,
                              child: IconButton(
                                  padding: EdgeInsets.all(5),
                                  constraints: BoxConstraints(),
                                  onPressed: () {
                                    exselect(true, false);
                                    exselect(true, true);
                                  },
                                  icon: Icon(
                                    Icons.add_circle_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  )),
                            ),

                          ],
                        ),
                      ),
                      Center(
                        child: Container(
                            child: Text('운동 제거/추가', style: TextStyle(color: Colors.grey, fontSize: 15), )
                        ),
                      )

                    ],
                  ),
                ),
                Container(child: Consumer<RoutineTimeProvider>(
                    builder: (builder, provider, child) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: provider.buttoncolor,
                            textStyle: const TextStyle(fontSize: 20)),
                        onPressed: () {

                        if (_routinetimeProvider.isstarted) {
                          recordExercise();
                          _editHistoryCheck();
                          _editWorkoutCheck();
                          Navigator.push(
                              context,
                              Transition(
                                  child: ExerciseDone(
                                      exerciseList: exerciseList,
                                      routinetime: _routinetimeProvider
                                          .routineTime),
                                  transitionEffect:
                                  TransitionEffect.RIGHT_TO_LEFT));
                        }
                        provider.routinecheck(widget.rindex);


                        },
                        child: Text(provider.routineButton),
                      );
                    }))

              ],
            ),
          );
        }
        );
  }

  void setSetting(int eindex, int sindex) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          height:220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.white,
          ),

          child: _setinfo(eindex, sindex)
        );
      },
    );
  }

  Widget _setinfo(int eindex, int sindex) {
    return Consumer2<WorkoutdataProvider,ExercisesdataProvider>(
      builder: (builder, workout, exinfo, child) {
        var plandata = workout.workoutdata.routinedatas[widget.rindex].exercises[0];
        var inplandata = plandata.plans[plandata.progress].exercises;
        var exdata = plandata.plans[plandata.progress].exercises[eindex];
        var setdata = exdata.sets[sindex];
        var uniqexinfo =  exinfo.exercisesdata.exercises[exinfo.exercisesdata.exercises.indexWhere((element) => element.name == exdata.ref_name)];
        _weightctrl.text = setdata.weight.toString();
        _repsctrl.text = setdata.reps.toString();
        double changeweight = 0.0;
        int changereps = 1;
        return Container(
          child: Column(
            children: [
              Container(height: 15,),
              Container(
                child: Text('기준 운동: ${uniqexinfo.name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ),
              Container(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/3,
                    child: Center(child: Text('기준 1rm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/3,
                    child: Center(child: Text('중량비(%)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/3,
                    child: Center(child: Text('횟수', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
                  ),
                ],
              ),
              Container(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/3 -10,
                    child:Center(child: Text(uniqexinfo.onerm.toStringAsFixed(1), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/3 -10 ,
                    child: Center(
                      child: TextField(
                        controller: _weightctrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 21, color: Colors.blue,),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 3, color: Colors.grey)
                          ),
                          hintText: "${setdata.weight}",
                          hintStyle: TextStyle(fontSize: 21, color: Colors.white,),),
                        onChanged: (text) {
                          if (text == "") {
                            changeweight = 0.0;
                          } else {
                            changeweight =
                                double.parse(text);
                          }

                        },
                      ),
                    ),

                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/3 -10,
                    child: Center(
                      child: TextField(
                        controller: _repsctrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 21, color: Colors.blue,),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 3, color: Colors.grey)
                          ),
                          hintText: "${setdata.weight}",
                          hintStyle: TextStyle(fontSize: 21, color: Colors.white,),),
                        onChanged: (text) {
                          if (text == "") {
                            changereps = 1;
                          } else {
                            changereps =
                                int.parse(text);
                          }
                        },
                      ),
                    ),

                  ),
                ],
              ),
              Container(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 50)),
                    ),
                      onPressed: (){
                        workout.plansetcheck(widget.rindex, eindex, sindex, changeweight, changereps);
                        Navigator.pop(context);
                        _editWorkoutCheck();
                      },
                      child: Text('완료', style: TextStyle(fontWeight: FontWeight.bold),)),
                  Container(width: 10,),
                ],
              ),

            ],
          ),

        );
      }
    );
  }

  void exselect(bool isadd, bool isex, [int where =0]) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height*2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Color(0xFF717171),
          ),

          child: Center(
            child: _exercises_searchWidget(isadd, isex, where)
          ),
        );
      },
    );
  }

  Widget _exercises_searchWidget(bool isadd, bool isex, int where) {
    return Column(
      children: [
        Container(
          height: 15,
        ),
        Container(
          child: Text(isex ? '운동을 선택해주세요' : '1RM 기준 운동을 선택해주세요' , style: TextStyle(fontSize: 20.0, color: Color(0xFF212121),fontWeight: FontWeight.bold),),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                hintText: "Exercise Name",
                hintStyle:
                TextStyle(fontSize: 20.0, color: Colors.white),

              ),
              onChanged: (text) {
                searchExercise(text.toString());
              }),
        ),
        exercisesWidget(_testdata, true, isadd, isex, where)
      ],
    );
  }

  Widget exercisesWidget(exuniq, bool shirink, bool isadd, bool isex, int where) {
    double top = 0;
    double bottom = 0;
    return Expanded(
      //color: Colors.black,
      child: Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {

        return ListView.separated(
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
              ;
              return GestureDetector(
                onTap: () {
                  if(isadd){
                   if(isex){
                     _addexinput = exuniq[index].name;
                     Navigator.pop(context);
                   } else {
                     _workoutdataProvider.planaddexAt(
                         widget.rindex,
                         new Plan_Exercises(
                             name: _addexinput,
                             ref_name: exuniq[index].name,
                             sets: [],
                             rest: 0));

                     Navigator.pop(context);
                     _editWorkoutCheck();
                   }
                  }else if(isex){
                    _workoutdataProvider.planchangeexnameAt(widget.rindex, where, exuniq[index].name);
                    Navigator.pop(context);
                    _editWorkoutCheck();

                  }else{
                    _workoutdataProvider.planchangeexrefnameAt(widget.rindex, where, exuniq[index].name);
                    Navigator.pop(context);
                    _editWorkoutCheck();

                  };
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
                          exuniq[index].name,
                          style: TextStyle(
                              fontSize: 21,
                              color: Colors.white),
                        ),
                        Container(
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Rest: need to set",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF717171))),
                              Expanded(child: SizedBox()),
                              Text(
                                  "1RM: ${exuniq[index].onerm.toStringAsFixed(1)}/${exuniq[index].goal.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF717171))),
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
            itemCount: exuniq.length);
      }),
    );
  }

  void recordExercise() {
    var exercise_all =
        _workoutdataProvider.routinedatas[widget.rindex].exercises[0].plans[_workoutdataProvider.routinedatas[widget.rindex].exercises[0].progress].exercises;
    for (int n = 0; n < exercise_all.length; n++) {
      var recordedsets = exercise_all[n].sets.where((sets) {
        return (sets.ischecked as bool && sets.weight != 0);
      }).toList();
      double monerm = 0;
      for (int i = 0; i < recordedsets.length; i++) {
        if (recordedsets[i].reps != 1) {
          if (monerm <
              recordedsets[i].weight * (1 + recordedsets[i].reps / 30)) {
            monerm = recordedsets[i].weight * (1 + recordedsets[i].reps / 30);
          }
        } else if (monerm < recordedsets[i].weight) {
          monerm = recordedsets[i].weight;
        }
      }
      var _eachex = _exercises[_exercises
          .indexWhere((element) => element.name == exercise_all[n].name)];
      if (!recordedsets.isEmpty) {
        exerciseList.add(hisdata.Exercises(
            name: exercise_all[n].name,
            sets: recordedsets,
            onerm: monerm,
            goal: _eachex.goal,
            date: DateTime.now().toString().substring(0, 10)));
      }

      if (monerm > _eachex.onerm) {
        modifyExercise(monerm, exercise_all[n].name);
      }
    }
    _postExerciseCheck();
  }

  void _editHistoryCheck() async {
    if (!exerciseList.isEmpty) {
      HistoryPost(
          user_email: _userdataProvider.userdata.email,
          exercises: exerciseList,
          new_record: 120,
          workout_time: _routinetimeProvider.routineTime,
          nickname: _userdataProvider.userdata.nickname)
          .postHistory()
          .then((data) => data["user_email"] != null
          ? {
        _historydataProvider.getdata(),
        _historydataProvider.getHistorydataAll(),
        exerciseList = []
      }
          : showToast("입력을 확인해주세요"));
    } else {
      print("no exercises");
    }
  }

  void modifyExercise(double newonerm, exname) {
    _exercises[_exercises.indexWhere((element) => element.name == exname)]
        .onerm = newonerm;
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
        user_email: _userdataProvider.userdata.email, exercises: _exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
        ? {showToast("수정 완료"), _exercisesdataProvider.getdata()}
        : showToast("입력을 확인해주세요"));
  }

  void searchExercise(String query) {
    final suggestions = _testdata0.where((exercise) {
      final exTitle = exercise.name;
      return (exTitle.contains(query)) as bool;
    }).toList();

    setState(() => _testdata = suggestions);
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
  
  
  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _testdata0 = _exercisesdataProvider.exercisesdata.exercises;
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    return Scaffold(
        appBar: _appbarWidget(),
        body: _Nday_RoutineWidget(),
        backgroundColor: Colors.black
    );
  }
}
