import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:tutorial/tutorial.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:expandable/expandable.dart';

class EachWorkoutSearch extends StatefulWidget {
  int rindex;
  EachWorkoutSearch({Key? key, required this.rindex}) : super(key: key);

  @override
  _EachWorkoutSearchState createState() => _EachWorkoutSearchState();
}

class _EachWorkoutSearchState extends State<EachWorkoutSearch>
    with TickerProviderStateMixin {
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
  ExpandableController _menucontroller =
      ExpandableController(initialExpanded: true);

  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  var btnDisabled;
  var _customExUsed = false;
  var selectedItem = '기타';
  var selectedItem2 = '기타';
  bool _isExListShow = true;

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
      _searchExercise(_exSearchCtrl.text);
      btnDisabled == true
          ? null
          : [btnDisabled = true, Navigator.of(context).pop()];
    }
  }

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      leading: Center(
        child: GestureDetector(
          child: Icon(
            Icons.arrow_back_ios_outlined,
            color: Theme.of(context).primaryColorLight,
          ),
          onTap: () {
            _showMyDialog();
          },
        ),
      ),
      title: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: TextField(
              key: keySearch,
              controller: _exSearchCtrl,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
                hintText: "운동 검색",
                hintStyle: TextStyle(
                    fontSize: 20.0, color: Theme.of(context).primaryColorLight),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(width: 2, color: Theme.of(context).cardColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2.0),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (text) {
                filterTotal(
                    _exSearchCtrl.text, _exProvider.tags, _exProvider.tags2);
              }),
        ),
      ),
      actions: [
        IconButton(
          key: keyCheck,
          iconSize: 30,
          icon: Icon(Icons.check_rounded),
          color: Theme.of(context).primaryColorLight,
          onPressed: () {
            _editWorkoutCheck();
            btnDisabled == true
                ? null
                : [btnDisabled = true, Navigator.of(context).pop()];
          },
        )
      ],
      backgroundColor: Theme.of(context).canvasColor,
    );
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userProvider.userdata.email, exercises: _exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  Widget _targetchip(items2) {
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
          runSpacing: 10,
          choiceStyle: const C2ChoiceStyle(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                          _targetchip(options),
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
              padding: EdgeInsets.symmetric(horizontal: 2),
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
                    _workoutProvider.removeexAt(widget.rindex, index);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
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
                        height: 56,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _exImage != ""
                                      ? Image.asset(
                                          _exImage,
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 50,
                                          width: 50,
                                          child: Icon(Icons.image_not_supported,
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle),
                                        ),
                                  _isExListShow
                                      ? Container()
                                      : Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  exlist[index].name,
                                                  textScaleFactor: 1.2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorLight),
                                                ),
                                              ),
                                              Container()
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),
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
                );
              },
              shrinkWrap: shirink,
              itemCount: exlist.length),
          exlist.isEmpty == true
              ? GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        height: 88,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              Theme.of(context).primaryColor),
                                      child: Icon(
                                        Icons.add,
                                        size: 28.0,
                                        color: Theme.of(context).buttonColor,
                                      ),
                                    ),
                                    _isExListShow
                                        ? Container()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 4.0),
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
                              SizedBox(height: 4),
                              _isExListShow
                                  ? Text("오른쪽 클릭",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight))
                                  : Text("오른쪽을 눌러서 추가 할 수 있어요",
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
                      ? _exp1()
                      : provider.filtmenu == 2
                          ? _exp2()
                          : Container(),
                );
              }),
            ),
          ),
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
                return false;
              },
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (details.delta.dx > 0 && _isExListShow == true) {
                    setState(() {
                      _isExListShow = false;
                    });
                    print("Dragging in +X direction");
                  } else if (details.delta.dx < 0 && _isExListShow == false) {
                    setState(() {
                      _isExListShow = true;
                    });
                    print("-x");
                  }
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            child: Center(
                              child: Text("현재 루틴",
                                  textScaleFactor: 1.6,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  )),
                            ),
                          ),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: _isExListShow
                                  ? 78
                                  : MediaQuery.of(context).size.width - 88,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 4.0, left: 1.0),
                                child: SingleChildScrollView(
                                  child: _exercisesWidget(true, true),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 4.0, right: 4.0, top: 36),
                        child: VerticalDivider(
                            color: Theme.of(context).primaryColor,
                            thickness: 2,
                            width: 2),
                      ),
                      Consumer<ExercisesdataProvider>(
                          builder: (builder, provider, child) {
                        return Expanded(
                          child: Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 4.0, right: 1.0),
                              child: Column(
                                children: [
                                  Container(
                                    child: Center(
                                      child: Text("운동 종목",
                                          textScaleFactor: 1.6,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight)),
                                    ),
                                  ),
                                  _exercisesItemWidget(true),
                                  SizedBox(height: 4),
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
                                            height: 80,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 28.0,
                                                            color: Theme.of(
                                                                    context)
                                                                .buttonColor,
                                                          ),
                                                        ),
                                                        _isExListShow
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        "커스텀 운동",
                                                                        textScaleFactor:
                                                                            1.5,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Theme.of(context).primaryColorLight,
                                                                        )),
                                                                  ],
                                                                ),
                                                              )
                                                            : Container()
                                                      ]),
                                                  SizedBox(height: 4),
                                                  _isExListShow
                                                      ? Text(
                                                          "개인 운동을 추가 할 수 있어요",
                                                          textScaleFactor: 1.0,
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorLight,
                                                          ))
                                                      : Text("커스텀",
                                                          textScaleFactor: 1.0,
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
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
                          ),
                        );
                      })
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exercisesItemWidget(bool shirink) {
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
                if (exuniq.length == 1) {
                  top = 20;
                  bottom = 20;
                } else if (index == 0) {
                  top = 20;
                  bottom = 0;
                } else if (index == exuniq.length - 1) {
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
                              (element) => element.name == exuniq[index].name)]
                      .image;
                  if (_exImage == null) {
                    _exImage = "";
                  }
                } catch (e) {
                  _exImage = "";
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _workoutProvider.addexAt(
                          widget.rindex,
                          new wod.Exercises(
                              name: exuniq[index].name,
                              sets: wod.Setslist().setslist,
                              rest: 90,
                              isCardio: exuniq[index].category == "유산소"
                                  ? true
                                  : false));
                    });
                  },
                  child: Container(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(top),
                              bottomRight: Radius.circular(bottom),
                              topLeft: Radius.circular(top),
                              bottomLeft: Radius.circular(bottom))),
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _exImage != ""
                              ? Image.asset(
                                  _exImage,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 50,
                                  width: 50,
                                  child: Icon(Icons.image_not_supported,
                                      color:
                                          Theme.of(context).primaryColorDark),
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle),
                                ),
                          _isExListShow
                              ? Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          exuniq[index].name,
                                          textScaleFactor: 1.2,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
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

  void _searchExercise(String query) async {
    final suggestions =
        await _exProvider.exercisesdata.exercises.map((exercise) {
      final exTitle = exercise.name.toLowerCase().replaceAll(' ', '');
      return (exTitle.contains(query.toLowerCase().replaceAll(' ', '')))
          as bool;
    }).toList();
    _exProvider.settestdata_s(suggestions);
  }

  Widget _exp1() {
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
          runSpacing: 5,
          choiceStyle: C2ChoiceStyle(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Widget _exp2() {
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
          runSpacing: 5,
          choiceStyle: const C2ChoiceStyle(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _exercises = _exProvider.exercisesdata.exercises;
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

      return Scaffold(appBar: _appbarWidget(), body: _exercises_searchWidget());
    });
  }
}
