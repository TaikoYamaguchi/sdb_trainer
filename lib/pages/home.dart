import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentPageIndex=0;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 0;
  }

  BottomNavigationBarItem _bottomNavigationBarItem(
      String iconName, String label){
    return BottomNavigationBarItem(
      icon: SvgPicture.asset("assets/svg/${iconName}_off.svg"),
      label: label,
      backgroundColor: Colors.black
    );
  }
  
  Widget _bottomNavigationBarwidget(){
    return BottomNavigationBar(
      onTap: (int index) {
        print(index);
        setState(() {
          _currentPageIndex = index;
        });
      },
      currentIndex: _currentPageIndex,
      items: [
        _bottomNavigationBarItem("home", "홈"),
        _bottomNavigationBarItem("dumbel", "운동"),
        _bottomNavigationBarItem("calendar", "기록"),
        _bottomNavigationBarItem("profile", "프로필"),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "아라동",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [],
      ),
      bottomNavigationBar: _bottomNavigationBarwidget(),
    );
  }
}

