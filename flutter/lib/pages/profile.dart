import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
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
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:in_app_review/in_app_review.dart';

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
          : Center(
              child: Column(
              children: [
                CircularProgressIndicator(),
              ],
            )),
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

  Widget _errorLogoutButton(context) {
    return SizedBox(
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
            disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
            padding: EdgeInsets.all(12.0),
          ),
          onPressed: () {
            userLogOut(context);
          },
          child:
              Text('로그아웃', style: TextStyle(fontSize: 16, color: Colors.white)),
        ));
  }

  void _sendEmail() async {
    String body = await _getEmailBody();
    var _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    final Email email = Email(
      body: body,
      subject: '[Supero 문의]',
      recipients: ['supero.corp@gmail.com'],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      String title =
          "${_userProvider.userdata.nickname}님 죄송합니다😭 \n\n기본 메일 앱을 사용할 수 없기 때문에 앱에서 바로 문의를 전송하기 어려운 상황입니다";
      String message =
          "아래 이메일로 연락주시면 친절하게 답변해드릴게요 :)\n\n- 이메일 : supero.corp@gmail.com";
      displayErrorAlert(context, title, message);
    }
  }

  Future<String> _getEmailBody() async {
    Map<String, dynamic> appInfo = await getAppInfo();
    Map<String, dynamic> deviceInfo = await getDeviceInfo();

    String body = "";

    body += "\n";
    body += "==============\n";
    body += "아래 내용과 오류 스크린샷을 보내주시면 큰 도움이 됩니다🙏\n";

    body += "이메일: ${_userProvider.userdata.email}\n";
    body += "닉네임: ${_userProvider.userdata.nickname}\n";

    appInfo.forEach((key, value) {
      body += "$key: $value\n";
    });

    deviceInfo.forEach((key, value) {
      body += "$key: $value\n";
    });

    body += "==============\n";

    return body;
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
                          Text("프로필", style: TextStyle(color: Colors.white)),
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
                        Text("목표 설정하기", style: TextStyle(color: Colors.white)),
                        Icon(Icons.chevron_right, color: Colors.white),
                      ]))),
          ElevatedButton(
              onPressed: () {
                _sendEmail();
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
                        Text("오류 알려주기", style: TextStyle(color: Colors.white)),
                        Icon(Icons.chevron_right, color: Colors.white),
                      ]))),
          ElevatedButton(
              onPressed: () {
                final _appStoreURL =
                    "https://apps.apple.com/kr/app/supero/id6444859542";
                final _playStoreURL =
                    "https://play.google.com/store/apps/details?id=com.tk_lck.supero";

                displayShareAlert(
                    context,
                    "Supero에서 같이 운동해요💪\n\n운동과 기록도 하고 무게도 올리고 공유 할 수 있어요😁\n\n아래 눌러서 설치해요",
                    "- PlayStore : ${_playStoreURL} \n\n- AppStore : ${_appStoreURL}");
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
                        Text("친구와 운동하기", style: TextStyle(color: Colors.white)),
                        Icon(Icons.chevron_right, color: Colors.white),
                      ]))),
          ElevatedButton(
              onPressed: () async {
                final InAppReview inAppReview = InAppReview.instance;
                print("gogo?");

                print(await inAppReview.isAvailable());
                inAppReview.openStoreListing(
                  appStoreId: '6444859542',
                );
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
                        Text("평점 남기기🙏", style: TextStyle(color: Colors.white)),
                        Icon(Icons.open_in_new, color: Colors.white),
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

          Consumer<ExercisesdataProvider>(builder: (builder, provider, child) {
            return ElevatedButton(
                onPressed: () {
                  provider.getdata_all().then((value) {
                    print(provider.exercisesdatas);
                  });
                },
                onLongPress: () {
                  ExerciseEditAll(exercisedatas: provider.exercisesdatas)
                      .editExercise();
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
                          Text("exercise_change",
                              style: TextStyle(color: Colors.white)),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ])));
          }),
          Consumer<HistorydataProvider>(builder: (builder, provider, child) {
            return ElevatedButton(
                onPressed: () {
                  provider.getHistorydataAllforChange().then((value) {
                    print(provider.historydataAllforChange.sdbdatas.length);
                  });
                },
                onLongPress: () {
                  //ExerciseEditAll(
                  //        exercisedatas: provider.exercisesdatas.exercisedatas)
                  //    .editExercise();
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
                          Text("history_change",
                              style: TextStyle(color: Colors.white)),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ])));
          }),
        ]),
      ),
    );
  }
}
