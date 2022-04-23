import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileNickname.dart';
import 'package:sdb_trainer/pages/userProfileBody.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _userdataProvider;
  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text(
        "",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _userProfileWidget() {
    return Column(children: [
      ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              Transition(
                  child: ProfileNickname(),
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
                ])),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              Transition(
                  child: ProfileBody(),
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
                  Text(
                      _userdataProvider.userdata.height.toString() +
                          _userdataProvider.userdata.height_unit +
                          "/" +
                          _userdataProvider.userdata.weight.toString() +
                          _userdataProvider.userdata.weight_unit,
                      style: TextStyle(color: Colors.white)),
                  Icon(Icons.chevron_right, color: Colors.white),
                ])),
      ),
      ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xFF212121))),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      _userdataProvider.userdata.height_unit +
                          "/" +
                          _userdataProvider.userdata.weight_unit,
                      style: TextStyle(color: Colors.white)),
                  Icon(Icons.chevron_right, color: Colors.white),
                ])),
      ),
      ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xFF212121))),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_userdataProvider.userdata.isMan ? "남성" : "여성",
                      style: TextStyle(color: Colors.white)),
                  Container(),
                ])),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context);
    return Scaffold(
        appBar: _appbarWidget(),
        body: _userProfileWidget(),
        backgroundColor: Colors.black);
  }
}
