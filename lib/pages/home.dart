import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  PreferredSizeWidget _appbarWidget(){
    return AppBar(
      title: Text(
        "",
        style:TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset("assets/svg/chart.svg"),
          onPressed: () {
            print("press!");
          },
        )
      ],
      backgroundColor: Colors.black,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
    );
  }
}
