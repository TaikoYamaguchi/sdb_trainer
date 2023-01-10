import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gif/flutter_gif.dart';
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
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:sdb_trainer/src/utils/change_name.dart';
import 'package:sdb_trainer/src/utils/my_flexible_space_bar.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transition/transition.dart';
import 'package:tutorial/tutorial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:expandable/expandable.dart';

class EachWorkoutDetails extends StatefulWidget {
  int rindex;
  EachWorkoutDetails({Key? key, required this.rindex}) : super(key: key);

  @override
  _EachWorkoutDetailsState createState() => _EachWorkoutDetailsState();
}

class _EachWorkoutDetailsState extends State<EachWorkoutDetails>
    with TickerProviderStateMixin {
  var _hisProvider;
  var _routinetimeProvider;
  var _userProvider;
  var _workoutProvider;
  var _famousdataProvider;
  var backupwddata;
  var _PopProvider;
  var _PrefsProvider;
  var _exercises;
  final controller = TextEditingController();
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  TextEditingController _exSearchCtrl = TextEditingController(text: "");
  TextEditingController _customExNameCtrl = TextEditingController(text: "");
  var _exProvider;
  late List<hisdata.Exercises> exerciseList = [];
  bool _inittutor = true;
  ExpandableController _menucontroller =
      ExpandableController(initialExpanded: true);
  late FlutterGifController controller1;

  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  bool _isexsearch = false;
  var btnDisabled;
  var _customExUsed = false;
  var _customRuUsed = false;
  var selectedItem = '기타';
  var selectedItem2 = '기타';

  var keyPlus = GlobalKey();
  var keyContainer = GlobalKey();
  var keyCheck = GlobalKey();
  var keySearch = GlobalKey();
  var keySelect = GlobalKey();

  List<TutorialItem> itens = [];

  //Iniciando o estado.
  @override
  void initState() {
    controller1 = FlutterGifController(vsync: this);
    itens.addAll({
      TutorialItem(
          globalKey: keyPlus,
          touchScreen: true,
          top: 200,
          left: 50,
          children: [
            Text(
              "+버튼을 눌러 원하는 운동을 추가 하세요",
              textScaleFactor: 1.7,
              style: TextStyle(color: Colors.white),
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
            textScaleFactor: 1.7,
            style: TextStyle(color: Colors.white),
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
            textScaleFactor: 1.7,
            style: TextStyle(color: Colors.white),
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
            textScaleFactor: 1.7,
            style: TextStyle(color: Colors.white),
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

  _showMyDialog() async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return showsimpleAlerts(
            layer: 2,
            rindex: widget.rindex,
            eindex: 0,
          );
        });
    if (result == true) {
      _workoutProvider.changebudata(widget.rindex);
      _workoutNameCtrl.clear();
      _exSearchCtrl.clear();
      searchExercise(_exSearchCtrl.text);
      setState(() {
        _isexsearch = !_isexsearch;
      });
    }
  }

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      leading: _isexsearch
          ? Center(
              child: GestureDetector(
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  color: Theme.of(context).primaryColorLight,
                ),
                onTap: () {
                  _showMyDialog();
                },
              ),
            )
          : Center(
              child: GestureDetector(
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  color: Theme.of(context).primaryColorLight,
                ),
                onTap: () {
                  btnDisabled == true
                      ? null
                      : [btnDisabled = true, Navigator.of(context).pop()];
                },
              ),
            ),
      title: _isexsearch
          ? Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
                child: TextField(
                    key: keySearch,
                    controller: _exSearchCtrl,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
                      hintText: "운동 검색",
                      hintStyle: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).primaryColorLight),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2, color: Theme.of(context).cardColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onChanged: (text) {
                      filterTotal(_exSearchCtrl.text, _exProvider.tags,
                          _exProvider.tags2);
                    }),
              ),
            )
          : Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NameInputDialog(rindex: widget.rindex);
                      },
                    );
                  },
                  child: Container(
                    child: Consumer<WorkoutdataProvider>(
                        builder: (builder, provider, child) {
                      return Text(
                        provider.workoutdata.routinedatas[widget.rindex].name,
                        textScaleFactor: 1.3,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight),
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
                color: Theme.of(context).primaryColorLight,
                onPressed: () {
                  _editWorkoutCheck();
                  setState(() {
                    _isexsearch = !_isexsearch;
                  });
                },
              )
            : IconButton(
                key: keyPlus,
                icon: SvgPicture.asset(
                  "assets/svg/add_white.svg",
                  color: Theme.of(context).primaryColorLight,
                ),
                onPressed: () {
                  _workoutProvider.dataBU(widget.rindex);

                  setState(() {
                    _isexsearch = !_isexsearch;
                  });
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
      backgroundColor: Theme.of(context).canvasColor,
    );
  }

  void _editWorkoutwoCheck() async {
    var routinedatas_all = _workoutProvider.workoutdata.routinedatas;
    for (int n = 0; n < routinedatas_all[widget.rindex].exercises.length; n++) {
      for (int i = 0;
          i < routinedatas_all[widget.rindex].exercises[n].sets.length;
          i++) {
        routinedatas_all[widget.rindex].exercises[n].sets[i].ischecked = false;
      }
    }
    WorkoutEdit(
            id: _workoutProvider.workoutdata.id,
            user_email: _userProvider.userdata.email,
            routinedatas: routinedatas_all)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? showToast("수정 완료")
            : showToast("입력을 확인해주세요"));
  }

  void recordExercise() {
    var exercise_all =
        _workoutProvider.workoutdata.routinedatas[widget.rindex].exercises;
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
              user_email: _userProvider.userdata.email,
              exercises: exerciseList,
              new_record: _routinetimeProvider.routineNewRecord,
              workout_time: _routinetimeProvider.routineTime,
              nickname: _userProvider.userdata.nickname)
          .postHistory()
          .then((data) => data["user_email"] != null
              ? {
                  Navigator.push(
                      context,
                      Transition(
                          child: ExerciseDone(
                              exerciseList: exerciseList,
                              routinetime: _routinetimeProvider.routineTime,
                              sdbdata: hisdata.SDBdata.fromJson(data)),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT)),
                  _routinetimeProvider.routinecheck(widget.rindex),
                  _hisProvider.getdata(),
                  _hisProvider.getHistorydataAll(),
                  exerciseList = []
                }
              : showToast("입력을 확인해주세요"));
    } else {
      _routinetimeProvider.routinecheck(widget.rindex);
    }
  }

  void modifyExercise(double newonerm, exname) {
    _exercises[_exercises.indexWhere((element) => element.name == exname)]
        .onerm = newonerm;
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userProvider.userdata.email, exercises: _exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  Widget targetchip(items2) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).cardColor,
      child: Consumer<FamousdataProvider>(builder: (context, provider, child) {
        return ChipsChoice<String>.multiple(
          value: provider.tags,
          onChanged: (val) {
            val.indexOf('기타') == val.length - 1
                ? {
                    provider.settags(['기타']),
                    _menucontroller.expanded = false
                  }
                : [
                    val.remove('기타'),
                    provider.settags(val),
                  ];
          },
          choiceItems: C2Choice.listFrom<String, String>(
            source: items2,
            value: (i, v) => v,
            label: (i, v) => v,
            tooltip: (i, v) => v,
          ),
          wrapped: true,
          choiceStyle: const C2ChoiceStyle(
            color: Color(0xff40434e),
            appearance: C2ChipType.elevated,
          ),
          choiceActiveStyle: const C2ChoiceStyle(
            color: Color(0xff7a28cb),
            appearance: C2ChipType.elevated,
          ),
        );
      }),
    );
  }

  void _displayCustomExInputDialog(provider) {
    _famousdataProvider.settags(['기타']);
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext context) {
          List<String> options = [..._exProvider.options];
          options.remove('All');
          List<String> options2 = [..._exProvider.options2];
          options2.remove('All');
          return SingleChildScrollView(
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter mystate) {
              return Container(
                padding: EdgeInsets.all(12.0),
                height: MediaQuery.of(context).size.height * 0.65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                            '커스텀 운동을 만들어보세요',
                            textScaleFactor: 2.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight),
                          ),
                          SizedBox(height: 4),
                          Text('운동의 이름을 입력해 주세요',
                              textScaleFactor: 1.3,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Text('외부를 터치하면 취소 할 수 있어요',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 20),
                          TextField(
                            onChanged: (value) {
                              _exProvider.exercisesdata.exercises
                                  .indexWhere((exercise) {
                                if (exercise.name == _customExNameCtrl.text) {
                                  mystate(() {
                                    _customExUsed = true;
                                  });
                                  return true;
                                } else {
                                  mystate(() {
                                    _customExUsed = false;
                                  });
                                  return false;
                                }
                              });
                            },
                            style: TextStyle(
                                fontSize: 24.0,
                                color: Theme.of(context).primaryColorLight),
                            textAlign: TextAlign.center,
                            controller: _customExNameCtrl,
                            decoration: InputDecoration(
                                filled: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 3),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 3),
                                ),
                                hintText: "커스텀 운동 이름",
                                hintStyle: TextStyle(
                                    fontSize: 24.0,
                                    color:
                                        Theme.of(context).primaryColorLight)),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 16),
                              Container(
                                child: Text(
                                  '운동부위:',
                                  textScaleFactor: 2.0,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight),
                                ),
                              ),
                            ],
                          ),
                          targetchip(options),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 16),
                              Container(
                                child: Text(
                                  '카테고리:',
                                  textScaleFactor: 2.0,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight),
                                ),
                              ),
                              SizedBox(width: 20),
                              Container(
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        2 /
                                        5,
                                    child: DropdownButtonFormField(
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        filled: true,
                                        enabledBorder: UnderlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                              width: 3),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 3),
                                        ),
                                      ),
                                      hint: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '기타',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorLight),
                                          )),
                                      items: options2
                                          .map((item) => DropdownMenuItem<
                                                  String>(
                                              value: item.toString(),
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    item,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColorLight),
                                                  ))))
                                          .toList(),
                                      onChanged: (item) => setState(
                                          () => selectedItem2 = item as String),
                                    )),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    _customExSubmitButton(context, provider)
                  ],
                ),
              );
            }),
          );
        });
  }

  Widget _customExSubmitButton(context, provider) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor:
                  _customExNameCtrl.text == "" || _customExUsed == true
                      ? Color(0xFF212121)
                      : Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (_customExUsed == false && _customExNameCtrl.text != "") {
                _exProvider.addExdata(Exercises(
                    name: _customExNameCtrl.text,
                    onerm: 0,
                    goal: 0,
                    image: null,
                    category: selectedItem2,
                    target: _famousdataProvider.tags,
                    custom: true,
                    note: ''));
                _postExerciseCheck();
                _customExNameCtrl.clear();

                filterTotal(
                    _exSearchCtrl.text, _exProvider.tags, _exProvider.tags2);

                Navigator.of(context).pop();
              }
            },
            child: Text(_customExUsed == true ? "존재하는 운동" : "커스텀 운동 추가",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).buttonColor))));
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

  Widget _exercisesWidget(bool scrollable, bool shirink) {
    return Container(
      child: Consumer3<WorkoutdataProvider, ExercisesdataProvider,
          RoutineTimeProvider>(builder: (builder, wdp, exp, rtp, child) {
        List exunique = exp.exercisesdata.exercises;
        List exlist = wdp.workoutdata.routinedatas[widget.rindex].exercises;
        for (int i = 0; i < exlist.length; i++) {
          final filter = exunique.where((unique) {
            return (unique.name == exlist[i].name);
          }).toList();
          if (filter.isEmpty) {
            _workoutProvider.removeexAt(widget.rindex, i);
            showToast('더 이상 존재하지 않는 운동은 삭제되요');
          }
        }
        return Column(children: [
          ReorderableListView.builder(
              physics: scrollable ? new NeverScrollableScrollPhysics() : null,
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
              padding: EdgeInsets.symmetric(horizontal: _isexsearch ? 2 : 4),
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

                var _exImage;
                try {
                  _exImage = extra_completely_new_Ex[
                          extra_completely_new_Ex.indexWhere(
                              (element) => element.name == exlist[index].name)]
                      .image;
                  if (_exImage == null) {
                    _exImage = "";
                  }
                } catch (e) {
                  _exImage = "";
                }

                return GestureDetector(
                  key: Key('$index'),
                  onTap: () {
                    _isexsearch
                        ? [_workoutProvider.removeexAt(widget.rindex, index)]
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
                              _workoutProvider.removeexAt(widget.rindex, index);
                              _editWorkoutCheck();
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Theme.of(context).buttonColor,
                            icon: Icons.delete,
                            label: 'Delete',
                          )
                        ]),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: _isexsearch ? 8 : 8),
                          decoration: BoxDecoration(
                              color: rtp.isstarted
                                  ? index == rtp.nowoneindex
                                      ? Color(0xffCEEC97)
                                      : Theme.of(context).cardColor
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(top),
                                  bottomRight: Radius.circular(bottom),
                                  topLeft: Radius.circular(top),
                                  bottomLeft: Radius.circular(bottom))),
                          height: _isexsearch ? 42 : 76,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    _isexsearch
                                        ? Container()
                                        : _exImage != ""
                                            ? Image.asset(
                                                _exImage,
                                                height: 64,
                                                width: 64,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                height: 64,
                                                width: 64,
                                                child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Theme.of(context)
                                                        .primaryColorDark),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle),
                                              ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exlist[index].name,
                                            textScaleFactor:
                                                _isexsearch ? 1.1 : 1.7,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorLight),
                                          ),
                                          _isexsearch
                                              ? Container()
                                              : Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          "Rest: ${exlist[index].rest}",
                                                          textScaleFactor: 1.0,
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF717171))),
                                                    ],
                                                  ),
                                                )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 12, 4, 12),
                                child: Container(
                                  height: 15.0,
                                  width: 3.0,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColorDark,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                ),
                              )
                            ],
                          ),
                        ),
                        index == exlist.length - 1
                            ? Container()
                            : Container(
                                alignment: Alignment.center,
                                height: 0.5,
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 0.5,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              )
                      ],
                    ),
                  ),
                );
              },
              shrinkWrap: shirink,
              itemCount: exlist.length),
          _isexsearch
              ? exlist.isEmpty == true
                  ? GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: 80,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          child: Icon(
                                            Icons.add,
                                            size: 28.0,
                                            color:
                                                Theme.of(context).buttonColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 4.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("운동 추가",
                                                  textScaleFactor: 1.5,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  )),
                                            ],
                                          ),
                                        )
                                      ]),
                                  Text("오른쪽을 눌러서 추가 할 수 있어요",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ))
                  : Container()
              : GestureDetector(
                  onTap: () {
                    _workoutProvider.dataBU(widget.rindex);
                    _exProvider.resettags();
                    _exProvider.inittestdata();
                    setState(() {
                      _isexsearch = !_isexsearch;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
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
                                    color: Theme.of(context).buttonColor,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 4.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("이곳을 눌러보세요",
                                          textScaleFactor: 1.5,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          )),
                                      Text("운동을 추가 할 수 있어요",
                                          textScaleFactor: 1.1,
                                          style: TextStyle(
                                            color: Colors.grey,
                                          )),
                                    ],
                                  ),
                                )
                              ]),
                        ),
                      ),
                    ),
                  ))
        ]);
      }),
    );
  }

  Widget _exercises_searchWidget() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Container(
              child: Consumer<ExercisesdataProvider>(
                  builder: (context, provider, child) {
                return ExpandablePanel(
                  controller: _menucontroller,
                  theme: ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      hasIcon: false,
                      iconColor: Theme.of(context).primaryColorLight,
                      tapHeaderToExpand: false),
                  header: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          provider.setfiltmenu(1);
                          _menucontroller.expanded = true;
                        },
                        child: Card(
                          color: provider.filtmenu == 1
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2 - 10,
                            height:
                                _appbarWidget().preferredSize.height * 2 / 3,
                            child: Center(
                              child: Text(
                                provider.tags.indexOf("All") != -1
                                    ? "운동부위"
                                    : '${provider.tags.toString().replaceAll('[', '').replaceAll(']', '')}',
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                    color: provider.filtmenu == 1
                                        ? Theme.of(context).buttonColor
                                        : Theme.of(context).primaryColorLight),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          provider.setfiltmenu(2);
                          _menucontroller.expanded = true;
                        },
                        child: Card(
                          color: provider.filtmenu == 2
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2 - 10,
                            height:
                                _appbarWidget().preferredSize.height * 2 / 3,
                            child: Center(
                              child: Text(
                                provider.tags2.indexOf("All") != -1
                                    ? "운동유형"
                                    : '${provider.tags2.toString().replaceAll('[', '').replaceAll(']', '')}',
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                    color: provider.filtmenu == 2
                                        ? Theme.of(context).buttonColor
                                        : Theme.of(context).primaryColorLight),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  collapsed: Container(),
                  expanded: provider.filtmenu == 1
                      ? exp1()
                      : provider.filtmenu == 2
                          ? exp2()
                          : Container(),
                );
              }),
            ),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2 - 1,
                  child: Center(
                    child: Text("현재 루틴",
                        textScaleFactor: 2.0,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2 - 1,
                  child: Center(
                    child: Text("운동 종목",
                        textScaleFactor: 2.0,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight)),
                  ),
                )
              ]),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is UserScrollNotification) {
                  if (notification.direction == ScrollDirection.forward) {
                    //_menucontroller.expanded = true;
                  } else if (notification.direction ==
                      ScrollDirection.reverse) {
                    _menucontroller.expanded = false;
                  }
                }

                // Returning null (or false) to
                // "allow the notification to continue to be dispatched to further ancestors".
                return false;
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 1.0),
                          child: _exercisesWidget(true, true),
                        ),
                      ),
                    ),
                    VerticalDivider(
                        color: Theme.of(context).primaryColor,
                        thickness: 2,
                        width: 2),
                    Consumer<ExercisesdataProvider>(
                        builder: (builder, provider, child) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 2 - 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0, right: 1.0),
                          child: Column(
                            children: [
                              exercisesWidget(true),
                              GestureDetector(
                                  onTap: () {
                                    _displayCustomExInputDialog(provider);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2, right: 2),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        height: 100,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 28.0,
                                                        color: Theme.of(context)
                                                            .buttonColor,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text("커스텀 운동",
                                                              textScaleFactor:
                                                                  1.5,
                                                              style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorLight,
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  ]),
                                              Text("개인 운동을 추가 할 수 있어요",
                                                  textScaleFactor: 1.0,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      );
                    })
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget exercisesWidget(bool shirink) {
    double top = 0;
    double bottom = 0;
    return Expanded(
        key: keySelect,
        //color: Colors.black,
        child: Consumer2<WorkoutdataProvider, ExercisesdataProvider>(
            builder: (builder, provider, provider2, child) {
          List exlist =
              provider.workoutdata.routinedatas[widget.rindex].exercises;
          List existlist = [];
          if (_exProvider.testdata == null) {
            _exProvider.inittestdata();
          }
          final exuniq = _exProvider.testdata;
          for (int i = 0; i < exlist.length; i++) {
            existlist.add(exlist[i].name);
          }

          return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 2),
              itemBuilder: (BuildContext _context, int index) {
                bool alreadyexist = existlist.contains(exuniq[index].name);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _workoutProvider.addexAt(
                          widget.rindex,
                          new wod.Exercises(
                              name: exuniq[index].name,
                              sets: wod.Setslist().setslist,
                              rest: 90));
                    });
                  },
                  child: Container(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: _isexsearch ? 10 : 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(top),
                              bottomRight: Radius.circular(bottom),
                              topLeft: Radius.circular(top),
                              bottomLeft: Radius.circular(bottom))),
                      height: _isexsearch ? 42 : 52,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exuniq[index].name,
                            textScaleFactor: _isexsearch ? 1.1 : 1.7,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext _context, int index) {
                return Container(
                  alignment: Alignment.center,
                  height: 0.5,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 0.5,
                    color: Theme.of(context).primaryColorDark,
                  ),
                );
              },
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: exuniq.length);
        }));
  }

  void searchExercise(String query) async {
    final suggestions =
        await _exProvider.exercisesdata.exercises.map((exercise) {
      final exTitle = exercise.name.toLowerCase().replaceAll(' ', '');
      return (exTitle.contains(query.toLowerCase().replaceAll(' ', '')))
          as bool;
    }).toList();
    _exProvider.settestdata_s(suggestions);
  }

  Widget exp1() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child:
          Consumer<ExercisesdataProvider>(builder: (context, provider, child) {
        return ChipsChoice<String>.multiple(
          value: provider.tags,
          onChanged: (val) {
            val.indexOf('All') == val.length - 1
                ? {
                    provider.settags(['All']),
                    _menucontroller.expanded = false
                  }
                : [
                    val.remove('All'),
                    provider.settags(val),
                  ];
            filterTotal(
                _exSearchCtrl.text, _exProvider.tags, _exProvider.tags2);
          },
          choiceItems: C2Choice.listFrom<String, String>(
            source: provider.options,
            value: (i, v) => v,
            label: (i, v) => v,
            tooltip: (i, v) => v,
          ),
          wrapped: true,
          choiceStyle: C2ChoiceStyle(
            appearance: C2ChipType.elevated,
            labelStyle: TextStyle(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          choiceActiveStyle: C2ChoiceStyle(
            color: Theme.of(context).primaryColor,
            appearance: C2ChipType.elevated,
          ),
        );
      }),
    );
  }

  Widget exp2() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child:
          Consumer<ExercisesdataProvider>(builder: (context, provider, child) {
        return ChipsChoice<String>.multiple(
          value: provider.tags2,
          onChanged: (val) {
            val.indexOf('All') == val.length - 1
                ? {
                    provider.settags2(['All']),
                    _menucontroller.expanded = false
                  }
                : [
                    val.remove('All'),
                    provider.settags2(val),
                  ];
            filterTotal(
                _exSearchCtrl.text, _exProvider.tags, _exProvider.tags2);
          },
          choiceItems: C2Choice.listFrom<String, String>(
            source: provider.options2,
            value: (i, v) => v,
            label: (i, v) => v,
            tooltip: (i, v) => v,
          ),
          wrapped: true,
          choiceStyle: const C2ChoiceStyle(
            appearance: C2ChipType.elevated,
          ),
          choiceActiveStyle: C2ChoiceStyle(
            color: Theme.of(context).primaryColor,
            appearance: C2ChipType.elevated,
          ),
        );
      }),
    );
  }

  filterTotal(String query, List tags, List tags2) async {
    var suggestions;
    var suggestions2;
    var suggestions3;
    if (query == '') {
      suggestions = await _exProvider.exercisesdata.exercises;
    } else {
      suggestions = await _exProvider.exercisesdata.exercises.where((exercise) {
        final exTitle = exercise.name.toLowerCase().replaceAll(' ', '');
        return (exTitle.contains(query.toLowerCase().replaceAll(' ', '')))
            as bool;
      }).toList();
    }

    if (tags[0] == 'All') {
      suggestions2 = await _exProvider.exercisesdata.exercises;
    } else {
      suggestions2 =
          await _exProvider.exercisesdata.exercises.where((exercise) {
        final extarget = Set.from(exercise.target);
        final query_s = Set.from(tags);
        return (query_s.intersection(extarget).isNotEmpty) as bool;
      }).toList();
    }

    if (tags2[0] == 'All') {
      suggestions3 = await _exProvider.exercisesdata.exercises;
    } else {
      suggestions3 =
          await _exProvider.exercisesdata.exercises.where((exercise) {
        final excate = exercise.category;
        return (tags2.contains(excate)) as bool;
      }).toList();
    }
    _exProvider.settesttotal(suggestions, suggestions2, suggestions3);
  }

  @override
  Widget build(BuildContext context) {
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercises = _exProvider.exercisesdata.exercises;
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);
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
      bool _tutorpop = provider.tutorpop;
      _tutorpop == false
          ? null
          : [
              provider.exstackup(0),
              Future.delayed(Duration.zero, () async {
                Navigator.of(context).popUntil((route) => route.isFirst);
                _PopProvider.tutorpopoff();
              })
            ];

      return Scaffold(
        appBar: _isexsearch ? _appbarWidget() : null,
        body: _isexsearch
            ? _exercises_searchWidget()
            : CustomScrollView(slivers: [
                SliverAppBar(
                  snap: false,
                  floating: false,
                  pinned: true,
                  backgroundColor:
                      Theme.of(context).canvasColor.withOpacity(0.9),
                  actions: [
                    IconButton(
                      key: keyPlus,
                      icon: SvgPicture.asset("assets/svg/add_white.svg",
                          color: Theme.of(context).primaryColorLight),
                      onPressed: () {
                        _workoutProvider.dataBU(widget.rindex);
                        _exProvider.resettags();
                        _exProvider.inittestdata();

                        setState(() {
                          _isexsearch = !_isexsearch;
                        });
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
                  leading: Center(
                    child: GestureDetector(
                      child: Icon(Icons.arrow_back_ios_outlined,
                          color: Theme.of(context).primaryColorLight),
                      onTap: () {
                        btnDisabled == true
                            ? null
                            : [btnDisabled = true, Navigator.of(context).pop()];
                      },
                    ),
                  ),
                  expandedHeight: _appbarWidget().preferredSize.height * 2,
                  collapsedHeight: _appbarWidget().preferredSize.height,
                  flexibleSpace: myFlexibleSpaceBar(
                    expandedTitleScale: 1.2,
                    titlePaddingTween: EdgeInsetsTween(
                        begin: EdgeInsets.only(left: 12.0, bottom: 8),
                        end: EdgeInsets.only(left: 60.0, bottom: 8)),
                    title: GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return NameInputDialog(rindex: widget.rindex);
                            });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Consumer<WorkoutdataProvider>(
                                builder: (builder, provider, child) {
                              return Text(
                                provider.workoutdata.routinedatas[widget.rindex]
                                    .name,
                                textScaleFactor: 1.3,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, _index) {
                      return Container(child: _exercisesWidget(true, true));
                    },
                    childCount: 1,
                  ),
                )
              ]),
      );
    });
  }
}
