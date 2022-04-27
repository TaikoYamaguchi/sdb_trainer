import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';

import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';

import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  var _userdataProvider;
  var _loginState;

  @override
  Widget build(BuildContext context) {
    _loginState = Provider.of<LoginPageProvider>(context);
    _userdataProvider = Provider.of<UserdataProvider>(context);
    return Scaffold(
      appBar: AppBar(
          title: Text("설정", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black),
      body: Column(children: [
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  Transition(
                      child: UserProfile(),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF212121))),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_userdataProvider.userdata.nickname,
                          style: TextStyle(color: Colors.white)),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ]))),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  Transition(
                      child: ProfileGoal(),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF212121))),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("목표설정", style: TextStyle(color: Colors.white)),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ]))),
        ElevatedButton(
            onPressed: () => _userLogOut(),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF212121))),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("로그아웃", style: TextStyle(color: Colors.white)),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ]))),
      ]),
      backgroundColor: Colors.black,
    );
  }

  void _userLogOut() {
    UserLogOut.logOut();
    _loginState.change(false);
    _loginState.changeSignup(false);
  }
}
