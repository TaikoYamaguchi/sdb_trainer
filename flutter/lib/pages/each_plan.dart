
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

  Program sample = new Program(progress: 0, plans: [Plans(exercises: [new Plan_Exercises(name: '벤치프레스', ref_name: '벤치프레스', sets: [Sets(index: 0, weight: 100, reps: 10, ischecked: false)], rest: 0)])]);



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
                  child: Text('Nday', style: TextStyle(color: Colors.white, fontSize: 20), ),
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
                      //_workoutdataProvider.addexAt(widget.rindex,sample);
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
          Container(
            //child: Text
          )

        ],
      ),
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
