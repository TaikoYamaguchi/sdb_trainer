import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/navigators/exercise_navi.dart';
import 'package:sdb_trainer/navigators/profile_navi.dart';
import 'package:sdb_trainer/pages/exercise.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/pages/login.dart';
import 'package:sdb_trainer/pages/signup.dart';
import 'package:sdb_trainer/pages/profile.dart';
import 'package:sdb_trainer/pages/feed.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/repository/user_repository.dart';

import 'statics.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _bodyStater;
  var _loginState;
  int _currentIndex = 0;
  var _userdataProvider;

  BottomNavigationBarItem _bottomNavigationBarItem(
      String iconName, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset("assets/svg/${iconName}_off.svg"),
      activeIcon: SvgPicture.asset("assets/svg/${iconName}_on.svg"),
      label: label,
    );
  }

  Widget _bottomNavigationBarwidget() {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF212121),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      selectedFontSize: 20,
      unselectedItemColor: Color(0xFF717171),
      unselectedFontSize: 20,
      onTap: (int index) {
        print(index);
        setState(() {
          _bodyStater.change(index);
        });
      },
      currentIndex: _bodyStater.bodystate,
      items: [
        _bottomNavigationBarItem("home", "홈"),
        _bottomNavigationBarItem("dumbel", "운동"),
        _bottomNavigationBarItem("feed", "피드"),
        _bottomNavigationBarItem("calendar", "기록"),
        _bottomNavigationBarItem("profile", "프로필"),
      ],
    );
  }

  Widget _bodyWidget() {
    switch (_bodyStater.bodystate) {
      case 0:
        return Home();

      case 1:
        return TabNavigator();

      case 2:
        return Feed();

      case 3:
        return Calendar();

      case 4:
        return TabNavigator();
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context, listen: true);
    _loginState = Provider.of<LoginPageProvider>(context);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _userdataProvider.getUsersFriendsAll();
    return Scaffold(
      body: _loginState.isLogin
          ? IndexedStack(index: _bodyStater.bodystate, children: <Widget>[
              Home(),
              TabNavigator(),
              Feed(),
              Calendar(),
              TabProfileNavigator()
            ])
          : _loginState.isSignUp
              ? SignUpPage()
              : LoginPage(),
      bottomNavigationBar:
          _loginState.isLogin ? _bottomNavigationBarwidget() : null,
    );
  }
}
