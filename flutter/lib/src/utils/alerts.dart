import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
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
      required this.eindex})
      : super(key: key);
  int layer;
  int rindex;
  int eindex;
  @override
  _showsimpleAlertsState createState() => _showsimpleAlertsState();
}

class _showsimpleAlertsState extends State<showsimpleAlerts> {
  // layer 1: delete, 2: add ex cancel
  String title = '';
  String subtitle = '';
  String comment = '';

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
                ? ExsearchOutButton(context: context, rindex: widget.rindex)
                : widget.layer == 3
                    ? _StartConfirmButton(context)
                    : _moveToExButton(context),
      ],
    );
  }
}

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
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
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

class ExsearchOutButton extends StatefulWidget {
  ExsearchOutButton({Key? key, required this.context, required this.rindex})
      : super(key: key);
  int rindex;
  BuildContext context;
  @override
  _ExsearchOutButtonState createState() => _ExsearchOutButtonState();
}

class _ExsearchOutButtonState extends State<ExsearchOutButton> {
  var _workoutProvider;
  var _userProvider;

  Widget exoutbutton() {
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

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);

    return exoutbutton();
  }
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
