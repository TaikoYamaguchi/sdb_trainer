import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  var _selectImage;
  File? _image;
  var _userProvider;
  var _PopProvider;
  var _loginState;
  var _PrefsProvider;
  var _bodyStater;

  @override
  Widget build(BuildContext context) {
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // here the desired height
          child: AppBar(
              elevation: 0,
              title: Text("설정",
                  style: TextStyle(color: Colors.white, fontSize: 25)),
              actions: [
                Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                        onPressed: () {
                          _PopProvider.tutorpopon();

                          Future.delayed(Duration(milliseconds: 400))
                              .then((value) {
                            _bodyStater.change(1);
                          });
                          _PrefsProvider.tutorstart();
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).cardColor)),
                        child: Text('튜토리얼',
                            style: TextStyle(color: Colors.white))))
              ],
              backgroundColor: Color(0xFF101012))),
      body: _userProvider.userdata != null
          ? _profile(context)
          : Center(child: CircularProgressIndicator()),
      backgroundColor: Color(0xFF101012),
    );
  }

  Future<void> _pickImg() async {
    final XFile? selectImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (selectImage != null) {
      dynamic sendData = selectImage.path;
      UserImageEdit(file: sendData).patchUserImage().then((data) {
        _userProvider.setUserdata(data);
      });
    }
  }

  Future _getImage(ImageSource imageSource) async {
    _selectImage =
        await _picker.pickImage(source: imageSource, imageQuality: 30);
    if (_selectImage != null) {
      dynamic sendData = _selectImage.path;
      UserImageEdit(file: sendData).patchUserImage().then((data) {
        _userProvider.setUserdata(data);
      });
    }

    setState(() {
      _image = File(_selectImage!.path); // 가져온 이미지를 _image에 저장
    });
  }

  void _displayPhotoDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                      child: Text("사진을 올릴 방법을 고를 수 있어요",
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.0)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).primaryColor,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                disabledForegroundColor:
                                    Color.fromRGBO(246, 58, 64, 20),
                                padding: EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                _getImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 24, color: Colors.white),
                                  Text('촬영',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                ],
                              ),
                            )),
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context).primaryColor,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                disabledForegroundColor:
                                    Color.fromRGBO(246, 58, 64, 20),
                                padding: EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                _getImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.collections,
                                      size: 24, color: Colors.white),
                                  Text('갤러리',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
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
                          Text(_userProvider.userdata.nickname,
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
              onPressed: () => userLogOut(context),
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
                _displayPhotoDialog();
              },
              child: _userProvider.userdata.image == ""
                  ? Icon(
                      Icons.account_circle,
                      color: Colors.grey,
                      size: 200.0,
                    )
                  : Consumer<UserdataProvider>(
                      builder: (builder, rpovider, child) {
                      return CachedNetworkImage(
                        imageUrl: _userProvider.userdata.image,
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
    print("loggggggout");
    _userProvider.setUserKakaoEmail(null);
    _userProvider.setUserKakaoName(null);
    _userProvider.setUserKakaoImageUrl(null);
    _userProvider.setUserKakaoGender(null);
    UserLogOut.logOut();
    _loginState.change(false);
    _loginState.changeSignup(false);
  }
}
