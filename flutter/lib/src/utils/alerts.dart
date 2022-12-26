import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
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
                ? new Text("긴급 점검 중 입니다",
                    textScaleFactor: 1.5,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white))
                : new Text("앱이 업데이트 되었어요",
                    textAlign: TextAlign.center,
                    textScaleFactor: 2.0,
                    style: TextStyle(color: Colors.white)),
            content: new SingleChildScrollView(
              child: type == "r"
                  ? Column(
                      children: [
                        Text("빨리 점검을 끝내겠습니다",
                            textScaleFactor: 1.3,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                        Text("양해 부탁드립니다",
                            textScaleFactor: 1.3,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                      ],
                    )
                  : Column(
                      children: [
                        Text("더 좋은 서비스를 제공해 드리기 위해",
                            textScaleFactor: 1.3,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                        Text("앱을 업데이트 해주세요",
                            textScaleFactor: 1.3,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
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
                                  color: Colors.white,
                                ),
                                disabledForegroundColor:
                                    Color.fromRGBO(246, 58, 64, 20),
                                padding: EdgeInsets.all(12.0),
                              ),
                              child: new Text("업데이트 하러가기",
                                  textScaleFactor: 1.7,
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                LaunchReview.launch(
                                    androidAppId: "com.tk_lck.supero",
                                    iOSAppId: "6444859542");
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
                                        color: Colors.white,
                                      ),
                                      disabledForegroundColor:
                                          Color.fromRGBO(246, 58, 64, 20),
                                      padding: EdgeInsets.all(12.0),
                                    ),
                                    child: new Text("업데이트 하기",
                                        textScaleFactor: 1.7,
                                        style: TextStyle(color: Colors.white)),
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
                                        foregroundColor: Color(0xFF101012),
                                        backgroundColor: Color(0xFF101012),
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        disabledForegroundColor:
                                            Color(0xFF101012),
                                        padding: EdgeInsets.all(12.0),
                                      ),
                                      child: new Text("다음에",
                                          textScaleFactor: 1.7,
                                          style:
                                              TextStyle(color: Colors.white)),
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
    var _routineMenuProvider =
        Provider.of<RoutineMenuStater>(context, listen: false);
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
              _routineMenuProvider.change(1);
            },
            child: Text("바로 운동 하기",
                textScaleFactor: 1.5, style: TextStyle(color: Colors.white))));
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              _workoutProvider.removeroutineAt(rindex);
              _editWorkoutCheck();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("삭제",
                textScaleFactor: 1.5, style: TextStyle(color: Colors.white))));
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text("편집 취소 하기",
                textScaleFactor: 1.5, style: TextStyle(color: Colors.white))));
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text("운동 시작 하기",
                textScaleFactor: 1.5, style: TextStyle(color: Colors.white))));
  }

  Widget _FinishConfirmButton(context) {
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text("운동 종료 하기",
                textScaleFactor: 1.7, style: TextStyle(color: Colors.white))));
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
          style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(subtitle,
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white)),
          Text(comment,
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ],
      ),
      actions: <Widget>[
        widget.layer == 1
            ? _DeleteConfirmButton_r(widget.rindex, context)
            : widget.layer == 2
                ? exSearchOutButton(context)
                : widget.layer == 3
                    ? _StartConfirmButton(context)
                    : widget.layer == 3
                        ? _moveToExButton(context)
                        : _FinishConfirmButton(context),
      ],
    );
  }
}

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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("계속 운동 하기",
                textScaleFactor: 1.7, style: TextStyle(color: Colors.white))));
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
      buttonPadding: EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      backgroundColor: Theme.of(context).cardColor,
      contentPadding: EdgeInsets.all(12.0),
      title: Text(
        '신기록을 달성했어요!',
        textScaleFactor: 2.0,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
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
                        textScaleFactor: 3.2,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFffc60a8)),
                      )
                    : Flexible(
                        child: Text(
                          widget.exercise.name,
                          textScaleFactor: 2.4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFffc60a8)),
                        ),
                      ),
                Center(
                  child: Text(
                      widget.onerm.toStringAsFixed(1) +
                          _userProvider.userdata.weight_unit,
                      textScaleFactor: 2.7,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFffc60a8),
                      )),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 120,
                        child: Center(
                            child: Text(
                          "${widget.sets.weight.toStringAsFixed(1)}${_userProvider.userdata.weight_unit}",
                          textScaleFactor: 1.7,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ))),
                    Container(
                        width: 20,
                        child: SvgPicture.asset("assets/svg/multiply.svg",
                            color: Colors.grey,
                            height: 19 * _themeProvider.userFontSize / 0.8)),
                    Container(
                        width: 120,
                        child: Center(
                            child: Text(
                          "${widget.sets.reps}회",
                          textScaleFactor: 1.7,
                          style: TextStyle(
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

class exGoalEditAlert extends StatefulWidget {
  exGoalEditAlert({Key? key, required this.exercise}) : super(key: key);
  var exercise;
  @override
  _exGoalEditAlertState createState() => _exGoalEditAlertState();
}

class _exGoalEditAlertState extends State<exGoalEditAlert> {
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

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);

    var index = _exProvider.exercisesdata.exercises
        .indexWhere((element) => element.name == widget.exercise.name);
    var _exOnermController = TextEditingController(
        text: _exProvider.exercisesdata.exercises[index].onerm
            .toStringAsFixed(1));
    var _exGoalController = TextEditingController(
        text:
            _exProvider.exercisesdata.exercises[index].goal.toStringAsFixed(1));

    return AlertDialog(
      buttonPadding: EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      backgroundColor: Theme.of(context).cardColor,
      contentPadding: EdgeInsets.all(12.0),
      title: Text(
        '목표를 달성하셨나요?',
        textScaleFactor: 2.0,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("더 높은 목표를 설정해보세요!",
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          SizedBox(height: 20),
          TextField(
            controller: _exOnermController,
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: true),
            style: TextStyle(
              fontSize: 21 * _themeProvider.userFontSize / 0.8,
              color: Colors.white,
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
                    color: Colors.white)),
            onChanged: (text) {},
          ),
          TextField(
            controller: _exGoalController,
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: true),
            style: TextStyle(
              fontSize: 21 * _themeProvider.userFontSize / 0.8,
              color: Colors.white,
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
                    color: Colors.white)),
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            child: Text('수정하기',
                textScaleFactor: 1.7, style: TextStyle(color: Colors.white)),
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
  }
}

class setResttimeAlert extends StatefulWidget {
  setResttimeAlert({Key? key, required this.rindex}) : super(key: key);
  int rindex;
  @override
  _setResttimeAlertState createState() => _setResttimeAlertState();
}

class _setResttimeAlertState extends State<setResttimeAlert> {
  var _exProvider;
  var _userProvider;
  var _workoutProvider;
  var _routinetimeProvider;
  TextEditingController _resttimectrl = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);

    return AlertDialog(
      buttonPadding: EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      backgroundColor: Theme.of(context).cardColor,
      contentPadding: EdgeInsets.all(12.0),
      title: Text(
        '휴식 시간을 설정 해볼게요',
        textScaleFactor: 1.5,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('세트당 휴식 시간을 입력해주세요',
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white)),
          SizedBox(height: 20),
          TextField(
            controller: _resttimectrl,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 21 * _themeProvider.userFontSize / 0.8,
              color: Colors.white,
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
                hintText: "휴식 시간 입력(초)",
                hintStyle: TextStyle(
                    fontSize: 24.0 * _themeProvider.userFontSize / 0.8,
                    color: Colors.white)),
            onChanged: (text) {
              int changetime;
              changetime = int.parse(text);
              _routinetimeProvider.resttimecheck(changetime);
            },
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            child: Text('휴식 시간 설정하기',
                textScaleFactor: 1.5, style: TextStyle(color: Colors.white)),
            onPressed: () {
              _resttimectrl.clear();
              Navigator.of(context, rootNavigator: true).pop(true);
            },
          ),
        ),
      ],
    );
  }
}
