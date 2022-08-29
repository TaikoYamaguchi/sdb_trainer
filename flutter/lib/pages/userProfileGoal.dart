import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';

class ProfileGoal extends StatefulWidget {
  @override
  _ProfileGoalState createState() => _ProfileGoalState();
}

class _ProfileGoalState extends State<ProfileGoal> {
  bool isLoading = false;
  var _userdataProvider;
  var _exercisesdataProvider;
  var _userNicknameCtrl;
  var _exerciseList;

  List<TextEditingController> _onermController = [];
  List<TextEditingController> _goalController = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _exerciseList = _exercisesdataProvider.exercisesdata.exercises;

    return Consumer<PopProvider>(builder: (Builder, provider, child) {
      bool _popable = provider.isprostacking;
      _popable == false
          ? null
          : [
              provider.profilestackdown(),
              provider.propopoff(),
              Future.delayed(Duration.zero, () async {
                Navigator.of(context).pop();
              })
            ];
      return Scaffold(appBar: _appbarWidget(), body: _signupExerciseWidget());
    });
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text(
        "",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _signupExerciseWidget() {
    return Container(
      color: Colors.black,
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                    Text("운동 정보 수정",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                    Text("목표치와 1rm을 설정해보세요",
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 120,
                              child: Text(
                                "운동",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              )),
                          Container(
                              width: 70,
                              child: Text("1rm",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center)),
                          Container(
                              width: 80,
                              child: Text("목표",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center))
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: ListView.separated(
                          itemBuilder: (BuildContext _context, int index) {
                            return Center(
                                child: _exerciseWidget(
                                    _exerciseList[index], index));
                          },
                          separatorBuilder: (BuildContext _context, int index) {
                            return Container(
                              alignment: Alignment.center,
                              height: 1,
                              color: Colors.black,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 1,
                                color: Color(0xFF717171),
                              ),
                            );
                          },
                          itemCount: _exerciseList.length),
                    ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ),
                    _weightSubmitButton(context),
                  ]))),
    );
  }

  Widget _exerciseWidget(Exercises, index) {
    _onermController.add(
        new TextEditingController(text: Exercises.onerm.toStringAsFixed(1)));
    _goalController.add(
        new TextEditingController(text: Exercises.goal.toStringAsFixed(1)));
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 120,
              child: Text(
                Exercises.name,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            Container(
              width: 70,
              child: TextFormField(
                  controller: _onermController[index],
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: Exercises.onerm.toStringAsFixed(1),
                      hintStyle: TextStyle(fontSize: 18, color: Colors.white)),
                  onChanged: (text) {
                    double changeweight;
                    if (text == "") {
                      changeweight = 0.0;
                    } else {
                      changeweight = double.parse(text);
                    }
                    setState(() {
                      _exerciseList[index].onerm = changeweight;
                    });
                  }),
            ),
            Container(
              width: 80,
              child: TextFormField(
                  controller: _goalController[index],
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: Exercises.goal.toStringAsFixed(1),
                      hintStyle: TextStyle(fontSize: 18, color: Colors.white)),
                  onChanged: (text) {
                    double changeweight;
                    if (text == "") {
                      changeweight = 0.0;
                    } else {
                      changeweight = double.parse(text);
                    }
                    setState(() {
                      _exerciseList[index].goal = changeweight;
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weightSubmitButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () => _postExerciseCheck(),
            child: Text(isLoading ? 'loggin in.....' : "운동 정보 수정",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userdataProvider.userdata.email,
            exercises: _exerciseList)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {
                showToast("수정 완료"),
                _exercisesdataProvider.getdata(),
                Navigator.pop(context)
              }
            : showToast("입력을 확인해주세요"));
  }
}
