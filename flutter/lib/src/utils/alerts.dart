import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';

Future<dynamic> showUpdateVersion(_appUpdateVersion, context) {
  var type = _appUpdateVersion[_appUpdateVersion.length - 1];
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () => Future.value(false),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            title: type == "r"
                ? Text("긴급 점검 중 입니다",
                    textScaleFactor: 1.5,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight))
                : Text("앱이 업데이트 되었어요",
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
            content: SingleChildScrollView(
              child: type == "r"
                  ? Column(
                      children: [
                        Text("빨리 점검을 끝내겠습니다",
                            textScaleFactor: 1.3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Text("양해 부탁드립니다",
                            textScaleFactor: 1.3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                      ],
                    )
                  : Column(
                      children: [
                        Text("더 좋은 서비스를 제공해 드리기 위해",
                            textScaleFactor: 1.3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Text("앱을 업데이트 해주세요",
                            textScaleFactor: 1.3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                      ],
                    ),
            ),
            actions: <Widget>[
              type == "r"
                  ? Container()
                  : type == "b"
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
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
                                disabledForegroundColor:
                                    const Color.fromRGBO(246, 58, 64, 20),
                                padding: const EdgeInsets.all(12.0),
                              ),
                              child: Text("업데이트 하러가기",
                                  textScaleFactor: 1.7,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight)),
                              onPressed: () {
                                LaunchReview.launch(
                                    androidAppId: "com.tk_lck.supero",
                                    iOSAppId: "6444859542");
                                exit(0);
                              }))
                      : Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                                width: type == "b"
                                    ? MediaQuery.of(context).size.width
                                    : MediaQuery.of(context).size.width / 2.3,
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      foregroundColor:
                                          Theme.of(context).primaryColor,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      textStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                      disabledForegroundColor:
                                          const Color.fromRGBO(246, 58, 64, 20),
                                      padding: const EdgeInsets.all(12.0),
                                    ),
                                    child: Text("업데이트 하기",
                                        textScaleFactor: 1.7,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor)),
                                    onPressed: () {
                                      LaunchReview.launch(
                                          androidAppId: "com.tk_lck.supero",
                                          iOSAppId: "6444859542");
                                    })),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 3.5,
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        foregroundColor:
                                            const Color(0xFF101012),
                                        backgroundColor:
                                            const Color(0xFF101012),
                                        textStyle: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                        disabledForegroundColor:
                                            const Color(0xFF101012),
                                        padding: const EdgeInsets.all(12.0),
                                      ),
                                      child: Text("다음에",
                                          textScaleFactor: 1.7,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .highlightColor)),
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(false);
                                      })),
                            )
                          ],
                        ),
            ],
          ));
    },
  );
}

// ignore: camel_case_types, must_be_immutable
class showsimpleAlerts extends StatefulWidget {
  showsimpleAlerts(
      {Key? key,
      required this.layer,
      required this.rindex,
      required this.eindex,
      this.specificvar})
      : super(key: key);
  int layer;
  int rindex;
  int eindex;
  var specificvar;
  @override
  _showsimpleAlertsState createState() => _showsimpleAlertsState();
}

class _showsimpleAlertsState extends State<showsimpleAlerts> {
  // layer 1: delete, 2: add ex cancel
  String title = '';
  String subtitle = '';
  String comment = '';

