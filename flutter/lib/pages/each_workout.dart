import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/pages/exercise.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:transition/transition.dart';


class EachWorkoutDetails extends StatefulWidget {
  String workouttitle;
  List exerciselist;
  List uniqueinfo;
  EachWorkoutDetails({Key? key, required this.workouttitle, required this.exerciselist, required this.uniqueinfo}) : super(key: key);

  @override
  _EachWorkoutDetailsState createState() => _EachWorkoutDetailsState();
}

class _EachWorkoutDetailsState extends State<EachWorkoutDetails> {
  final controller = TextEditingController();
  var _exercisesdataProvider;
  var _testdata;
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
      title: Row(
        children: [
          Text(
            widget.workouttitle,
            style:TextStyle(color: Colors.white, fontSize: 30),
          ),
        ],
      ),
      actions: [
        IconButton(
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


  Widget _exercisesWidget(bool shirink) {
    return Container(
      color: Colors.black,
      child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index){
            final exinfo = widget.uniqueinfo.where((unique){
              final info = unique.name;
              return info.contains(widget.exerciselist[index].name);
            }).toList();
            if(index==0){top = 20; bottom = 0;} else if (index==widget.exerciselist.length-1){top = 0;bottom = 20;} else {top = 0;bottom = 0;};
            return GestureDetector(
              onTap: () {
                Navigator.push(context,Transition(
                    child: EachExerciseDetails(
                      exercisedetail: widget.exerciselist[index],
                      eachuniqueinfo: exinfo,
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
                                "1RM: ${exinfo[0].onerm}/${exinfo[0].goal}unit",
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
              onChanged: searchExercise,
            ),
          ),
          _exercisesWidget(true),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
            color: Color(0xFF212121),
            height: 20,
            child: Row(
              children: [
                Text(
                  "Not in List"
                ),
              ],
            ),
          ),
          ExerciseState.exercisesWidget(
              _testdata, true)
        ],
      ),
    );
  }

  void searchExercise(String query){
    final suggestions = _exercisesdataProvider.exercisesdata.where((exercises){
      final exTitle = exercises.name;
      final input = query;
      return exTitle.contains(input);
    }).toList();

    setState(() => _testdata = suggestions);
  }

  @override
  Widget build(BuildContext context) {
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _testdata = _exercisesdataProvider.exercisesdata;
    return Scaffold(
      appBar: _appbarWidget(),
      body: _isexsearch
      ? _exercises_searchWidget()
      : _exercisesWidget(false)
    );
  }
}