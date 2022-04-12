import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  var _loginState;

  @override
  Widget build(BuildContext context) {
    _loginState = Provider.of<LoginPageProvider>(context);
    return Container(
        color: Colors.black,
        child: Center(
            child: FlatButton(
                onPressed: () => _userLogOut(),
                child: Text("로그아웃", style: TextStyle(color: Colors.white)))));
  }

  void _userLogOut() {
    UserLogOut.logOut();
    _loginState.change(false);
    _loginState.changeSignup(false);
  }
}
