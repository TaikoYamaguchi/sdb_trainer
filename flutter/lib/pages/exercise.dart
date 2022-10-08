import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/pages/each_plan.dart';
import 'package:sdb_trainer/pages/each_workout.dart';
import 'package:sdb_trainer/pages/exercise_filter.dart';
import 'package:sdb_trainer/pages/routine_bank.dart';
import 'package:sdb_trainer/pages/unique_exercise.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
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
  var _routinetimeProvider;
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
                  _routinetimeProvider.isstarted
                  ? showToast("운동중엔 순서변경이 불가능 해요")
                  : setState(() {
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
                          Card(
                              color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            elevation: 8.0,
                            margin: new EdgeInsets.symmetric(horizontal: 6, vertical: 6.0),
                            child: Slidable(
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
                                        _routinetimeProvider.isstarted
                                            ? showToast("운동중엔 루틴제거는 불가능 해요")
                                            : _displayDeleteAlert(index);
                                      },
                                      backgroundColor: Color(0xFFFE4A49),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: '삭제',
                                    )
                                  ]),
                              child: Container(
                                child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5.0),
                                    leading: Container(
                                      height: double.infinity,
                                      padding: EdgeInsets.only(right: 15.0),
                                      decoration: new BoxDecoration(
                                          border: new Border(
                                              right: new BorderSide(width: 1.0, color: Colors.white24))),
                                      child: routinelist[index].mode == 0
                                          ? Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: SizedBox(
                                              width: 25,
                                              child: SvgPicture.asset("assets/svg/dumbel_on.svg",
                                              color: Colors.white30),
                                            ),
                                          )
                                          : CircularPercentIndicator(
                                            radius: 20,
                                            lineWidth: 5.0,
                                            animation: true,
                                            percent: (routinelist[index].exercises[0].progress+1)/routinelist[index].exercises[0].plans.length,
                                            center: new Text(
                                              "${routinelist[index].exercises[0].progress+1}/${routinelist[index].exercises[0].plans.length}",
                                              style:
                                              new TextStyle(color: Colors.white ,  fontSize: 10.0),
                                            ),
                                            circularStrokeCap: CircularStrokeCap.round,
                                            progressColor: Colors.purple,
                                          ),
                                    ),
                                    title: Text(
                                      routinelist[index].name,
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),

                                    subtitle: Row(
                                      children: [
                                        routinelist[index].mode == 0
                                            ? Text("${routinelist[index].exercises.length}개 운동",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white30))
                                            : Text("프로그램 모드",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white30)),
                                      ],
                                    ),
                                    trailing:
                                    Icon(Icons.keyboard_arrow_right, color: Colors.white30, size: 30.0)

                                ),
                              ),
                            )
                                /*
                            Container(
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
                                          routinelist[index].mode == 0
                                              ? Text("${routinelist[index].exercises.length} Exercises",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF717171)))
                                              : Text("Program Mode",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF717171))),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),

                                 */
                          ),

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
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).primaryColor,
              textStyle: TextStyle(color: Colors.white,),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              _workoutdataProvider.removeroutineAt(rindex);
              _editWorkoutCheck();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("삭제",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }




  void filterExercise(List query) {
    final suggestions = _exercisesdataProvider.exercisesdata.exercises.where((exercise) {
      if (query[0]=='All'){
        return true;
      } else {
        final extarget = Set.from(exercise.target);
        final query_s = Set.from(query);
        return (query_s.intersection(extarget).isNotEmpty) as bool;
      }
    }).toList();
    _exercisesdataProvider.settestdata_f1(suggestions);
  }

  Widget group_by_target() {
    return Container(
      child: GridView.builder(
        itemCount: 12,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 7/8,
          mainAxisSpacing: 10,

        ),
        itemBuilder: (BuildContext context, int index) {
          var key_list =ExImage().body_part_image.keys.toList();
          return GestureDetector(
            onTap: (){
              _exercisesdataProvider.inittestdata();
              _exercisesdataProvider.settags([key_list[index].toString()]);
              filterExercise(_exercisesdataProvider.tags);
              Navigator.push(
                  context,
                  Transition(
                      child: ExerciseFilter(),
                      transitionEffect: TransitionEffect.BOTTOM_TO_TOP));
            },
            child: Card(
              color: Colors.black,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: ExImage().body_part_image[key_list[index]] != ''
                          ? Container(
                              height: MediaQuery.of(context).size.width/4,
                              width: MediaQuery.of(context).size.width/4,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                                  image: DecorationImage(
                                    image: new AssetImage(ExImage().body_part_image[key_list[index]]),
                                    fit: BoxFit.cover,
                                  )))
                          : Container(
                          color: Colors.white,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 100,
                          )),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        '${key_list[index]}',
                        style: TextStyle(
                            fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },

      ),
    );
  }

  Widget _bodyWidget() {
    switch (swap) {
      case 1:
        return _workoutWidget();

      case -1:
        return group_by_target();
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
                            _customExUsed = true;
                          });
                          return true;
                        } else {
                          setState(() {
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
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),),
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: _workoutNameCtrl.text == "" || _customExUsed == true
                  ? Color(0xFF212121)
                  : Theme.of(context).primaryColor,
              textStyle: TextStyle(color: Colors.white,),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (!_customExUsed && _workoutNameCtrl.text != "") {
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
            child: Text(_customExUsed == true ? "존재하는 루틴 이름" : "새 루틴 추가",
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
                    _workoutdataProvider.workoutdata.routinedatas
                        .indexWhere((routine) {
                      if (routine.name == _workoutNameCtrl.text) {
                        setState(() {
                          _customExUsed = true;
                        });
                        return true;
                      } else {
                        setState(() {
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
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),),
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: _workoutNameCtrl.text == "" || _customExUsed == true
                  ? Color(0xFF212121)
                  : Theme.of(context).primaryColor,
              textStyle: TextStyle(color: Colors.white,),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              !_customExUsed && _workoutNameCtrl.text != ""
              ? [_editWorkoutNameCheck(_workoutNameCtrl.text, index),
              _workoutNameCtrl.clear(),
              Navigator.of(context, rootNavigator: true).pop()]
              : null;
            },
            child: Text(_customExUsed == true ? "존재하는 루틴 이름" : "루틴 이름 수정",
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
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
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

    return Consumer<PopProvider>(builder: (Builder, provider, child) {
      int grindex = _workoutdataProvider.workoutdata.routinedatas.indexWhere(
          (routine) =>
              routine.name == _PrefsProvider.prefs.getString('lastroutine'));
      bool _goto = provider.goto;
      _goto == false
          ? null
          : [
              provider.exstackup(0),
              Future.delayed(Duration.zero, () async {
                Navigator.of(context).popUntil((route) => route.isFirst);
                if (_workoutdataProvider.workoutdata
                        .routinedatas[_routinetimeProvider.nowonrindex].mode ==
                    0) {
                  Navigator.push(
                      context,
                      Transition(
                          child: EachWorkoutDetails(
                            rindex: _routinetimeProvider.nowonrindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  Navigator.push(
                      context,
                      Transition(
                          child: EachExerciseDetails(
                            ueindex: _exercisesdataProvider
                                .exercisesdata.exercises
                                .indexWhere((element) =>
                            element.name ==
                                _workoutdataProvider
                                    .workoutdata
                                    .routinedatas[
                                _routinetimeProvider.nowonrindex]
                                    .exercises[
                                _routinetimeProvider.nowoneindex]
                                    .name),
                            eindex: _routinetimeProvider.nowoneindex,
                            rindex: _routinetimeProvider.nowonrindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  provider.gotooff();
                  provider.exstackup(2);
                } else {
                  Navigator.push(
                      context,
                      Transition(
                          child: EachPlanDetails(
                            rindex: _routinetimeProvider.nowonrindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  provider.gotooff();
                  provider.exstackup(1);
                }
              }),
            ];
      provider.gotolast == false
          ? null
          : [
              provider.exstackup(0),
              Future.delayed(Duration.zero, () async {
                Navigator.of(context).popUntil((route) => route.isFirst);
                if (_workoutdataProvider
                        .workoutdata.routinedatas[grindex].mode ==
                    1) {
                  Navigator.push(
                      context,
                      Transition(
                          child: EachPlanDetails(
                            rindex: grindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  provider.gotooff();
                  provider.exstackup(1);
                } else {
                  Navigator.push(
                      context,
                      Transition(
                          child: EachWorkoutDetails(
                            rindex: grindex,
                          ),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  provider.gotooff();
                  provider.exstackup(1);
                }
              }),
            ];
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
    });
  }
}
