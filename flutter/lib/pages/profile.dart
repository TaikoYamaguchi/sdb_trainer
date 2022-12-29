import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

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
  var _themeProvider;

  @override
  Widget build(BuildContext context) {
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // here the desired height
          child: AppBar(
            elevation: 0,
            title: Text("설정",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight)),
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
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight))))
            ],
            backgroundColor: Theme.of(context).canvasColor,
          )),
      body: _userProvider.userdata != null
          ? _profile(context)
          : Center(
              child: Column(
              children: [
                CircularProgressIndicator(),
              ],
            )),
    );
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
              color: Theme.of(context).primaryColorLight,
            ),
            disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
            padding: EdgeInsets.all(12.0),
          ),
          onPressed: () {
            userLogOut(context);
          },
          child: Text('로그아웃',
              textScaleFactor: 1.3,
              style: TextStyle(color: Theme.of(context).primaryColorLight)),
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
                          Text("프로필",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).primaryColorDark),
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
                        Text("목표 설정하기",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorDark),
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
                        Text("오류 알려주기",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorDark),
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
                        Text("친구와 운동하기",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorDark),
                      ]))),
          ElevatedButton(
              onPressed: () async {
                final InAppReview inAppReview = InAppReview.instance;
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
                        Text("평점 남기기🙏",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.open_in_new,
                            color: Theme.of(context).primaryColorDark),
                      ]))),
          Column(
            children: [
              Container(
                  color: Theme.of(context).cardColor,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("글자 크기 변경",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                        ]),
                  )),
              Container(
                  color: Theme.of(context).cardColor,
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Center(
                      child: CustomSlidingSegmentedControl(
                          height: 50.0,
                          isStretch: true,
                          initialValue: _themeProvider.userFontSize,
                          children: {
                            0.6: Text("가",
                                style: TextStyle(
                                    fontSize: 10.0,
                                    color:
                                        Theme.of(context).primaryColorLight)),
                            0.7: Text("가",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color:
                                        Theme.of(context).primaryColorLight)),
                            0.8: Text("가",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color:
                                        Theme.of(context).primaryColorLight)),
                            0.9: Text("가",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color:
                                        Theme.of(context).primaryColorLight)),
                            1.0: Text("가",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color:
                                        Theme.of(context).primaryColorLight)),
                          },
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).canvasColor,
                          ),
                          innerPadding: const EdgeInsets.all(4),
                          thumbDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).cardColor),
                          onValueChanged: (value) {
                            setState(() {
                              _themeProvider.setUserFontsize(value);
                            });
                          }),
                    ),
                  )),
            ],
          ),
          Column(
            children: [
              Container(
                  color: Theme.of(context).cardColor,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("테마 변경",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                        ]),
                  )),
              Container(
                  color: Theme.of(context).cardColor,
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Center(
                      child: CustomSlidingSegmentedControl(
                          height: 50.0,
                          isStretch: true,
                          initialValue: _themeProvider.userThemeDark,
                          children: {
                            "white": Text("화이트",
                                textScaleFactor: 1.1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).primaryColorLight)),
                            "dark": Text("블랙",
                                textScaleFactor: 1.1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).primaryColorLight)),
                          },
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).canvasColor,
                          ),
                          innerPadding: const EdgeInsets.all(4),
                          thumbDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).cardColor),
                          onValueChanged: (value) {
                            setState(() {
                              _themeProvider.setUserTheme(value);
                            });
                          }),
                    ),
                  )),
            ],
          ),

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
                        Text("로그아웃",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorDark),
                      ]))),
          SizedBox(height: 30),
          GestureDetector(
              onTap: () {
                displayPhotoDialog(context);
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
          Consumer<ExercisesdataProvider>(builder: (builder, provider, child) {
            return ElevatedButton(
                onPressed: () {
                  print('fuck');
                  provider.getdata_all().then((value) {
                    print(provider.exercisesdatas.exercisedatas[10].exercises[1]
                        .target[0]);
                  });
                },
                onLongPress: () {
                  ExerciseEditAll(
                          exercisedatas: provider.exercisesdatas.exercisedatas)
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
                              style: TextStyle(color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right, color: Theme.of(context).primaryColorLight),
                        ])));
          }),
          Consumer<HistorydataProvider>(builder: (builder, provider, child) {
            return ElevatedButton(
                onPressed: () {
                  print('fuck2');
                  provider.getHistorydataAllforChange().then((value) {
                    print(provider.historydataAllforChange.sdbdatas.length);
                  });
                },
                onLongPress: () {
                  HistoryEditAll(
                          sdbdatas: provider.historydataAllforChange.sdbdatas)
                      .editHistory();
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
                              style: TextStyle(color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right, color: Theme.of(context).primaryColorLight),
                        ])));
          }),

          Consumer<ExercisesdataProvider>(builder: (builder, provider, child) {
            return ElevatedButton(
                onPressed: () {
                  print('fuck3');
                  for (int n = 0; n < old_Ex.length; n++) {
                    extra_completely_new_Ex.removeWhere(
                        (element) => element.name == old_Ex[n].name);
                    print(extra_completely_new_Ex.length);
                  }

                  provider.getdata_all().then((value) {
                    print(provider.exercisesdatas.exercisedatas[0].exercises[1]
                        .target[0]);
                    for (int n = 0;
                        n < provider.exercisesdatas.exercisedatas.length;
                        n++) {
                      provider.exercisesdatas.exercisedatas[n].exercises
                          .addAll(extra_completely_new_Ex);
                    }
                  });
                },
                onLongPress: () {
                  ExerciseEditAll(
                          exercisedatas: provider.exercisesdatas.exercisedatas)
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
                          Text("exercise_add",
                              style: TextStyle(color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right, color: Theme.of(context).primaryColorLight),
                        ])));
          }),
          */
        ]),
      ),
    );
  }
}
