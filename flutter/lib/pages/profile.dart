import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';

import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';

import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  final ImagePicker _picker = ImagePicker();
  var _userdataProvider;
  var _PopProvider;
  var _loginState;
  var _PrefsProvider;
  var _bodyStater;

  @override
  Widget build(BuildContext context) {
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
          title: Text("설정", style: TextStyle(color: Colors.white, fontSize: 25)),
          actions: [
            Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                    onPressed: () {
                      _PopProvider.tutorpopon();

                      Future.delayed(Duration(milliseconds: 400)).then((value) {
                        _bodyStater.change(1);
                      });
                      _PrefsProvider.tutorstart();
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).cardColor)),
                    child: Text('튜토리얼', style: TextStyle(color: Colors.white))))
          ],
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
                _PopProvider.profilestackup();
                Navigator.push(
                    context,
                    Transition(
                        child: UserProfile(),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).cardColor)),
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
                _PopProvider.profilestackup();
                Navigator.push(
                    context,
                    Transition(
                        child: ProfileGoal(),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).cardColor)),
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
                      MaterialStateProperty.all(Theme.of(context).cardColor)),
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
                      return CachedNetworkImage(
                        imageUrl: _userdataProvider.userdata.image,
                        imageBuilder: (context, imageProivder) => Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              image: DecorationImage(
                                image: imageProivder,
                                fit: BoxFit.cover,
                              )),
                        ),
                      );
                    })),

          //ex back end 바꾸는 코드임 절대 지우지 말것
          /*


          Consumer<ExercisesdataProvider>(
            builder: (builder, provider, child) {
              return ElevatedButton(
                  onPressed: () {
                    provider.getdata_all().then((value){print(provider.exercisesdatas.exercisedatas[10].exercises[1].target[0]);});

                  },
                  onLongPress: (){
                    ExerciseEditAll(exercisedatas: provider.exercisesdatas.exercisedatas).editExercise();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).cardColor)),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("exercise_change", style: TextStyle(color: Colors.white)),
                            Icon(Icons.chevron_right, color: Colors.white),
                          ])));

            }
          ),

           */


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
