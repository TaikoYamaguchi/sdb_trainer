import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/navigators/exercise_navi.dart';
import 'package:sdb_trainer/pages/exercise.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/pages/login.dart';
import 'package:sdb_trainer/pages/signup.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/repository/user_repository.dart';

import 'statics.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  var _bodyStater;
  var _loginState;

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
        _bodyStater.change(index);
      },
      currentIndex: _bodyStater.bodystate,
      items: [
        _bottomNavigationBarItem("home", "홈"),
        _bottomNavigationBarItem("dumbel", "운동"),
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
        return Calendar();

      case 3:
        return Container(
            child: Center(
                child: FlatButton(
                    onPressed: () => _userLogOut(), child: Text("로그아웃"))));
    }
    return Container();
  }

  void _userLogOut() {
    UserLogOut.logOut();
    _loginState.change(false);
    _loginState.changeSignup(false);
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context);
    _loginState = Provider.of<LoginPageProvider>(context);
    return Scaffold(
      body: _loginState.isLogin
          ? _bodyWidget()
          : _loginState.isSignUp
              ? SignUpPage()
              : LoginPage(),
      bottomNavigationBar:
          _loginState.isLogin ? _bottomNavigationBarwidget() : null,
    );
  }
}
