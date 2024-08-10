import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/profile/appNotification.dart';
import 'package:sdb_trainer/pages/profile/interview.dart';
import 'package:sdb_trainer/pages/profile/userNotification.dart';
import 'package:sdb_trainer/providers/interviewdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/pages/profile/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/profile/userProfileGoal.dart';
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
  var _userProvider;
  var _PopProvider;
  var _themeProvider;
  var _interviewProvider;

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    _interviewProvider =
        Provider.of<InterviewdataProvider>(context, listen: false);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0), // here the desired height
          child: AppBar(
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("설정",
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ],
            ),
            actions: [],
            backgroundColor: Theme.of(context).canvasColor,
          )),
      body: _userProvider.userdata != null
          ? _profile(context)
          : const Center(
              child: Column(
              children: [
                CircularProgressIndicator(),
              ],
            )),
    );
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
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
            onTap: () {
              _PopProvider.profilestackup();
              Navigator.push(
                  context,
                  Transition(
                      child: UserProfile(),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Theme.of(context).cardColor,
                child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("프로필 편집하기",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).primaryColorDark),
                        ])))),
        GestureDetector(
            onTap: () {
              _PopProvider.profilestackup();
              Navigator.push(
                  context,
                  Transition(
                      child: AppNotification(),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Theme.of(context).cardColor,
                child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("공지사항📢",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).primaryColorDark),
                        ])))),
        GestureDetector(
            onTap: () {
              _PopProvider.profilestackup();
              Navigator.push(
                  context,
                  Transition(
                      child: UserNotification(),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Theme.of(context).cardColor,
                child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("알림 설정하기",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).primaryColorDark),
                        ])))),
        GestureDetector(
            onTap: () {
              _PopProvider.profilestackup();
              Navigator.push(
                  context,
                  Transition(
                      child: ProfileGoal(),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Theme.of(context).cardColor,
                child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("목표 설정하기",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).primaryColorDark),
                        ])))),
        GestureDetector(
            onTap: () {
              _sendEmail();
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Theme.of(context).cardColor,
                child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("오류 알려주기",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).primaryColorDark),
                        ])))),
        GestureDetector(
            onTap: () {
              const _appStoreURL =
                  "https://apps.apple.com/kr/app/supero/id6444859542";
              const _playStoreURL =
                  "https://play.google.com/store/apps/details?id=com.tk_lck.supero";

              displayShareAlert(
                  context,
                  "Supero에서 같이 운동해요💪\n\n운동과 기록도 하고 무게도 올리고 공유 할 수 있어요😁\n\n아래 눌러서 설치해요",
                  "- PlayStore : ${_playStoreURL} \n\n- AppStore : ${_appStoreURL}");
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Theme.of(context).cardColor,
                child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("친구와 운동하기👍",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).primaryColorDark),
                        ])))),
        GestureDetector(
            onTap: () async {
              final InAppReview inAppReview = InAppReview.instance;
              inAppReview.openStoreListing(
                appStoreId: '6444859542',
              );
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("평점 남기기🙏",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.open_in_new,
                            color: Theme.of(context).primaryColorDark),
                      ]),
                ))),
        GestureDetector(
            onTap: () async {
              _PopProvider.profilestackup();
              _interviewProvider.interviewdataAll == null
                  ? _interviewProvider.getInterviewdataFirst()
                  : null;
              Navigator.push(
                  context,
                  Transition(
                      child: Interview(),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("기능 제안하기👏",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorDark),
                      ]),
                ))),
        Container(
            color: Theme.of(context).cardColor,
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("글자 변경하기",
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
                              color: Theme.of(context).primaryColorLight)),
                      0.7: Text("가",
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context).primaryColorLight)),
                      0.8: Text("가",
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Theme.of(context).primaryColorLight)),
                      0.9: Text("가",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).primaryColorLight)),
                      1.0: Text("가",
                          style: TextStyle(
                              fontSize: 18.0,
                              color: Theme.of(context).primaryColorLight)),
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
        Container(
            color: Theme.of(context).cardColor,
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("테마 변경하기",
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
                              color: Theme.of(context).primaryColorLight)),
                      "dark": Text("블랙",
                          textScaleFactor: 1.1,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
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
        GestureDetector(
            onTap: () => userLogOut(context),
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("로그아웃",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorDark),
                      ]),
                ))),
        const SizedBox(height: 30),
        GestureDetector(
            onTap: () {
              displayPhotoDialog(context);
            },
            child: _userProvider.userdata.image == ""
                ? const Icon(
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
                                const BorderRadius.all(Radius.circular(50)),
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
                  print(provider
                      .exercisesdatas.exercisedatas[10].exercises[1].image);
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
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorLight),
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
/*
                for (int n = 0; n < delete_Ex.length; n++) {
                  extra_completely_new_Ex
                      .removeWhere((element) => element.name == delete_Ex[n]);
                }
                var after = jsonEncode(extra_completely_new_Ex);
                print(after);

   */
                provider.getdata_all().then((value) {
                  print(provider.exercisesdatas.exercisedatas[0].exercises[1]
                      .target[0]);
                  for (int n = 0;
                      n < provider.exercisesdatas.exercisedatas.length;
                      n++) {
//                      provider.exercisesdatas.exercisedatas[n].exercises
//                          .addAll(new_Ex);
                    provider.exercisesdatas.exercisedatas[n].exercises
                        .removeWhere((element) =>
                            element.name == '얼터네이팅 덤벨 바벨 벤치 프레스');
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
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorLight),
                      ])));
        }),
 */
      ]),
    );
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }
}