  Widget _moveToExButton(context) {
    var _bodyStater = Provider.of<BodyStater>(context, listen: false);
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
              _bodyStater.change(1);
            },
            child: Text("바로 운동 하기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  Widget _DeleteConfirmButton_r(rindex, context) {
    var _workoutProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    var _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    void _editWorkoutCheck() async {
      WorkoutEdit(
              user_email: _userProvider.userdata.email,
              id: _workoutProvider.workoutdata.id,
              routinedatas: _workoutProvider.workoutdata.routinedatas)
          .editWorkout()
          .then((data) => data["user_email"] != null
              ? [showToast("done!"), _workoutProvider.getdata()]
              : showToast("입력을 확인해주세요"));
    }

    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Theme.of(context).highlightColor,
              ),
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              _workoutProvider.removeroutineAt(rindex);
              _editWorkoutCheck();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("삭제",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  Widget exSearchOutButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text("편집 취소 하기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  Widget _StartConfirmButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
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
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text("운동 시작 하기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  Widget _FinishConfirmButton(eindex, context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
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
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text(eindex == 1 ? "운동을 업로드 하는 중..." : "운동 종료 하기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  Widget _customDeleteButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
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
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text("커스텀 운동 삭제 하기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  Widget _deleteConfirmButton_History() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
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
              padding: const EdgeInsets.all(8.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text("삭제",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  Widget _deleteConfirmButton_User() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text("탈퇴",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.layer) {
      case 1:
        title = "루틴을 지울 수 있어요";
        subtitle = '정말로 루틴을 지우시나요?';
        comment = '루틴을 지우면 복구 할 수 없어요';
        break;
      case 2:
        title = "편집이 저장되지 않아요";
        subtitle = '루틴 편집을 종료하시겠나요?';
        comment = '오른쪽 위를 클릭하면 저장할 수 있어요';
        break;
      case 3:
        title = "운동을 시작 할 수 있어요";
        subtitle = '운동을 시작 할까요?';
        comment = '외부를 터치하면 취소 할 수 있어요';
        break;
      case 4:
        title = "운동을 추가했어요!";
        subtitle = '바로 운동을 시작 할까요?';
        comment = '외부를 터치하면 취소 할 수 있어요';
        break;
      case 5:
        title = "운동을 종료 할 수 있어요";
        subtitle = '운동을 종료 하시겠나요?';
        comment = '외부를 터치하면 취소 할 수 있어요';
        break;
      case 6:
        title = "커스텀운동을 삭제 할 수 있어요";
        subtitle = '커스텀운동을 삭제 하시겠나요?';
        comment = '외부를 터치하면 취소 할 수 있어요';
        break;
      case 7:
        title = "기록을 삭제 할 수 있어요";
        subtitle = '정말로 기록을 지우시나요?';
        comment = '외부를 터치하면 취소 할 수 있어요';
        break;
      case 8:
        title = "정말 탈퇴 하시나요?";
        subtitle = '더 많은 기능을 준비 중 이에요';
        comment = '데이터를 지우면 복구 할 수 없어요';
        break;
      case 9:
        title = "운동을 업로드 하는 중...";
        subtitle = '';
        comment = '';
        break;
    }
    ;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      backgroundColor: Theme.of(context).cardColor,
      title: Text(title,
          textScaleFactor: 1.5,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).primaryColorLight)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(subtitle,
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight)),
          Text(comment,
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
      actions: <Widget>[
        widget.layer == 1
            ? _DeleteConfirmButton_r(widget.rindex, context)
            : widget.layer == 2
                ? exSearchOutButton(context)
                : widget.layer == 3
                    ? _StartConfirmButton(context)
                    : widget.layer == 4
                        ? _moveToExButton(context)
                        : widget.layer == 5
                            ? _FinishConfirmButton(widget.eindex, context)
                            : widget.layer == 6
                                ? _customDeleteButton()
                                : widget.layer == 7
                                    ? _deleteConfirmButton_History()
                                    : _deleteConfirmButton_User(),
      ],
    );
  }
}

// ignore: camel_case_types, must_be_immutable
class newOnermAlerts extends StatefulWidget {
  newOnermAlerts(
      {Key? key,
      required this.onerm,
      required this.sets,
      required this.exercise})
      : super(key: key);
  double onerm;
  var sets;
  var exercise;
  @override
  _newOnermAlertsState createState() => _newOnermAlertsState();
}

class _newOnermAlertsState extends State<newOnermAlerts> {
  Widget _closeNewOnermButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
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
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("계속 운동 하기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    var _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    late ConfettiController _controllerCenter;
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 3));
    _controllerCenter.play();

    return AlertDialog(
      buttonPadding: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      backgroundColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.all(12.0),
      title: Text(
        '신기록을 달성했어요!',
        textScaleFactor: 1.5,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).primaryColorLight),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.exercise.name.length < 8
                    ? Text(
                        widget.exercise.name,
                        textScaleFactor: 1.9,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFffc60a8)),
                      )
                    : Flexible(
                        child: Text(
                          widget.exercise.name,
                          textScaleFactor: 1.7,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFffc60a8)),
                        ),
                      ),
                Center(
                  child: Text(
                      widget.onerm.toStringAsFixed(1) +
                          _userProvider.userdata.weight_unit,
                      textScaleFactor: 1.7,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFffc60a8),
                      )),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 120,
                        child: Center(
                            child: Text(
                          "${widget.sets.weight.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                          textScaleFactor: 1.5,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ))),
                    Container(
                        width: 20,
                        child: SvgPicture.asset("assets/svg/multiply.svg",
                            color: Colors.grey,
                            height: 16 * _themeProvider.userFontSize / 0.8)),
                    Container(
                        width: 120,
                        child: Center(
                            child: Text(
                          "${widget.sets.reps}회",
                          textScaleFactor: 1.5,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        )))
                  ],
                )
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _controllerCenter,
                blastDirectionality: BlastDirectionality
                    .explosive, // don't specify a direction, blast randomly
                shouldLoop:
                    true, // start again as soon as the animation is finished
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ], // manually specify the colors to be used
              ),
            )
          ])
        ],
      ),
      actions: <Widget>[
        _closeNewOnermButton(context),
      ],
    );
  }
}

