import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/pages/each_plan.dart';
import 'package:sdb_trainer/pages/each_workout.dart';
import 'package:sdb_trainer/pages/routine_bank.dart';
import 'package:sdb_trainer/pages/unique_exercise.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:tutorial/tutorial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Exercise extends StatefulWidget {
  final onPush;
  Exercise({Key? key, this.onPush}) : super(key: key);

  @override
  ExerciseState createState() => ExerciseState();
}

class ExerciseState extends State<Exercise> {
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  var _userdataProvider;
  var _exercisesdataProvider;
  var _workoutdataProvider;
  var _famousdataProvider;
  var _RoutineMenuProvider;
  var _PopProvider;
  var _PrefsProvider;
  bool modecheck = false;
  PageController? controller;
  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  String _title = "Workout List";
  var _customExUsed = false;

  var keyPlus = GlobalKey();
  var keyContainer = GlobalKey();
  var keyCheck = GlobalKey();
  var keySearch = GlobalKey();
  var keySelect = GlobalKey();

  List<TutorialItem> itens = [];

  @override
  void initState() {
    itens.addAll({
      TutorialItem(
          globalKey: keyPlus,
          touchScreen: true,
          top: 200,
          left: 50,
          children: [
            Text(
              "+버튼을 눌러 원하는 이름의 루틴을 추가하세요",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(
              height: 100,
            )
          ],
          widgetNext: Text(
            "아무곳을 눌러 진행",
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          shapeFocus: ShapeFocus.oval),
    });

    ///FUNÇÃO QUE EXIBE O TUTORIAL.

    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    if (swap == 1) {
      _title = "Workout List";
    } else {
      _title = "Exercise List";
    }
    ;
    return AppBar(
      title: Row(
        children: [
          Text(
            _title,
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          IconButton(
              iconSize: 30,
              onPressed: () {
                setState(() {
                  swap = swap * -1;
                });
              },
              icon: Icon(Icons.swap_horiz_outlined))
        ],
      ),
      actions: swap == 1
          ? [
              Consumer<RoutineMenuStater>(builder: (builder, provider, child) {
                if (provider.menustate == 0) {
                  return IconButton(
                    key: keyPlus,
                    icon: SvgPicture.asset("assets/svg/add_white.svg"),
                    onPressed: () {
                      _displayTextInputDialog();
                    },
                  );
                } else {
                  return IconButton(
                    iconSize: 30,
                    icon: Icon(Icons.refresh_rounded),
                    onPressed: () {
                      _onRefresh();
                    },
                  );
                }
              })
            ]
          : null,
      backgroundColor: Colors.black,
    );
  }

  Future<void> _onRefresh() {
    _famousdataProvider.getdata();
    return Future<void>.value();
  }

  Widget _workoutWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            height: 40,
            alignment: Alignment.center,
            color: Colors.black,
            child: Center(
              child: Consumer<RoutineMenuStater>(
                  builder: (builder, provider, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                        onTap: () {
                          controller!.animateToPage(0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut);
                          provider.change(0);
                        },
                        child: Text(
                          'My',
                          style: TextStyle(
                              //decoration: provider.menustate == 0 ? TextDecoration.underline : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                              color: provider.menustate == 0
                                  ? Theme.of(context).primaryColor
                                  : Color(0xFF717171)),
                        )),
                    GestureDetector(
                        onTap: () {
                          controller!.animateToPage(1,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut);
                          provider.change(1);
                        },
                        child: Text(
                          'Famous',
                          style: TextStyle(
                              //decoration: provider.menustate == 1 ? TextDecoration.underline : null,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: provider.menustate == 1
                                  ? Theme.of(context).primaryColor
                                  : Color(0xFF717171)),
                        ))
                  ],
                );
              }),
            ),
          ),
          Consumer<RoutineMenuStater>(builder: (builder, provider, child) {
            return _routinemenuPage();
          }),
        ],
      ),
    );
  }

  void _displayDeleteAlert(rindex) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            title: Text('루틴을 지울 수 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('정말로 루틴을 지우시나요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('루틴을 지우면 복구 할 수 없어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            actions: <Widget>[
              _DeleteConfirmButton(rindex),
            ],
          );
        });
  }

  Widget _routinemenuPage() {
    controller = PageController(initialPage: _RoutineMenuProvider.menustate);
    return Expanded(
      child: PageView(
        onPageChanged: (value) {
          _RoutineMenuProvider.change(value);
        },
        controller: controller,
        children: [
          _MyWorkout(),
          RoutineBank(),
        ],
      ),
    );
  }

  Widget _MyWorkout() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.black,
      child: Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
        List routinelist = provider.workoutdata.routinedatas;
        return routinelist.isEmpty
            ? GestureDetector(
                onTap: () {
                  _displayTextInputDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor),
                                child: Icon(
                                  Icons.add,
                                  size: 28.0,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("운동 루틴을 만들어 보세요",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                    Text("오른쪽 위를 클릭해도 만들 수 있어요",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 14)),
                                  ],
                                ),
                              )
                            ]),
                      ),
                    ),
                  ),
                ))
            : ReorderableListView.builder(
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = routinelist.removeAt(oldIndex);
                    routinelist.insert(newIndex, item);
                    _editWorkoutCheck();
                  });
                },
                padding: EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (BuildContext _context, int index) {
                  if (routinelist.length == 1) {
                    top = 20;
                    bottom = 20;
                  } else if (index == 0) {
                    top = 20;
                    bottom = 0;
                  } else if (index == routinelist.length - 1) {
                    top = 0;
                    bottom = 20;
                  } else {
                    top = 0;
                    bottom = 0;
                  }
                  ;
                  return GestureDetector(
                    key: Key('$index'),
                    onTap: () {
                      _PopProvider.exstackup(1);
                      routinelist[index].mode == 0
                          ? Navigator.push(
                              context,
                              Transition(
                                  child: EachWorkoutDetails(
                                    rindex: index,
                                  ),
                                  transitionEffect:
                                      TransitionEffect.RIGHT_TO_LEFT))
                          : Navigator.push(
                              context,
                              Transition(
                                  child: EachPlanDetails(
                                    rindex: index,
                                  ),
                                  transitionEffect:
                                      TransitionEffect.RIGHT_TO_LEFT));
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Slidable(
                            endActionPane: ActionPane(
                                extentRatio: 0.4,
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) {
                                      _displayRoutineNameEditDialog(index);
                                    },
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: '수정',
                                  ),
                                  SlidableAction(
                                    onPressed: (_) {
                                      _displayDeleteAlert(index);
                                    },
                                    backgroundColor: Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: '삭제',
                                  )
                                ]),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(top),
                                      bottomRight: Radius.circular(bottom),
                                      topLeft: Radius.circular(top),
                                      bottomLeft: Radius.circular(bottom))),
                              height: 52,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        routinelist[index].name,
                                        style: TextStyle(
                                            fontSize: 21, color: Colors.white),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          routinelist[index].mode == 1
                                              ? Text("Program Mode",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF717171)))
                                              : Text(
                                                  "${routinelist[index].exercises.length} Exercises",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Color(0xFF717171))),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          index == routinelist.length - 1
                              ? Container()
                              : Container(
                                  alignment: Alignment.center,
                                  height: 1,
                                  color: Color(0xFF212121),
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    height: 1,
                                    color: Color(0xFF717171),
                                  ),
                                )
                        ],
                      ),
                    ),
                  );
                },
                itemCount: routinelist.length);
      }),
    );
  }

  Widget _DeleteConfirmButton(rindex) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () {
              _workoutdataProvider.removeroutineAt(rindex);
              _editWorkoutCheck();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("삭제",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _deleteWorkoutCheck(int id) async {
    WorkoutDelete(id: id).deleteWorkout().then((data) =>
        data["user_email"] != null
            ? _workoutdataProvider.getdata()
            : showToast("입력을 확인해주세요"));
  }

  static Widget exercisesWidget(exuniq, userdata, bool shirink) {
    double top = 0;
    double bottom = 0;
    return Container(
      color: Colors.black,
      child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index) {
            if (index == 0) {
              top = 20;
              bottom = 0;
            } else if (index == exuniq.length - 1) {
              top = 0;
              bottom = 20;
            } else {
              top = 0;
              bottom = 0;
            }
            return Container(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Theme.of(_context).cardColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(top),
                        bottomRight: Radius.circular(bottom),
                        topLeft: Radius.circular(top),
                        bottomLeft: Radius.circular(bottom))),
                height: 52,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exuniq[index].name,
                      style: TextStyle(fontSize: 21, color: Colors.white),
                    ),
                    Container(
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Rest: need to set",
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF717171))),
                          Expanded(child: SizedBox()),
                          Text(
                              "1RM: " +
                                  exuniq[index].onerm.toStringAsFixed(1) +
                                  "/${exuniq[index].goal.toStringAsFixed(1)}${userdata.weight_unit}",
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF717171))),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext _context, int index) {
            return Container(
              alignment: Alignment.center,
              height: 1,
              color: Theme.of(_context).cardColor,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 1,
                color: Color(0xFF717171),
              ),
            );
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: shirink,
          itemCount: exuniq.length),
    );
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userdataProvider.userdata.email,
            exercises: _exercisesdataProvider.exercisesdata.exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exercisesdataProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  Widget exercisesWidget2(bool shirink) {
    double top = 0;
    double bottom = 0;
    return Container(
      color: Colors.black,
      child: Consumer2<ExercisesdataProvider, UserdataProvider>(
          builder: (builer, exercise, user, child) {
        var _userdata = user.userdata;
        var _exunique = exercise.exercisesdata.exercises;

        return ReorderableListView.builder(
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = _exunique.removeAt(oldIndex);
              _exunique.insert(newIndex, item);
              _postExerciseCheck();
            });
          },
          padding: EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (BuildContext _context, int index) {
            if (index == 0) {
              top = 20;
              bottom = 0;
            } else if (index == _exunique.length - 1) {
              top = 0;
              bottom = 20;
            } else {
              top = 0;
              bottom = 0;
            }
            return GestureDetector(
              key: Key('$index'),
              onTap: () {
                Navigator.push(
                    context,
                    Transition(
                        child: UniqueExerciseDetails(
                          ueindex: index,
                        ),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
              },
              child: Container(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          color: Theme.of(_context).cardColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(top),
                              bottomRight: Radius.circular(bottom),
                              topLeft: Radius.circular(top),
                              bottomLeft: Radius.circular(bottom))),
                      height: 52,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _exunique[index].name,
                            style: TextStyle(fontSize: 21, color: Colors.white),
                          ),
                          Container(
                            child: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("Rest: need to set",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF717171))),
                                Expanded(child: SizedBox()),
                                Text(
                                    "1RM: ${_exunique[index].onerm.toStringAsFixed(1)}/${_exunique[index].goal.toStringAsFixed(1)}${_userdata.weight_unit}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF717171))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    index == _exunique.length - 1
                        ? Container()
                        : Container(
                            alignment: Alignment.center,
                            height: 1,
                            color: Color(0xFF212121),
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              height: 1,
                              color: Color(0xFF717171),
                            ),
                          )
                  ],
                ),
              ),
            );
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: shirink,
          itemCount: _exunique.length,
        );
      }),
    );
  }

  Widget _bodyWidget() {
    switch (swap) {
      case 1:
        return _workoutWidget();

      case -1:
        return exercisesWidget2(false);
    }
    return Container();
  }

  void _displayTextInputDialog() {
    _RoutineMenuProvider.modereset();
    showDialog(
        context: context,
        builder: (context) {
          Color getColor(Set<MaterialState> states) {
            const Set<MaterialState> interactiveStates = <MaterialState>{
              MaterialState.pressed,
            };
            if (states.any(interactiveStates.contains)) {
              return Theme.of(context).primaryColor;
            }
            return Colors.black26;
          }

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              buttonPadding: EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).cardColor,
              contentPadding: EdgeInsets.all(12.0),
              title: Text(
                '운동 루틴을 추가 해볼게요',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('운동 루틴의 이름을 입력해 주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('외부를 터치하면 취소 할 수 있어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      _workoutdataProvider.workoutdata.routinedatas
                          .indexWhere((routine) {
                        if (routine.name == _workoutNameCtrl.text) {
                          setState(() {
                            print("useddddddd");
                            _customExUsed = true;
                          });
                          return true;
                        } else {
                          setState(() {
                            print("nullllllllll");
                            _customExUsed = false;
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
                        hintStyle:
                            TextStyle(fontSize: 24.0, color: Colors.white)),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Program 모드',
                          style: TextStyle(fontSize: 12.0, color: Colors.white),
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
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      value: provider.ismodechecked,
                                      onChanged: (newvalue) {
                                        provider.modecheck();
                                      }));
                            })),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                _workoutSubmitButton(context),
              ],
            );
          });
        });
  }

  Widget _workoutSubmitButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: _workoutNameCtrl.text == "" || _customExUsed == true
                ? Color(0xFF212121)
                : Theme.of(context).primaryColor,
            textColor: Colors.white,
            disabledColor: Color(0xFF212121),
            disabledTextColor: Colors.white,
            padding: EdgeInsets.all(12.0),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () {
              if(!_customExUsed){
                _workoutdataProvider.addroutine(new Routinedatas(
                    name: _workoutNameCtrl.text,
                    mode: _RoutineMenuProvider.ismodechecked ? 1 : 0,
                    exercises: _RoutineMenuProvider.ismodechecked
                        ? [
                      new Program(
                          progress: 0, plans: [new Plans(exercises: [])])
                    ]
                        : [],
                    routine_time: 0));
                _editWorkoutCheck();
                _workoutNameCtrl.clear();
                Navigator.of(context, rootNavigator: true).pop();
              };

            },
            child: Text(_customExUsed == true ? "존재하는 루틴" : "새 루틴 추가",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _editWorkoutCheck() async {
    WorkoutEdit(
            user_email: _userdataProvider.userdata.email,
            id: _workoutdataProvider.workoutdata.id,
            routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? [showToast("done!"), _workoutdataProvider.getdata()]
            : showToast("입력을 확인해주세요"));
  }

  void _postWorkoutCheck() async {
    WorkoutPost(
            user_email: _userdataProvider.userdata.email,
            routinedatas: _workoutdataProvider.routinedatas)
        .postWorkout()
        .then((data) => data["user_email"] != null
            ? _workoutdataProvider.getdata()
            : showToast("입력을 확인해주세요"));
  }

  void _displayRoutineNameEditDialog(index) {
    showDialog(
        context: context,
        builder: (context) {
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
                    setState(() {
                      null;
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
                      hintStyle:
                          TextStyle(fontSize: 24.0, color: Colors.white)),
                ),
              ]),
              actions: <Widget>[
                _routineNameEditSubmitButton(context, index),
              ],
            );
          });
        });
  }

  Widget _routineNameEditSubmitButton(context, index) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: _workoutNameCtrl.text == ""
                ? Color(0xFF212121)
                : Theme.of(context).primaryColor,
            textColor: Colors.white,
            disabledColor: Color(0xFF212121),
            disabledTextColor: Colors.white,
            padding: EdgeInsets.all(12.0),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () {
              _editWorkoutNameCheck(_workoutNameCtrl.text, index);
              _workoutNameCtrl.clear();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("루틴 이름 수정",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _editWorkoutNameCheck(newname, index) async {
    _workoutdataProvider.namechange(index, newname);

    WorkoutEdit(
            user_email: _userdataProvider.userdata.email,
            id: _workoutdataProvider.workoutdata.id,
            routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? {showToast("done!"), _workoutdataProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);

    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _famousdataProvider = Provider.of<FamousdataProvider>(context, listen: false);
    _RoutineMenuProvider =
        Provider.of<RoutineMenuStater>(context, listen: false);
    _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);
    _PrefsProvider.eachworkouttutor
        ? _PrefsProvider.stepone
            ? [
                Future.delayed(Duration(milliseconds: 0)).then((value) {
                  Tutorial.showTutorial(context, itens);
                  _PrefsProvider.steponedone();
                }),
              ]
            : null
        : null;

    return Scaffold(
        appBar: _appbarWidget(),
        body: Consumer2<ExercisesdataProvider, WorkoutdataProvider>(
            builder: (context, provider1, provider2, widget) {
          if (provider2.workoutdata != null) {
            return _bodyWidget();
          }
          return Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }),
        backgroundColor: Colors.black);
  }
}
