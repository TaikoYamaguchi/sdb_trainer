
import 'package:expandable/expandable.dart';
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

  Plans sample = new Plans(exercises: []);
  Plan_Exercises exsample = new Plan_Exercises(name: '벤치프레스', ref_name: '벤치프레스', sets: [Sets(index: 0, weight: 100, reps: 10, ischecked: false)], rest: 0);

  ExpandableController Controller = ExpandableController(
    initialExpanded: true,
  );



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
                            return Container(
                              child: Column(
                                children: [
                                  ExpandablePanel(
                                    controller: Controller,
                                      theme: const ExpandableThemeData(
                                        headerAlignment: ExpandablePanelHeaderAlignment.center,
                                        hasIcon: true,
                                        iconColor: Colors.white,
                                      ),
                                      header:Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(inplandata[index].name, style: TextStyle(color: Colors.white, fontSize: 20),),
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
    return Scaffold(
        appBar: _appbarWidget(),
        body: _Nday_RoutineWidget()
    );
  }
}
