import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/pages/exercise_done.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/src/utils/my_flexible_space_bar.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transition/transition.dart';
import 'package:tutorial/tutorial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChangeName extends StatefulWidget {
  int rindex;
  ChangeName({Key? key, required this.rindex}) : super(key: key);
  @override
  _ChangeNameState createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
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
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
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

    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        buttonPadding: EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.all(12.0),
        title: Text(
          '루틴 이름을 수정 해보세요',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('운동 루틴의 이름을 입력해 주세요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16)),
          Text('외부를 터치하면 취소 할 수 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12)),
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
        ]),
        actions: <Widget>[
          _workoutSubmitButton(context),
        ],
      );
    });
  }
}
