import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Exercise extends StatefulWidget {
  const Exercise({Key? key}) : super(key: key);

  @override
  _ExerciseState createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {

  PreferredSizeWidget _appbarWidget(){
    return AppBar(
      title: Text(
          "Workout List",
          style:TextStyle(color: Colors.white),
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

  Widget _bodyWidget() {
    return ListView.separated(
        itemBuilder: (BuildContext _context, int index){
          return Container(
            child: Text(
              index.toString(),
            ),
          );
        },
        separatorBuilder: (BuildContext _context, int index){
          return Container(height:1, color: Color(0xFF717171),);
        },
        itemCount: 3
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