Future<dynamic> exGoalEditAlert(context, exercise) async {
  var _exProvider;
  var _userProvider;

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userProvider.userdata.email,
            exercises: _exProvider.exercisesdata.exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  var _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  _userProvider = Provider.of<UserdataProvider>(context, listen: false);
  _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);

  var index = _exProvider.exercisesdata.exercises
      .indexWhere((element) => element.name == exercise.name);
  var _exOnermController = TextEditingController(
      text:
          _exProvider.exercisesdata.exercises[index].onerm.toStringAsFixed(1));
  var _exGoalController = TextEditingController(
      text: _exProvider.exercisesdata.exercises[index].goal.toStringAsFixed(1));

  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          buttonPadding: const EdgeInsets.all(12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.all(12.0),
          title: Text(
            '목표를 달성하셨나요?',
            textScaleFactor: 1.7,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("더 높은 목표를 설정해보세요!",
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              TextField(
                controller: _exOnermController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                style: TextStyle(
                  fontSize: 21 * _themeProvider.userFontSize / 0.8,
                  color: Theme.of(context).primaryColorLight,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    filled: true,
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    labelText: "1RM (" +
                        _exProvider.exercisesdata.exercises[index].name +
                        ")",
                    labelStyle: TextStyle(
                        fontSize: 16.0 * _themeProvider.userFontSize / 0.8,
                        color: Colors.grey),
                    hintText: "1RM",
                    hintStyle: TextStyle(
                        fontSize: 24.0 * _themeProvider.userFontSize / 0.8,
                        color: Theme.of(context).primaryColorLight)),
                onChanged: (text) {},
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _exGoalController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                style: TextStyle(
                  fontSize: 21 * _themeProvider.userFontSize / 0.8,
                  color: Theme.of(context).primaryColorLight,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    filled: true,
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    labelText: "목표 (" +
                        _exProvider.exercisesdata.exercises[index].name +
                        ")",
                    labelStyle: TextStyle(
                        fontSize: 16.0 * _themeProvider.userFontSize / 0.8,
                        color: Colors.grey),
                    hintText: "목표",
                    hintStyle: TextStyle(
                        fontSize: 24.0 * _themeProvider.userFontSize / 0.8,
                        color: Theme.of(context).primaryColorLight)),
                onChanged: (text) {},
              ),
            ],
          ),
          actions: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
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
                  disabledForegroundColor:
                      const Color.fromRGBO(246, 58, 64, 20),
                  padding: const EdgeInsets.all(12.0),
                ),
                child: Text('수정하기',
                    textScaleFactor: 1.5,
                    style: TextStyle(color: Theme.of(context).highlightColor)),
                onPressed: () {
                  _exProvider.putOnermGoalValue(
                      index,
                      double.parse(_exOnermController.text),
                      double.parse(_exGoalController.text));
                  _postExerciseCheck();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ),
          ],
        );
      });
}

