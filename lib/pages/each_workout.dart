import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/repository/contents_repository.dart';
import 'package:transition/transition.dart';


class EachWorkoutDetails extends StatefulWidget {
  String workouttitle;
  List exerciselist;
  EachWorkoutDetails({Key? key, required this.workouttitle, required this.exerciselist}) : super(key: key);

  @override
  _EachWorkoutDetailsState createState() => _EachWorkoutDetailsState();
}

class _EachWorkoutDetailsState extends State<EachWorkoutDetails> {
  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;


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
            print("press!");
          },
        )
      ],
      backgroundColor: Colors.black,
    );
  }



  Widget _exercisesWidget() {
    return Container(
      color: Colors.black,
      child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index){
            if(index==0){top = 20; bottom = 0;} else if (index==widget.exerciselist.length-1){top = 0;bottom = 20;} else {top = 0;bottom = 0;};
            return GestureDetector(
              onTap: () {
                Navigator.push(context,Transition(
                    child: EachExerciseDetails(exercisedetail: widget.exerciselist[index]),
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
                                "1RM: ${widget.exerciselist[index].onerm}",
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
          itemCount: widget.exerciselist.length
      ),
    );
  }

  //Widget _bodyWidget() {
  //  return FutureBuilder<Map<String, dynamic>>(
  //      future: _loadContents(),
  //      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
  //        return _exercisesWidget(snapshot.data ?? {});
  //      }
  //  );
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _exercisesWidget(),
    );
  }
}
