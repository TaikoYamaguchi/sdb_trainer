import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/pages/exercise.dart';
import 'package:sdb_trainer/pages/home.dart';

import 'statics.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
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

  Widget _bodyWidget() {
    switch (_currentPageIndex) {
      case 0:
        return Home();
        break;
      case 1:
        return Exercise();
        break;
      case 2:
        return Calendar();
        break;
      case 3:
        return Container();
        break;
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarwidget(),
    );
  }
}

