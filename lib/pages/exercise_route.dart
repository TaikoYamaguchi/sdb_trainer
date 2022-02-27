import 'package:flutter/material.dart';

class WorkoutRoute extends StatelessWidget {
  final String workouttitle;
  const WorkoutRoute({Key? key, @required this.workouttitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        Title: Text(workouttitle)
      ),
      body: ,
    );
  }
}
