import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class NameInputDialog extends StatefulWidget {
  int rindex;
  NameInputDialog({Key? key, required this.rindex}) : super(key: key);
  @override
  _NameInputDialogState createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<NameInputDialog> {
  var _hisProvider;
  var _routinetimeProvider;
  var _userProvider;
  var _workoutProvider;
  var _famousdataProvider;
  var backupwddata;
  var _PopProvider;
  var _PrefsProvider;
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  var _customRuUsed = false;
  var _ischecked = false;

  Widget _workoutSubmitButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor:
                  _workoutNameCtrl.text == "" || _customRuUsed == true
                      ? Color(0xFF212121)
                      : Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (!_customRuUsed && _workoutNameCtrl.text != "") {
                _editWorkoutNameCheck(_workoutNameCtrl.text);
                _workoutNameCtrl.clear();
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: Text(_customRuUsed == true ? "존재하는 루틴 이름" : "루틴 이름 수정",
                textScaleFactor: 1.7, style: TextStyle(color: Colors.white))));
  }

  void _editWorkoutNameCheck(newname) async {
    _workoutProvider.namechange(widget.rindex, newname);

    WorkoutEdit(
            user_email: _userProvider.userdata.email,
            id: _workoutProvider.workoutdata.id,
            routinedatas: _workoutProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? {showToast("done!"), _workoutProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  Widget _workoutSubmitButton2(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor:
                  _workoutNameCtrl.text == "" || _customRuUsed == true
                      ? Color(0xFF212121)
                      : Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Colors.white,
              ),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (!_customRuUsed && _workoutNameCtrl.text != "") {
                _workoutProvider.addroutine(Routinedatas(
                    name: _workoutNameCtrl.text,
                    mode: _ischecked ? 1 : 0,
                    exercises: _ischecked
                        ? [
                            Program(progress: 0, plans: [Plans(exercises: [])])
                          ]
                        : [],
                    routine_time: 0));
                _editWorkoutCheck();
                _workoutNameCtrl.clear();
                Navigator.of(context, rootNavigator: true).pop();
              }
              ;
            },
            child: Text(_customRuUsed == true ? "존재하는 루틴 이름" : "새 루틴 추가",
                textScaleFactor: 1.7, style: TextStyle(color: Colors.white))));
  }

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

  Widget NameInput() {
    String title = widget.rindex == -1 ? '운동 루틴을 추가 할게요' : '루틴 이름을 수정 해보세요';

    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        buttonPadding: EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.all(12.0),
        title: Text(
          title,
          textScaleFactor: 2.0,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('운동 루틴의 이름을 입력해 주세요',
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white)),
          Text('외부를 터치하면 취소 할 수 있어요',
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              _workoutProvider.workoutdata.routinedatas.indexWhere((routine) {
                if (routine.name == _workoutNameCtrl.text) {
                  setState(() {
                    _customRuUsed = true;
                  });
                  return true;
                } else {
                  setState(() {
                    _customRuUsed = false;
                  });
                  return false;
                }
              });
            },
            style: TextStyle(fontSize: 24.0, color: Colors.white),
            textAlign: TextAlign.center,
            controller: _workoutNameCtrl,
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
                hintText: "운동 루틴 이름",
                hintStyle: TextStyle(fontSize: 24.0, color: Colors.white)),
          ),
          widget.rindex == -1
              ? Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '플랜 모드',
                        textScaleFactor: 1.2,
                        style: TextStyle(color: Colors.white),
                      ),
                      Transform.scale(
                          scale: 1,
                          child: Consumer<RoutineMenuStater>(
                              builder: (builder, provider, child) {
                            return Theme(
                                data: ThemeData(
                                    unselectedWidgetColor: Colors.white),
                                child: Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Theme.of(context).primaryColor,
                                    value: _ischecked,
                                    onChanged: (newvalue) {
                                      setState(() {
                                        _ischecked = !_ischecked;
                                      });

                                      provider.modecheck();
                                    }));
                          })),
                    ],
                  ),
                )
              : Container(),
        ]),
        actions: <Widget>[
          widget.rindex == -1
              ? _workoutSubmitButton2(context)
              : _workoutSubmitButton(context),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);

    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);

    return NameInput();
  }
}
