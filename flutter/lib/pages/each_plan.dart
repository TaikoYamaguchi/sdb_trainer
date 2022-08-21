
import 'package:expandable/expandable.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';

class EachPlanDetails extends StatefulWidget {
  int rindex;
  EachPlanDetails({Key? key, required this.rindex}) : super(key: key);

  @override
  State<EachPlanDetails> createState() => _EachPlanDetailsState();
}


class _EachPlanDetailsState extends State<EachPlanDetails> {

  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  var _workoutdataProvider;
  var _historydataProvider;
  var _routinetimeProvider;
  var _userdataProvider;
  var _exercisesdataProvider;
  var _testdata0;
  late var _testdata = _testdata0;
  String _addexinput = '';

  Plans sample = new Plans(exercises: []);
  Plan_Exercises exsample = new Plan_Exercises(name: '벤치프레스', ref_name: '벤치프레스', sets: [Sets(index: 0, weight: 100, reps: 10, ischecked: false)], rest: 0);

  ExpandableController Controller = ExpandableController(initialExpanded: true,);
  List<ExpandableController> Controllerlist = [];



  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined),
        onPressed: () {
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
    return Consumer<WorkoutdataProvider>(
        builder: (builder, workout, child) {
          var plandata = workout.workoutdata.routinedatas[widget.rindex].exercises[0];
          var inplandata = plandata.plans[plandata.progress].exercises;
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
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                          },
                          icon: Icon(
                            Icons
                                .arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 20,
                          )),
                      Container(width: 10,),
                      Container(
                        child: Text('${plandata.progress+1}/${plandata.plans.length}day', style: TextStyle(color: Colors.white, fontSize: 20), ),
                      ),
                      Container(width: 10,),
                      IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                          },
                          icon: Icon(
                            Icons
                                .arrow_forward_ios_outlined,
                            color: Colors.white,
                            size: 20,
                          )),
                      Container(width: 10,),
                      IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                          },
                          icon: Icon(
                            Icons.remove_circle_outlined,
                            color: Colors.white,
                            size: 20,
                          )),

                      Container(
                        child: Text('/', style: TextStyle(color: Colors.white, fontSize: 20), ),),
                      IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            _workoutdataProvider.addexAt(widget.rindex,sample);
                            _editWorkoutCheck();
                          },
                          icon: Icon(
                            Icons.add_circle_outlined,
                            color: Colors.white,
                            size: 20,
                          )),
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
                      Container(
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
                                            Text(inplandata[index].name, style: TextStyle(color: Colors.white, fontSize: 20),),
                                            Container(width: 10,),
                                            inplandata[index].sets.isEmpty
                                            ? IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                                onPressed: () {
                                                  workout.plansetsplus(widget.rindex, index);
                                                },
                                                icon: Icon(
                                                  Icons.add_circle_outlined,
                                                  color: Colors.white,
                                                  size: 20,
                                                ))
                                            : Container(
                                              child: Text('기준: ${inplandata[index].ref_name}', style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),),
                                            )
                                          ],
                                        ),
                                      ),
                                      collapsed: Container(), // body when the widget is Collapsed, I didnt need anything here.
                                      expanded:  Container(
                                        child: ListView.builder(
                                          physics: new NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext _context, int setindex) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                setindex ==0
                                                ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(width: 10,),
                                                    Container(width: 10,),
                                                    IconButton(
                                                        padding: EdgeInsets.zero,
                                                        constraints: BoxConstraints(),
                                                        onPressed: () {
                                                          workout.plansetsminus(widget.rindex, index);
                                                        },
                                                        icon: Icon(
                                                          Icons.remove_circle_outlined,
                                                          color: Colors.white,
                                                          size: 20,
                                                        )),
                                                    Container(width: 10,),
                                                    IconButton(
                                                        padding: EdgeInsets.zero,
                                                        constraints: BoxConstraints(),
                                                        onPressed: () {
                                                          workout.plansetsplus(widget.rindex, index);
                                                        },
                                                        icon: Icon(
                                                          Icons.add_circle_outlined,
                                                          color: Colors.white,
                                                          size: 20,
                                                        )),
                                                  ],
                                                )
                                                : Container()
                                                ,

                                                Row(
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        '${inplandata[index].sets[setindex].weight.toStringAsFixed(1)} X ${inplandata[index].sets[setindex].reps}',
                                                        style: TextStyle(color: Colors.white, fontSize:18 ),),
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
                      Container(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 10,),

                            IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  workout.planremoveexAt(widget.rindex);
                                },
                                icon: Icon(
                                  Icons.remove_circle_outlined,
                                  color: Colors.white,
                                  size: 20,
                                )),
                            Container(width: 10,),
                            Container(width: 10,),

                            IconButton(
                                padding: EdgeInsets.zero,
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
                          ],
                        ),
                      ),
                      Center(
                        child: Container(
                            child: Text('운동 추가 제거', style: TextStyle(color: Colors.grey, fontSize: 15), )
                        ),
                      )

                    ],
                  ),
                ),

              ],
            ),
          );
        }
        );
  }

  void exselect(bool isadd, bool isex) {
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
            child: _exercises_searchWidget(isadd, isex)
          ),
        );
      },
    );
  }

  Widget _exercises_searchWidget(bool isadd, bool isex) {
    return Column(
      children: [
        Container(
          height: 15,
        ),
        Container(
          child: Text(isex ? '운동을 선택해주세요' : '기준 운동을 선택해주세요' , style: TextStyle(fontSize: 20.0, color: Color(0xFF212121),fontWeight: FontWeight.bold),),
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
        exercisesWidget(_testdata, true, isadd, isex)
      ],
    );
  }

  Widget exercisesWidget(exuniq, bool shirink, bool isadd, bool isex) {
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
                   }
                  }else if(isex){

                  }else{

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
    return Scaffold(
        appBar: _appbarWidget(),
        body: _Nday_RoutineWidget()
    );
  }
}