// ignore: camel_case_types, must_be_immutable
class setWeightAlert extends StatefulWidget {
  setWeightAlert(
      {Key? key,
      required this.rindex,
      required this.pindex,
      required this.eindex})
      : super(key: key);
  int rindex;
  int pindex;
  int eindex;
  @override
  _setWeightAlertState createState() => _setWeightAlertState();
}

class _setWeightAlertState extends State<setWeightAlert> {
  var _userProvider;
  var _workoutProvider;
  var _routinemenuProvider;
  TextEditingController _additionalweightctrl = TextEditingController(text: "");
  var _menuList;

  Widget _posnegControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<RoutineMenuStater>(builder: (context, provider, child) {
        _menuList = <int, Widget>{
          0: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("중량 추가",
                textScaleFactor: 1.3,
                style: TextStyle(
                    color: provider.ispositive
                        ? Theme.of(context).highlightColor
                        : Theme.of(context).primaryColorLight)),
          ),
          1: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("중량 제거",
                  textScaleFactor: 1.3,
                  style: TextStyle(
                      color: provider.ispositive
                          ? Theme.of(context).primaryColorLight
                          : Theme.of(context).highlightColor))),
        };
        return Container(
          color: Theme.of(context).cardColor,
          child: CupertinoSlidingSegmentedControl(
              groupValue: provider.ispositive ? 0 : 1,
              children: _menuList,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              backgroundColor: Theme.of(context).cardColor,
              thumbColor: provider.ispositive
                  ? Theme.of(context).primaryColor
                  : Colors.red,
              onValueChanged: (i) {
                provider.boolchange();
              }),
        );
      }),
    );
  }

  void _editWorkoutwCheck() async {
    WorkoutEdit(
            id: _workoutProvider.workoutdata.id,
            user_email: _userProvider.userdata.email,
            routinedatas: _workoutProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) =>
            data["user_email"] != null ? null : showToast("입력을 확인해주세요"));
  }

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _routinemenuProvider =
        Provider.of<RoutineMenuStater>(context, listen: false);

    double input = _workoutProvider.workoutdata.routinedatas[widget.rindex]
        .exercises[widget.pindex].sets[widget.eindex].weight
        .abs();
    _additionalweightctrl.text = _workoutProvider
        .workoutdata
        .routinedatas[widget.rindex]
        .exercises[widget.pindex]
        .sets[widget.eindex]
        .weight
        .abs()
        .toString();
    _additionalweightctrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _additionalweightctrl.text.length));

    _routinemenuProvider.boolchangeto(_workoutProvider
                .workoutdata
                .routinedatas[widget.rindex]
                .exercises[widget.pindex]
                .sets[widget.eindex]
                .weight <
            0
        ? false
        : true);

    return AlertDialog(
      buttonPadding: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      backgroundColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.all(12.0),
      title: Text(
        '중량 추가/제거 가능해요',
        textScaleFactor: 1.5,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).primaryColorLight),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('피드에는 추가 중량만 기록돼요(몸무게제외)',
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight)),
          const SizedBox(height: 12),
          _posnegControllerWidget(),
          const SizedBox(height: 8),
          SizedBox(
            width: 150,
            child: Consumer2<RoutineMenuStater, WorkoutdataProvider>(
                builder: (context, provider, provider2, child) {
              return TextField(
                controller: _additionalweightctrl,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                style: TextStyle(
                  fontSize: 21 * _themeProvider.userFontSize / 0.8,
                  color: provider.ispositive
                      ? Theme.of(context).primaryColorLight
                      : Colors.red,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: Text(
                      provider.ispositive ? "+" : "-",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35 * _themeProvider.userFontSize / 0.8,
                        color: provider.ispositive
                            ? Theme.of(context).primaryColorLight
                            : Colors.red,
                      ),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                    filled: true,
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    hintText: "입력",
                    hintStyle: TextStyle(
                        fontSize: 21.0 * _themeProvider.userFontSize / 0.8,
                        color: provider.ispositive
                            ? Theme.of(context).primaryColorLight
                            : Colors.red)),
                onChanged: (text) {
                  input = double.parse(text);
                },
              );
            }),
          ),
        ],
      ),
      actions: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
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
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            child: Text('중량 추가/제거 하기',
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor)),
            onPressed: () {
              _workoutProvider.weightcheck(
                  widget.rindex,
                  widget.pindex,
                  widget.eindex,
                  _routinemenuProvider.ispositive ? input : -input);
              _editWorkoutwCheck();
              _additionalweightctrl.clear();
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ),
      ],
    );
  }
}

