import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';


class EachWorkoutDetails extends StatefulWidget {
  String workouttitle;
  List<wod.Exercises> exerciselist;
  List uniqueinfo;
  int routineindex;
  EachWorkoutDetails({Key? key, required this.workouttitle, required this.exerciselist, required this.uniqueinfo, required this.routineindex}) : super(key: key);

  @override
  _EachWorkoutDetailsState createState() => _EachWorkoutDetailsState();
}

class _EachWorkoutDetailsState extends State<EachWorkoutDetails> {
  var _userdataProvider;
  final controller = TextEditingController();
  var _exercisesdataProvider;
  var _testdata0;
  late var _testdata = _testdata0;

  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  bool _isexsearch=false;


  @override
  void initState() {
    super.initState();

  }

  PreferredSizeWidget _appbarWidget(){

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined),
        onPressed: (){
          //_editWorkoutCheck();
          Navigator.of(context).pop();
          //Provider.of<WorkoutdataProvider>(context, listen: false).getdata();
        },
      ),
      title: Row(
        children: [
          Text(
            widget.workouttitle,
            style:TextStyle(color: Colors.white, fontSize: 30),
          ),
        ],
      ),
      actions: [
        _isexsearch
            ? IconButton(
          iconSize: 30,
          icon: Icon(Icons.check_rounded),
          onPressed: () {
            _editWorkoutCheck();
            Provider.of<WorkoutdataProvider>(context, listen: false).getdata();
            setState(() {
              _isexsearch= !_isexsearch ;
            });
          },
        )
            : IconButton(
          icon: SvgPicture.asset("assets/svg/add.svg"),
          onPressed: () {

            setState(() {
              _isexsearch= !_isexsearch ;
            });
          },
        )
      ],
      backgroundColor: Colors.black,
    );
  }

  void _editWorkoutCheck() async {
    print(_userdataProvider.userdata.email);
    WorkoutEdit(user_email: _userdataProvider.userdata.email, name: widget.workouttitle,  exercises: widget.exerciselist)
        .editWorkout()
        .then((data) => data["user_email"] != null
        ? showToast("done!")
        : showToast("입력을 확인해주세요"));
  }


  Widget _exercisesWidget(bool shirink) {
    return Container(
      color: Colors.black,
      child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index){
            print(widget.exerciselist[index].name);
            print(widget.uniqueinfo[0].name);
            final exinfo = widget.uniqueinfo.where((unique){
              return (unique.name == widget.exerciselist[index].name);
            }).toList();
            print(exinfo);
            if(index==0){top = 20; bottom = 0;} else if (index==widget.exerciselist.length-1){top = 0;bottom = 20;} else {top = 0;bottom = 0;};
            return GestureDetector(
              onTap: () {
                _isexsearch
                ? setState(() {widget.exerciselist.removeAt(index);})
                : Navigator.push(context,Transition(
                    child: EachExerciseDetails(
                      exercisedetail: widget.exerciselist[index],
                      eachuniqueinfo: exinfo,
                      ueindex: widget.uniqueinfo.indexWhere((element) => element.name == widget.exerciselist[index].name),
                      eindex: index,
                      rindex: widget.routineindex,
                    ),
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
                        widget.exerciselist[index].name,
                        style: TextStyle(fontSize: 21, color: Colors.white),
                      ),

                      Container(
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                                "Rest: ${widget.exerciselist[index].rest}",
                                style: TextStyle(fontSize: 13, color: Color(0xFF717171))
                            ),
                            Expanded(child: SizedBox()),
                            Text(
                                "1RM: ${exinfo[0].onerm}/${exinfo[0].goal.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
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
          shrinkWrap: shirink,
          itemCount: widget.exerciselist.length
      ),
    );
  }

  Widget _exercises_searchWidget() {

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: TextField(

              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Color(0xFF717171),),
                hintText: "Exercise Name",
                hintStyle: TextStyle(fontSize: 20.0, color: Color(0xFF717171)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 3, color: Color(0xFF717171)),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (text) {
                searchExercise(text.toString());

              }
            ),
          ),
          AspectRatio(
            aspectRatio: 1.3,
              child: _exercisesWidget(true)
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
            color: Color(0xFF212121),
            height: 20,
            child: Row(
              children: [
                Text(
                  "Not in List",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          exercisesWidget(_testdata, true)

        ],
      ),
    );
  }

  Widget exercisesWidget(exuniq, bool shirink) {
    List existlist=[];
    for (int i = 0; i< widget.exerciselist.length; i++){
      existlist.add(widget.exerciselist[i].name);
    }
    double top = 0;
    double bottom = 0;
    return Expanded(
      //color: Colors.black,
      child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index) {
            bool alreadyexist = existlist.contains(exuniq[index].name);
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
              onTap: (){
                setState(() {
                  alreadyexist ? print("already") : widget.exerciselist.add(new wod.Exercises(name: exuniq[index].name, sets: wod.setslist, onerm: exuniq[index].onerm, rest: 0));
                });

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
                        style: TextStyle(fontSize: 21, color: alreadyexist ? Colors.black : Colors.white),
                      ),
                      Container(
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Rest: need to set",
                                style: TextStyle(
                                    fontSize: 13, color: alreadyexist ? Colors.black : Color(0xFF717171))),
                            Expanded(child: SizedBox()),
                            Text(
                                "1RM: ${exuniq[index].onerm}/${exuniq[index].goal.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
                                style: TextStyle(
                                    fontSize: 13, color: alreadyexist ? Colors.black : Color(0xFF717171))),
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
          itemCount: exuniq.length
      ),
    );
  }


  void searchExercise(String query){

    final suggestions = _testdata0.where((exercise){
      final exTitle = exercise.name;
      return (exTitle.contains(query)) as bool;
    }).toList();

    setState(() => _testdata = suggestions);
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _testdata0 = _exercisesdataProvider.exercisesdata.exercises;
    //for(int i = 0; i< widget.exerciselist.length; i++){
    //}
    print(_exercisesdataProvider.exercisesdata.exercises.length);
    return Scaffold(
      appBar: _appbarWidget(),
      body: _isexsearch
      ? _exercises_searchWidget()
      : _exercisesWidget(false)
    );

  }
}
