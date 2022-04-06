import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



class EachExerciseDetails extends StatefulWidget {
  dynamic exercisedetail;
  List eachuniqueinfo;
  EachExerciseDetails({Key? key, required this.exercisedetail, required this.eachuniqueinfo}) : super(key: key);

  @override
  _EachExerciseDetailsState createState() => _EachExerciseDetailsState();
}

class _EachExerciseDetailsState extends State<EachExerciseDetails> {
  bool _isChecked = false;
  double top = 0;
  double bottom = 0;
  double? weight;
  int? reps;
  List<TextEditingController> weightController = [];
  List<TextEditingController> repsController = [];
  List<double> weightfor1rm = [];
  List<int> repsfor1rm = [];


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

  /*
  void onerm_cal(){
    double? new_weight;
    int? new_reps;
    if (weightController.text != "") {
      new_weight = double.parse(weightController.text);
    }
    else {
      new_weight = widget.exercisedetail.sets[index].weight
    }
    if (repsController.text != "") {
      new_reps = int.parse(repsController.text);
    }
    else {
      new_weight = widget.exercisedetail.sets[index].reps
    }
    setState(() {
      weight= new_weight;
    });
  }
  */

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
        onTap: (){
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
                  Text("Best 1RM: ${widget.eachuniqueinfo[0].onerm}/${widget.eachuniqueinfo[0].goal}unit", style: TextStyle(color: Color(0xFF717171), fontSize: 21),),
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
                    weightController.add(new TextEditingController());
                    repsController.add(new TextEditingController());
                    weightfor1rm.add(widget.exercisedetail.sets[index].weight);
                    repsfor1rm.add(widget.exercisedetail.sets[index].reps);
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
                                    value: widget.exercisedetail!.sets[index].ischecked,
                                    onChanged: (newvalue){
                                      setState(() {
                                        widget.exercisedetail.sets[index].ischecked = newvalue!;
                                      });
                                      print(widget.exercisedetail!.sets[index].ischecked!);
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
                            child: TextField(
                              controller: weightController[index],
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 21, color: Colors.white,),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "${weightfor1rm[index]}",
                                hintStyle: TextStyle(fontSize: 21, color: Colors.white,),
                              ),
                              onChanged: (text){
                                double changeweight;
                                if(text==""){
                                  changeweight = 0.0;
                                }
                                else {
                                  changeweight = double.parse(text);
                                }
                                setState(() {
                                  weightfor1rm[index] = changeweight;
                                });
                                print(text);
                                print(weightfor1rm[index]);
                              },
                            ),
                          ),

                          Container(
                            width: 35,
                            child: SvgPicture.asset("assets/svg/multiply.svg",color: Colors.white, height: 19)
                          ),

                          Container(
                            width:40,
                            child: TextField(
                              controller: repsController[index],
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 21, color: Colors.white,),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "${repsfor1rm[index]}",
                                hintStyle: TextStyle(fontSize: 21, color: Colors.white,),
                              ),
                              onChanged: (text){
                                int changereps;
                                if(text==""){
                                  changereps = 1;
                                }
                                else {
                                  changereps = int.parse(text);
                                }
                                setState(() {
                                  repsfor1rm[index] = changereps;
                                });
                              },
                            ),
                          ),

                          Container(
                            width: 70,
                            child:  (widget.exercisedetail.sets[index].reps != 1)
                            ?Text(
                              "${(weightfor1rm[index] * (1 + repsfor1rm[index]/30)).toStringAsFixed(1)}",
                              style: TextStyle(fontSize: 21,color: Colors.white),
                              textAlign: TextAlign.center,
                            )
                            :Text(
                              "${weightfor1rm[index]}",
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
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _exercisedetailWidget(),
    );
  }
}
