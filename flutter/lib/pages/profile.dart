import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';

import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';

import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  final ImagePicker _picker = ImagePicker();
  var _userdataProvider;
  var _loginState;

  @override
  Widget build(BuildContext context) {
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    print("this is profileeeeeeeeee");
    return Scaffold(
      appBar: AppBar(
          title: Text("설정", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black),
      body: _userdataProvider.userdata != null
          ? _profile(context)
          : Center(child: CircularProgressIndicator()),
      backgroundColor: Colors.black,
    );
  }

  Future<void> _pickImg() async {
    final XFile? selectImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (selectImage != null) {
      dynamic sendData = selectImage.path;
      UserImageEdit(file: sendData).patchUserImage().then((data) {
        _userdataProvider.setUserdata(data);
      });
    }
  }

  Widget _profile(context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    Transition(
                        child: UserProfile(),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color(0xFF212121))),
              child: Consumer<UserdataProvider>(
                  builder: (builder, rpovider, child) {
                return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_userdataProvider.userdata.nickname,
                              style: TextStyle(color: Colors.white)),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ]));
              })),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    Transition(
                        child: ProfileGoal(),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color(0xFF212121))),
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
                  backgroundColor:
                      MaterialStateProperty.all(Color(0xFF212121))),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("로그아웃", style: TextStyle(color: Colors.white)),
                        Icon(Icons.chevron_right, color: Colors.white),
                      ]))),
          SizedBox(height: 30),
          GestureDetector(
              onTap: () {
                _pickImg();
              },
              child: _userdataProvider.userdata.image == ""
                  ? Icon(
                      Icons.account_circle,
                      color: Colors.grey,
                      size: 200.0,
                    )
                  : Consumer<UserdataProvider>(
                      builder: (builder, rpovider, child) {
                      return CircleAvatar(
                          radius: 100.0,
                          backgroundImage:
                              NetworkImage(_userdataProvider.userdata.image),
                          backgroundColor: Colors.transparent);
                    })),
        ]),
      ),
    );
  }

  void _userLogOut() {
    UserLogOut.logOut();
    _loginState.change(false);
    _loginState.changeSignup(false);
    _userdataProvider.setUserKakaoEmail(null);
    _userdataProvider.setUserKakaoName(null);
    _userdataProvider.setUserKakaoImageUrl(null);
    _userdataProvider.setUserKakaoGender(null);
  }
}