Future<dynamic> bodyWeightCtrlAlert(context, layer) async {
  var _userProvider;
  String title = '';
  String subtitle = '';
  String comment = '';

  _userProvider = Provider.of<UserdataProvider>(context, listen: false);
  var _userWeightController = TextEditingController(
      text: _userProvider.userdata.bodyStats.last.weight.toString());
  var _userWeightGoalController = TextEditingController(
      text: _userProvider.userdata.bodyStats.last.weight_goal.toString());

  switch (layer) {
    case 1:
      title = "몸무게를 기록 할게요";
      subtitle = '몸무게와 목표치를 바꿔보세요';
      comment = '오늘 몸무게 기록하기';
      break;
    case 2:
      title = "몸무게를 수정 할게요";
      subtitle = '몸무게와 목표치를 수정해보세요';
      comment = '몸무게 수정 하기';
      break;
  }
  ;

  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          buttonPadding: const EdgeInsets.all(12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.all(12.0),
          title: Text(
            title,
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle,
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              TextField(
                controller: _userWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                style: TextStyle(
                  fontSize: 21,
                  color: Theme.of(context).primaryColorLight,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    filled: true,
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    labelText: "몸무게",
                    labelStyle:
                        const TextStyle(fontSize: 16.0, color: Colors.grey),
                    hintText: "몸무게",
                    hintStyle: TextStyle(
                        fontSize: 24.0,
                        color: Theme.of(context).primaryColorLight)),
                onChanged: (text) {},
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _userWeightGoalController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                style: TextStyle(
                  fontSize: 21,
                  color: Theme.of(context).primaryColorLight,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    filled: true,
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    labelText: "목표 몸무게",
                    labelStyle:
                        const TextStyle(fontSize: 16.0, color: Colors.grey),
                    hintText: "목표 몸무게",
                    hintStyle: TextStyle(
                        fontSize: 24.0,
                        color: Theme.of(context).primaryColorLight)),
                onChanged: (text) {},
              ),
            ],
          ),
          actions: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
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
                  disabledForegroundColor:
                      const Color.fromRGBO(246, 58, 64, 20),
                  padding: const EdgeInsets.all(12.0),
                ),
                child: Text(comment,
                    textScaleFactor: 1.5,
                    style: TextStyle(color: Theme.of(context).highlightColor)),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                      .pop([_userWeightController, _userWeightGoalController]);
                },
              ),
            ),
          ],
        );
      });
}
