import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/each_exercise.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transition/transition.dart';
import 'package:tutorial/tutorial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EachWorkoutDetails extends StatefulWidget {
  int rindex;
  EachWorkoutDetails({Key? key, required this.rindex}) : super(key: key);

  @override
  _EachWorkoutDetailsState createState() => _EachWorkoutDetailsState();
}

class _EachWorkoutDetailsState extends State<EachWorkoutDetails> {
  var _historydataProvider;
  var _routinetimeProvider;
  var _userdataProvider;
  var _workoutdataProvider;
  var backupwddata;
  var _PopProvider;
  var _PrefsProvider;
  var _exercises;
  final controller = TextEditingController();
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  var _exercisesdataProvider;
  var _testdata0;
  late var _testdata = _testdata0;
  late List<hisdata.Exercises> exerciseList = [];
  bool _inittutor = true;

  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  bool _isexsearch = false;
  var btnDisabled;

  var keyPlus = GlobalKey();
  var keyContainer = GlobalKey();
  var keyCheck = GlobalKey();
  var keySearch = GlobalKey();
  var keySelect = GlobalKey();

  List<TutorialItem> itens = [];

  //Iniciando o estado.
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
              "+버튼을 눌러 원하는 운동을 추가 하세요",
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
      TutorialItem(
        globalKey: keySearch,
        touchScreen: true,
        top: 200,
        left: 50,
        children: [
          Text(
            "이곳에 검색하여 원하는 운동을 찾고,",
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
        shapeFocus: ShapeFocus.square,
      ),
      TutorialItem(
        globalKey: keySelect,
        touchScreen: true,
        top: 200,
        left: 50,
        children: [
          Text(
            "운동을 클릭하여 원하는 운동을 추가한 뒤,",
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
        shapeFocus: ShapeFocus.square,
      ),
      TutorialItem(
        globalKey: keyCheck,
        touchScreen: true,
        top: 200,
        left: 50,
        children: [
          Text(
            "이곳을 눌러 Routine 수정을 완료하세요",
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
        shapeFocus: ShapeFocus.oval,
      ),
    });

    ///FUNÇÃO QUE EXIBE O TUTORIAL.

    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return AppBar(
      leading: _isexsearch
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined),
              onPressed: () {
                _workoutdataProvider.changebudata(widget.rindex);
                setState(() {
                  _isexsearch = !_isexsearch;
                });
              },
            )
          : IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined),
              onPressed: () {
                _routinetimeProvider.isstarted
                    ? _displayFinishAlert()
                    : btnDisabled == true
                        ? null
                        : [btnDisabled = true, Navigator.of(context).pop()];
              },
            ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              _displayTextInputDialog();
            },
            child: Container(
              child: Consumer<WorkoutdataProvider>(
                  builder: (builder, provider, child) {
                return Text(
                  provider.workoutdata.routinedatas[widget.rindex].name,
                  style: TextStyle(color: Colors.white, fontSize: 30),
                );
              }),
            ),
          ),
        ],
      ),
      actions: [
        _isexsearch
            ? IconButton(
                key: keyCheck,
                iconSize: 30,
                icon: Icon(Icons.check_rounded),
                onPressed: () {
                  _editWorkoutCheck();
                  setState(() {
                    _isexsearch = !_isexsearch;
                  });
                },
              )
            : IconButton(
                key: keyPlus,
                icon: SvgPicture.asset("assets/svg/add_white.svg"),
                onPressed: () {
                  _workoutdataProvider.dataBU(widget.rindex);

                  setState(() {
                    _isexsearch = !_isexsearch;
                  });
                  print(_PrefsProvider.eachworkouttutor);
                  _PrefsProvider.eachworkouttutor
                      ? [
                          Future.delayed(Duration(milliseconds: 100))
                              .then((value) {
                            Tutorial.showTutorial(context, itens);
                          }),
                          _PrefsProvider.tutordone()
                        ]
                      : null;
                },
              )
      ],
      backgroundColor: Colors.black,
    );
  }

  void _editWorkoutwoCheck() async {
    var routinedatas_all = _workoutdataProvider.workoutdata.routinedatas;
    for (int n = 0; n < routinedatas_all[widget.rindex].exercises.length; n++) {
      for (int i = 0;
          i < routinedatas_all[widget.rindex].exercises[n].sets.length;
          i++) {
        routinedatas_all[widget.rindex].exercises[n].sets[i].ischecked = false;
      }
    }
    WorkoutEdit(
            id: _workoutdataProvider.workoutdata.id,
            user_email: _userdataProvider.userdata.email,
            routinedatas: routinedatas_all)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? showToast("수정 완료")
            : showToast("입력을 확인해주세요"));
  }

  void _displayFinishAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Workout Finish Alert',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('운동을 끝마치겠습니까?'),
            actions: <Widget>[
              _FinishConfirmButton(),
            ],
          );
        });
  }

  Widget _FinishConfirmButton() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: FlatButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledColor: Color.fromRGBO(246, 58, 64, 20),
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _routinetimeProvider.routinecheck(widget.rindex);
                    recordExercise();
                    _editHistoryCheck();
                    _editWorkoutwoCheck();
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text("Confirm",
                      style: TextStyle(fontSize: 20.0, color: Colors.white)))),
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  disabledColor: Color.fromRGBO(246, 58, 64, 20),
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("Cancel",
                      style: TextStyle(fontSize: 20.0, color: Colors.white))))
        ],
      ),
    );
  }

  void recordExercise() {
    var exercise_all =
        _workoutdataProvider.workoutdata.routinedatas[widget.rindex].exercises;
    for (int n = 0; n < exercise_all.length; n++) {
      var recordedsets = exercise_all[n].sets.where((sets) {
        return (sets.ischecked as bool && sets.weight != 0);
      }).toList();
      double monerm = 0;
      for (int i = 0; i < recordedsets.length; i++) {
        if (recordedsets[i].reps != 1) {
          if (monerm <
              recordedsets[i].weight * (1 + recordedsets[i].reps / 30)) {
            monerm = recordedsets[i].weight * (1 + recordedsets[i].reps / 30);
          }
        } else if (monerm < recordedsets[i].weight) {
          monerm = recordedsets[i].weight;
        }
      }
      var _eachex = _exercises[_exercises
          .indexWhere((element) => element.name == exercise_all[n].name)];
      if (!recordedsets.isEmpty) {
        exerciseList.add(hisdata.Exercises(
            name: exercise_all[n].name,
            sets: recordedsets,
            onerm: monerm,
            goal: _eachex.goal,
            date: DateTime.now().toString().substring(0, 10)));
      }

      if (monerm > _eachex.onerm) {
        modifyExercise(monerm, exercise_all[n].name);
      }
    }
    _postExerciseCheck();
  }

  void _editHistoryCheck() async {
    if (!exerciseList.isEmpty) {
      HistoryPost(
              user_email: _userdataProvider.userdata.email,
              exercises: exerciseList,
              new_record: 120,
              workout_time: _routinetimeProvider.routineTime,
              nickname: _userdataProvider.userdata.nickname)
          .postHistory()
          .then((data) => data["user_email"] != null
              ? {
                  _historydataProvider.getdata(),
                  _historydataProvider.getHistorydataAll(),
                  exerciseList = []
                }
              : showToast("입력을 확인해주세요"));
    } else {
      print("no exercises");
    }
  }

  void modifyExercise(double newonerm, exname) {
    _exercises[_exercises.indexWhere((element) => element.name == exname)]
        .onerm = newonerm;
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userdataProvider.userdata.email, exercises: _exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exercisesdataProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  void _displayTextInputDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('루틴 이름 설정'),
            content: TextField(
              onChanged: (value) {},
              controller: _workoutNameCtrl,
              decoration: InputDecoration(hintText: "루틴 이름"),
            ),
            actions: <Widget>[
              _workoutSubmitButton(context),
            ],
          );
        });
  }

  Widget _workoutSubmitButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () {
              _editWorkoutNameCheck(_workoutNameCtrl.text);
              _workoutNameCtrl.clear();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("workout 이름 제출",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _editWorkoutNameCheck(newname) async {
    _workoutdataProvider.namechange(widget.rindex, newname);

    WorkoutEdit(
            user_email: _userdataProvider.userdata.email,
            id: _workoutdataProvider.workoutdata.id,
            routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? {showToast("done!"), _workoutdataProvider.getdata()}
            : showToast("입력을 확인해주세요"));
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

  Widget _exercisesWidget(bool shirink) {
    return Container(
      color: Colors.black,
      child: Consumer2<WorkoutdataProvider, ExercisesdataProvider>(
          builder: (builder, wdp, exp, child) {
        List exunique = exp.exercisesdata.exercises;
        List exlist = wdp.workoutdata.routinedatas[widget.rindex].exercises;
        return ReorderableListView.builder(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = exlist.removeAt(oldIndex);
                exlist.insert(newIndex, item);
                _editWorkoutCheck();
              });
            },
            padding: EdgeInsets.symmetric(horizontal: 5),
            itemBuilder: (BuildContext _context, int index) {
              final exinfo = exunique.where((unique) {
                return (unique.name == exlist[index].name);
              }).toList();
              if (exlist.length == 1) {
                top = 20;
                bottom = 20;
              } else if (index == 0) {
                top = 20;
                bottom = 0;
              } else if (index == exlist.length - 1) {
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
                  _isexsearch
                      ? [_workoutdataProvider.removeexAt(widget.rindex, index)]
                      : [
                          _PopProvider.exstackup(2),
                          Navigator.push(
                              context,
                              Transition(
                                  child: EachExerciseDetails(
                                    ueindex: exunique.indexWhere((element) =>
                                        element.name == exlist[index].name),
                                    eindex: index,
                                    rindex: widget.rindex,
                                  ),
                                  transitionEffect:
                                      TransitionEffect.RIGHT_TO_LEFT))
                        ];
                },
                child: Slidable(
                  endActionPane: ActionPane(
                      extentRatio: 0.2,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            _workoutdataProvider.removeexAt(
                                widget.rindex, index);
                            _editWorkoutCheck();
                          },
                          backgroundColor: Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        )
                      ]),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            color: Color(0xFF212121),
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
                              exlist[index].name,
                              style:
                                  TextStyle(fontSize: 21, color: Colors.white),
                            ),
                            Container(
                              child: Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text("Rest: ${exlist[index].rest}",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF717171))),
                                  Expanded(child: SizedBox()),
                                  Text(
                                      "1RM: ${exinfo[0].onerm.toStringAsFixed(1)}/${exinfo[0].goal.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF717171))),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      index == exlist.length - 1
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
            /*
              separatorBuilder: (BuildContext _context, int index){
                return Container(
                  alignment: Alignment.center,
                  height:1, color: Color(0xFF212121),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height:1, color: Color(0xFF717171),
                  ),
                );

              },
               */
            shrinkWrap: shirink,
            itemCount: exlist.length);
      }),
    );
  }

  Widget _exercises_searchWidget() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: TextField(
                key: keySearch,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF717171),
                  ),
                  hintText: "Exercise Name",
                  hintStyle:
                      TextStyle(fontSize: 20.0, color: Color(0xFF717171)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Color(0xFF717171)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onChanged: (text) {
                  searchExercise(text.toString());
                }),
          ),
          AspectRatio(aspectRatio: 1.3, child: _exercisesWidget(true)),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
            color: Color(0xFF212121),
            height: 20,
            child: Row(
              children: [
                Text(
                  "Not in List",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          exercisesWidget(_testdata, true)
        ],
      ),
    );
  }

  Widget exercisesWidget(exuniq, bool shirink) {
    double top = 0;
    double bottom = 0;
    return Expanded(
      key: keySelect,
      //color: Colors.black,
      child: Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
        List exlist =
            provider.workoutdata.routinedatas[widget.rindex].exercises;
        List existlist = [];
        for (int i = 0; i < exlist.length; i++) {
          existlist.add(exlist[i].name);
        }

        return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 5),
            itemBuilder: (BuildContext _context, int index) {
              bool alreadyexist = existlist.contains(exuniq[index].name);
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
              ;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    alreadyexist
                        ? print("already")
                        : _workoutdataProvider.addexAt(
                            widget.rindex,
                            new wod.Exercises(
                                name: exuniq[index].name,
                                sets: wod.Setslist().setslist,
                                rest: 0));
                  });
                },
                child: Container(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Color(0xFF212121),
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
                          style: TextStyle(
                              fontSize: 21,
                              color:
                                  alreadyexist ? Colors.black : Colors.white),
                        ),
                        Container(
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Rest: need to set",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: alreadyexist
                                          ? Colors.black
                                          : Color(0xFF717171))),
                              Expanded(child: SizedBox()),
                              Text(
                                  "1RM: ${exuniq[index].onerm}/${exuniq[index].goal.toStringAsFixed(1)}${_userdataProvider.userdata.weight_unit}",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: alreadyexist
                                          ? Colors.black
                                          : Color(0xFF717171))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext _context, int index) {
              return Container(
                alignment: Alignment.center,
                height: 1,
                color: Color(0xFF212121),
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
            itemCount: exuniq.length);
      }),
    );
  }

  void searchExercise(String query) {
    final suggestions = _testdata0.where((exercise) {
      final exTitle = exercise.name;
      return (exTitle.contains(query)) as bool;
    }).toList();

    setState(() => _testdata = suggestions);
  }

  @override
  Widget build(BuildContext context) {
    _historydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercises = _exercisesdataProvider.exercisesdata.exercises;
    _testdata0 = _exercisesdataProvider.exercisesdata.exercises;
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);
    print("띠용");
    _PopProvider.tutorpopoff();
    _PrefsProvider.eachworkouttutor
        ? _PrefsProvider.steptwo
            ? [
                Future.delayed(Duration(milliseconds: 400)).then((value) {
                  Tutorial.showTutorial(context, itens);
                  _PrefsProvider.steptwodone();
                })
              ]
            : null
        : null;

    return Consumer<PopProvider>(builder: (Builder, provider, child) {
      bool _popable = provider.isstacking;
      _popable == false
          ? null
          : [
              provider.exstackdown(),
              provider.popoff(),
              Future.delayed(Duration.zero, () async {
                Navigator.of(context).pop();
              })
            ];
      print('working?1');
      bool _tutorpop = provider.tutorpop;
      _tutorpop == false
          ? print('working?2')
          : [
              print('working?'),
              provider.exstackup(0),
              Future.delayed(Duration.zero, () async {
                Navigator.of(context).popUntil((route) => route.isFirst);
                _PopProvider.tutorpopoff();
              })
            ];

      return Scaffold(
          appBar: _appbarWidget(),
          body:
              _isexsearch ? _exercises_searchWidget() : _exercisesWidget(false),
          backgroundColor: Colors.black);
    });
  }
}
