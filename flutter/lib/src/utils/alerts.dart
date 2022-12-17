import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
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
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24))
                : new Text("앱이 업데이트 되었어요",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24)),
            content: new SingleChildScrollView(
              child: type == "r"
                  ? Column(
                      children: [
                        Text("빨리 점검을 끝내겠습니다",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        Text("양해 부탁드립니다",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    )
                  : Column(
                      children: [
                        Text("더 좋은 서비스를 제공해 드리기 위해",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        Text("앱을 업데이트 해주세요",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
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
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.white)),
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
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white)),
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
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white)),
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

Future<dynamic> showsimpleAlerts(layer ,rindex, eindex, context) {
  // layer 1: delete, 2: add ex cancel
  String title= '';
  String subtitle= '';
  String comment= '';
  switch (layer){
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
  };

  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Theme.of(context).cardColor,
          title: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              Text(comment,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: <Widget>[
            _DeleteConfirmButton_r(rindex, context),
          ],
        );
      });
}

Widget _DeleteConfirmButton_r (rindex, context) {
  var _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
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
              style: TextStyle(fontSize: 20.0, color: Colors.white))));
}

Widget _ExsearchOutButton(context) {
  var _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
  var _userProvider = Provider.of<UserdataProvider>(context, listen: false);
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
            //_workoutProvider.changebudata(widget.rindex);
            //_workoutNameCtrl.clear();
            //_exSearchCtrl.clear();
            //searchExercise(_exSearchCtrl.text);
            //setState(() {
            //  _isexsearch = !_isexsearch;
            //});
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text("편집 취소 하기",
              style: TextStyle(fontSize: 20.0, color: Colors.white))));
}

