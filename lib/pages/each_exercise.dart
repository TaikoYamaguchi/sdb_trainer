
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/repository/contents_repository.dart';
import 'package:sdb_trainer/repository/routine_repository.dart';
import 'package:sdb_trainer/src/model/routinedata.dart';


class EachExerciseDetails extends StatefulWidget {
  dynamic exercisedetail;
  EachExerciseDetails({Key? key, required this.exercisedetail}) : super(key: key);

  @override
  _EachExerciseDetailsState createState() => _EachExerciseDetailsState();
}

class _EachExerciseDetailsState extends State<EachExerciseDetails> {
  bool _isChecked = false;
  final ContentsRepository contentsRepository = ContentsRepository();
  RoutinedataList? _routinedata;
  double top = 0;
  double bottom = 0;


  @override
  void initState() {
    super.initState();


  }

  PreferredSizeWidget _appbarWidget(){
    return AppBar(
      title: Text(
        "",
        style:TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }





  Future<Map<String, dynamic>> _loadContents() async {
    Map<String, dynamic> responseData =
    await contentsRepository.loadContentsFromLocation();
    return responseData;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Rest Timer off", style: TextStyle(color: Color(0xFF717171), fontSize: 21,fontWeight: FontWeight.bold,),),
                Text("Rest: ${widget.exercisedetail.rest}", style: TextStyle(color: Color(0xFF717171), fontSize: 14,fontWeight: FontWeight.bold,),),
              ],
            )
          ),
          Container(
            height: 130,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.exercisedetail.name, style: TextStyle(color: Colors.white, fontSize: 48),),
                Text("Best 1RM: ${widget.exercisedetail.onerm}", style: TextStyle(color: Color(0xFF717171), fontSize: 21),),
              ],
            )
          ),
          Container(
            padding: EdgeInsets.only(right: 10),
            height: 25,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: 70,
                    child: Text("Set",
                      style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.right,)
                ),
                Container(
                    width: 70,
                    child: Text("Weight()",
                      style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center,
                    )
                ),
                Container(
                  width:35
                ),
                Container(
                    width: 40,
                    child: Text("Reps",
                      style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center,
                    )
                ),
                Container(
                    width: 70,
                    child: Text("1RM",
                      style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center,
                    )
                ),
              ],
            )
          ),


          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext _context, int index){
                  return Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  checkColor: Colors.black,
                                  fillColor: MaterialStateProperty.resolveWith(getColor),
                                  value: _isChecked,
                                  onChanged: (value){
                                    setState(() {
                                      _isChecked = value!;
                                    });
                                    print(_isChecked);
                                  }
                                ),
                              ),
                              Text(
                                  "${index+1}",
                                  style: TextStyle(fontSize: 21,color: Colors.white)
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 70,
                          child: Text(
                            "${widget.exercisedetail.sets[index].weight}",
                            style: TextStyle(fontSize: 21,color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        Container(
                          width: 35,
                          child: SvgPicture.asset("assets/svg/multiply.svg",color: Colors.white, height: 19)
                        ),

                        Container(
                          width:40,
                          child: Text(
                            "${widget.exercisedetail.sets[index].reps}",
                            style: TextStyle(fontSize: 21,color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        Container(
                          width: 70,
                          child: Text(
                            "${widget.exercisedetail.sets[index].weight * widget.exercisedetail.sets[index].reps}",
                            style: TextStyle(fontSize: 21,color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext _context, int index){
                  return Container(
                    alignment: Alignment.center,
                    height:1, color: Colors.black,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height:1, color: Color(0xFF717171),
                    ),
                  );

                },
                itemCount: widget.exercisedetail.sets.length
            ),
          ),

        ],
      ),
    );
  }

  //Widget _bodyWidget() {
  //  return FutureBuilder<Map<String, dynamic>>(
  //      future: _loadContents(),
  //      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
  //        return _exercisedetailWidget(snapshot.data ?? {});
  //      }
  //  );
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _exercisedetailWidget(),
    );
  }
}
