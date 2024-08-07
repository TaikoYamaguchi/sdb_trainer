import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';

// ignore: must_be_immutable
class NameInputDialog extends StatefulWidget {
  int rindex;
  NameInputDialog({Key? key, required this.rindex}) : super(key: key);
  @override
  _NameInputDialogState createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<NameInputDialog> {
  var _userProvider;
  var _workoutProvider;
  var backupwddata;
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
                      ? const Color(0xFF212121)
                      : Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (!_customRuUsed && _workoutNameCtrl.text != "") {
                _editWorkoutNameCheck(_workoutNameCtrl.text);
                _workoutNameCtrl.clear();
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: Text(_customRuUsed == true ? "존재하는 루틴 이름" : "루틴 이름 수정",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).highlightColor))));
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
                      ? const Color(0xFF212121)
                      : Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              padding: const EdgeInsets.all(12.0),
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
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).highlightColor))));
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
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('운동 루틴의 이름을 입력해 주세요',
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight)),
          const Text('외부를 터치하면 취소 할 수 있어요',
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
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
            style: TextStyle(
                fontSize: 24.0, color: Theme.of(context).primaryColorLight),
            textAlign: TextAlign.center,
            controller: _workoutNameCtrl,
            decoration: InputDecoration(
                filled: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 1.5),
                ),
                hintText: "운동 루틴 이름",
                hintStyle: TextStyle(
                    fontSize: 24.0,
                    color: Theme.of(context).primaryColorLight)),
          ),
          widget.rindex == -1
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '플랜 모드',
                      textScaleFactor: 1.2,
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                    Transform.scale(
                        scale: 1,
                        child: Consumer<RoutineMenuStater>(
                            builder: (builder, provider, child) {
                          return Theme(
                              data: ThemeData(
                                  unselectedWidgetColor:
                                      Theme.of(context).primaryColorLight),
                              child: Checkbox(
                                  checkColor: Theme.of(context).highlightColor,
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
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);

    return NameInput();
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
