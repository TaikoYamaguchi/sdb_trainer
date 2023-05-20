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
  var _userProvider;
  var _exProvider;
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
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _exerciseList = _exProvider.exercisesdata.exercises;

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
    var _btnDisabled = false;
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              _btnDisabled == true
                  ? null
                  : [
                      Navigator.of(context).pop(),
                      _btnDisabled = true,
                    ];
            },
          ),
          title: Text(
            "",
            textScaleFactor: 2.5,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _signupExerciseWidget() {
    bool btnDisabled = false;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onPanUpdate: (details) {
          if (details.delta.dx > 0 && btnDisabled == false) {
            btnDisabled = true;
            Navigator.of(context).pop();
            print("Dragging in +X direction");
          }
        },
        child: Container(
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
                            textScaleFactor: 2.7,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.w600)),
                        Text("목표치와 1rm을 설정해보세요",
                            textScaleFactor: 1.3,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
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
                                    textScaleFactor: 1.5,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                    ),
                                  )),
                              Container(
                                  width: 70,
                                  child: Text("1rm",
                                      textScaleFactor: 1.5,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                      textAlign: TextAlign.center)),
                              Container(
                                  width: 80,
                                  child: Text("목표",
                                      textScaleFactor: 1.5,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
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
                              separatorBuilder:
                                  (BuildContext _context, int index) {
                                return Container(
                                  alignment: Alignment.center,
                                  height: 0.5,
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    height: 0.5,
                                    color: Theme.of(context).primaryColorDark,
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
        ));
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
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
            ),
            Container(
              width: 70,
              child: TextFormField(
                  controller: _onermController[index],
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).primaryColorLight),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: Exercises.onerm.toStringAsFixed(1),
                      hintStyle: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColorLight)),
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
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).primaryColorLight),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: Exercises.goal.toStringAsFixed(1),
                      hintStyle: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColorLight)),
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
              padding: EdgeInsets.all(8.0),
            ),
            onPressed: () => _postExerciseCheck(),
            child: Text(isLoading ? 'loggin in.....' : "운동 정보 수정",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).buttonColor))));
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userProvider.userdata.email, exercises: _exerciseList)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {
                showToast("수정 완료"),
                _exProvider.getdata(),
                Navigator.pop(context)
              }
            : showToast("입력을 확인해주세요"));
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
