import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/statics.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import '../src/model/historydata.dart' as historyModel;
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/src/utils/my_flexible_space_bar.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'dart:ui' as ui;
import 'dart:math';

class ExerciseGuide extends StatefulWidget {
  int eindex;
  bool isroutine;
  ExerciseGuide({Key? key, required this.eindex, this.isroutine = false})
      : super(key: key);

  @override
  State<ExerciseGuide> createState() => _ExerciseGuideState();
}

class _ExerciseGuideState extends State<ExerciseGuide> {
  var btnDisabled;
  var _tapPosition;
  late Map<DateTime, List<historyModel.SDBdata>> selectedEvents;
  var _userProvider;
  var _exProvider;
  var _PopProvider;
  var _workoutProvider;
  TextEditingController _exercisenoteCtrl = TextEditingController(text: '');
  bool editing = false;
  var _exercises;
  var _hisProvider;
  var selectedItem = '기타';
  var selectedItem2 = '기타';
  var _customExUsed = false;
  var _delete = false;
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  List<historyModel.Exercises>? _sdbChartData = [];
  var _chartIndex;
  TextEditingController _customExNameCtrl = TextEditingController(text: "");
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");

  @override
  void initState() {
    // TODO: implement initState
    _tapPosition = Offset(0.0, 0.0);
    selectedEvents = {};
    _tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior = ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enableSelectionZooming: true,
        selectionRectBorderColor: Colors.red,
        selectionRectBorderWidth: 2,
        selectionRectColor: Colors.white,
        enablePanning: true,
        maximumZoomLevel: 0.7);
    super.initState();
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
            btnDisabled == true
                ? null
                : [btnDisabled = true, Navigator.of(context).pop()];
          },
        ),
      ),
      title: Container(),
      actions: null,
      backgroundColor: Theme.of(context).canvasColor,
    );
  }

  Widget Status() {
    return Container(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Consumer<ExercisesdataProvider>(
                builder: (context, provier, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 5,
                          child: Center(
                            child: Text("Target",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold)),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Center(
                          child: Text(
                              provier.exercisesdata.exercises[widget.eindex]
                                          .target.length ==
                                      1
                                  ? provier.exercisesdata
                                      .exercises[widget.eindex].target[0]
                                  : '${provier.exercisesdata.exercises[widget.eindex].target.toString().substring(1, provier.exercisesdata.exercises[widget.eindex].target.toString().length - 1)}',
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 5,
                          child: Center(
                            child: Text("Category",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold)),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Center(
                          child: Text(
                              '${provier.exercisesdata.exercises[widget.eindex].category}',
                              textScaleFactor: 1.2,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 5,
                          child: Center(
                            child: Text("1rm",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold)),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Center(
                          child: Text(
                              '${provier.exercisesdata.exercises[widget.eindex].onerm.toStringAsFixed(0)}${_userProvider.userdata.weight_unit}',
                              textScaleFactor: 1.2,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 5,
                          child: Center(
                            child: Text("Goal",
                                textScaleFactor: 1.2,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold)),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Center(
                          child: Text(
                              '${provier.exercisesdata.exercises[widget.eindex].goal.toStringAsFixed(0)}${_userProvider.userdata.weight_unit}',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget exercisenote() {
    return Container(
        child: Padding(
            padding: const EdgeInsets.all(0),
            child: Card(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            alignment: Alignment.centerLeft,
                            child: Text("나만의 운동 노트",
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold)),
                          ),
                          editing
                              ? Container(
                                  child: IconButton(
                                    onPressed: () {
                                      _exProvider
                                          .exercisesdata
                                          .exercises[widget.eindex]
                                          .note = _exercisenoteCtrl.text;
                                      _postExerciseCheck();
                                      setState(() {
                                        editing = !editing;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : Container(
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        editing = !editing;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                )
                        ],
                      ),
                      editing
                          ? _commentWidget()
                          : Container(
                              padding: const EdgeInsets.all(12.0),
                              alignment: Alignment.centerLeft,
                              child: Consumer<ExercisesdataProvider>(
                                  builder: (context, provier, child) {
                                return Text(
                                    provier.exercisesdata
                                            .exercises[widget.eindex].note ??
                                        '나만의 운동노트를 적어주세요',
                                    textScaleFactor: 1.3,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        fontWeight: FontWeight.bold));
                              }),
                            ),
                    ],
                  ),
                ))));
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userProvider.userdata.email,
            exercises: _exProvider.exercisesdata.exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료")}
            : showToast("입력을 확인해주세요"));
  }

  void _displayCustomExInputDialog(provider) {
    showModalBottomSheet<void>(
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
              _customExNameCtrl.text =
                  _exProvider.exercisesdata.exercises[widget.eindex].name;
              selectedItem =
                  _exProvider.exercisesdata.exercises[widget.eindex].target;
              selectedItem2 =
                  _exProvider.exercisesdata.exercises[widget.eindex].category;
              return Container(
                padding: EdgeInsets.all(12.0),
                height: 390,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  children: [
                    Text(
                      '커스텀 운동을 수정해보세요',
                      textScaleFactor: 2.0,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                    Text('운동의 정보를 입력해 주세요',
                        textScaleFactor: 1.3,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight)),
                    Text('외부를 터치하면 취소 할 수 있어요',
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
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
                              color: Theme.of(context).primaryColorLight)),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            '운동부위:',
                            textScaleFactor: 2.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight),
                          ),
                        ),
                        SizedBox(width: 20),
                        Container(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 2 / 5,
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  enabledBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        width: 3),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
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
                                items: options
                                    .map((item) => DropdownMenuItem<String>(
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
                                    () => selectedItem = item as String),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            '카테고리:',
                            textScaleFactor: 2.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight),
                          ),
                        ),
                        SizedBox(width: 20),
                        Container(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 2 / 5,
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  enabledBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        width: 3),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
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
                                    .map((item) => DropdownMenuItem<String>(
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
                    target: [selectedItem],
                    custom: true,
                    note: ''));
                _postExerciseCheck();
                _customExNameCtrl.clear();

                Navigator.of(context).pop();
              }
            },
            child: Text(_customExUsed == true ? "존재하는 운동" : "커스텀 운동 추가",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  Widget _commentWidget() {
    _exercisenoteCtrl.text =
        _exProvider.exercisesdata.exercises[widget.eindex].note ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
          controller: _exercisenoteCtrl,
          keyboardType: TextInputType.multiline,
          //expands: true,
          maxLines: null,
          decoration: InputDecoration(
              labelText: '운동에 관해 적을 수 있어요',
              labelStyle: TextStyle(
                  fontSize: 16.0, color: Theme.of(context).primaryColorDark),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              fillColor: Theme.of(context).primaryColorLight),
          style: TextStyle(color: Theme.of(context).primaryColorLight)),
    );
  }

  Widget _Add_to_Plan_Button() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
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
                disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                padding: EdgeInsets.all(12.0),
              ),
              onPressed: () {
                planlist();
              },
              child: Text("플랜에 운동 추가하기",
                  textScaleFactor: 1.7,
                  style: TextStyle(color: Theme.of(context).buttonColor)))),
    );
  }

  void _editWorkoutCheck() async {
    WorkoutEdit(
            user_email: _userProvider.userdata.email,
            id: _workoutProvider.workoutdata.id,
            routinedatas: _workoutProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
            ? [showToast("done!")]
            : showToast("입력을 확인해주세요"));
  }

  Widget _MyWorkout() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 10,
          ),
          Center(
            child: Text(
              '추가할 플랜을 선택하세요',
              textScaleFactor: 2.0,
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Text('외부를 터치하면 취소 할 수 있어요',
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorDark)),
          Container(
            height: 10,
          ),
          Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
            final routinelist =
                provider.workoutdata.routinedatas.where((element) {
              return element.mode == 0;
            }).toList();

            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (BuildContext _context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _workoutProvider.addexAt(
                          provider.workoutdata.routinedatas.indexWhere(
                              (e) => e.name == routinelist[index].name),
                          new wod.Exercises(
                              name: _exProvider
                                  .exercisesdata.exercises[widget.eindex].name,
                              sets: wod.Setslist().setslist,
                              rest: 90));
                      _editWorkoutCheck();
                      Navigator.of(context).pop();

                      print("checkcccc");
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return showsimpleAlerts(
                              layer: 4,
                              rindex: 0,
                              eindex: 0,
                            );
                          });
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Card(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            elevation: 8.0,
                            margin: new EdgeInsets.symmetric(
                                horizontal: 0, vertical: 6.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5.0),
                                leading: Container(
                                    height: double.infinity,
                                    padding: EdgeInsets.only(right: 15.0),
                                    decoration: new BoxDecoration(
                                        border: new Border(
                                            right: new BorderSide(
                                                width: 1.0,
                                                color: Theme.of(context)
                                                    .primaryColorLight))),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: SizedBox(
                                        width: 25,
                                        child: SvgPicture.asset(
                                            "assets/svg/dumbel_on.svg",
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                      ),
                                    )),
                                title: Text(
                                  routinelist[index].name,
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  children: [
                                    routinelist[index].mode == 0
                                        ? Text(
                                            "${routinelist[index].exercises.length}개 운동",
                                            textScaleFactor: 1.0,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorLight))
                                        : Text("루틴 모드",
                                            textScaleFactor: 1.0,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorLight)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: routinelist.length);
          }),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    //color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GestureDetector(
                    onTap: () {
                      _displayTextInputDialog();
                    },
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("운동 플랜을 만들어 보세요",
                                    textScaleFactor: 1.5,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                                Text("원하는 이름, 종류의 플랜을 만들 수 있어요",
                                    textScaleFactor: 1.1,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorDark)),
                              ],
                            ),
                          )
                        ]),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void planlist() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: _MyWorkout());
      },
    );
  }

  void _displayTextInputDialog() {
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
            return Color(0xFF101012);
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
                '운동 루틴을 추가 할게요',
                textScaleFactor: 2.0,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('운동 루틴의 이름을 입력해 주세요',
                      textScaleFactor: 1.3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                  Text('외부를 터치하면 취소 할 수 있어요',
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark)),
                  SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      _workoutProvider.workoutdata.routinedatas
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
                    style: TextStyle(
                        fontSize: 24.0,
                        color: Theme.of(context).primaryColorLight),
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
                        hintStyle: TextStyle(
                            fontSize: 24.0,
                            color: Theme.of(context).primaryColorLight)),
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
                borderRadius: BorderRadius.circular(8.0),
              ),
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor:
                  _workoutNameCtrl.text == "" || _customExUsed == true
                      ? Color(0xFF212121)
                      : Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (!_customExUsed && _workoutNameCtrl.text != "") {
                _workoutProvider.addroutine(new wod.Routinedatas(
                    name: _workoutNameCtrl.text,
                    mode: 0,
                    exercises: [],
                    routine_time: 0));
                _editWorkoutCheck();
                _workoutNameCtrl.clear();
                Navigator.of(context, rootNavigator: true).pop();
              }
              ;
            },
            child: Text(_customExUsed == true ? "존재하는 루틴 이름" : "새 루틴 추가",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  void _getChartSourcefromDay() async {
    _sdbChartData = [];
    if (_hisProvider.historydata == null) {
      await initialHistorydataGet();
    }
    var _sdbChartDataExample = _hisProvider.historydata.sdbdatas
        .map((name) => name.exercises
            .where((name) => name.name ==
                    _exProvider.exercisesdata!.exercises[widget.eindex].name
                ? true
                : false)
            .toList())
        .toList();
    for (int i = 0; i < _sdbChartDataExample.length; i++) {
      if (_sdbChartDataExample[i].isEmpty) {
        null;
      } else {
        for (int k = 0; k < _sdbChartDataExample[i].length; k++) {
          _sdbChartData!.add(_sdbChartDataExample[i][k]);
        }
      }
    }
  }

  _showMyDialog() async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return showsimpleAlerts(
            layer: 6,
            rindex: -1,
            eindex: -1,
          );
        });
    if (result == true) {
      setState(() {
        _delete = !_delete;
      });

      _exProvider.removeExdata(widget.eindex);
      _postExerciseCheck();
      _exProvider.settestdata_d();

      Navigator.of(context).pop();
    }
  }

  initialHistorydataGet() async {
    final _initHistorydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    final _initExercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);

    _initExercisesdataProvider.getdata();
    await _initHistorydataProvider.getdata();
  }

  Widget _chartWidget(context) {
    final List<Color> color = <Color>[];
    color.add(Color(0xFffc60a8).withOpacity(0.7));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Color(0xFffc60a8).withOpacity(0.7));

    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.4);
    stops.add(0.6);
    stops.add(1.0);

    final LinearGradient gradientColors = LinearGradient(
        colors: color,
        stops: stops,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);
    return (Center(
        child: Column(
      children: [
        Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20))),
            child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: DateTimeAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  axisLine: const AxisLine(width: 0),
                ),
                primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    majorGridLines: const MajorGridLines(width: 0),
                    minimum: _sdbChartData!.length == 0
                        ? 0
                        : _sdbChartData!.length > 1
                            ? _sdbChartData!
                                    .reduce((curr, next) =>
                                        curr.onerm! < next.onerm! ? curr : next)
                                    .onerm! *
                                0.9
                            : _sdbChartData![0].onerm),
                tooltipBehavior: _tooltipBehavior,
                zoomPanBehavior: _zoomPanBehavior,
                legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    textStyle:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                series: [
                  // Renders line chart
                  LineSeries<historyModel.Exercises, DateTime>(
                    isVisibleInLegend: true,
                    color: Color(0xFF101012),
                    name: "goal",
                    dataSource: _sdbChartData!,
                    xValueMapper: (historyModel.Exercises sales, _) =>
                        DateTime.parse(sales.date!),
                    yValueMapper: (historyModel.Exercises sales, _) =>
                        sales.goal,
                  ),

                  LineSeries<historyModel.Exercises, DateTime>(
                    isVisibleInLegend: true,
                    onCreateShader: (ShaderDetails details) {
                      return ui.Gradient.linear(details.rect.topRight,
                          details.rect.bottomLeft, color, stops);
                    },
                    markerSettings: MarkerSettings(
                        isVisible: true,
                        height: 6,
                        width: 6,
                        borderWidth: 3,
                        color: Theme.of(context).primaryColor,
                        borderColor: Theme.of(context).primaryColor),
                    name: "1rm",
                    color: Theme.of(context).primaryColor,
                    width: 5,
                    dataSource: _sdbChartData!,
                    xValueMapper: (historyModel.Exercises sales, _) =>
                        DateTime.parse(sales.date!),
                    yValueMapper: (historyModel.Exercises sales, _) =>
                        sales.onerm,
                  ),
                ])),
        _onechartExercisesWidget(_sdbChartData)
      ],
    )));
  }

  Widget _onechartExercisesWidget(exercises) {
    return ListView.separated(
        itemBuilder: (BuildContext _context, int index) {
          return _onechartExerciseWidget(
              exercises[index], 0, _userProvider.userdata, true, index);
        },
        separatorBuilder: (BuildContext _context, int index) {
          return Container(
            alignment: Alignment.center,
            height: 0,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 0,
              color: Color(0xFF717171),
            ),
          );
        },
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: exercises.length,
        scrollDirection: Axis.vertical);
  }

  Widget _onechartExerciseWidget(
      exuniq, history_id, userdata, bool shirink, index) {
    double top = 20;
    double bottom = 20;
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(exuniq.date,
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(top),
                      bottomRight: Radius.circular(bottom),
                      topLeft: Radius.circular(top),
                      bottomLeft: Radius.circular(bottom))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chartExerciseSetsWidget(exuniq.sets),
                  Container(
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("",
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Color(0xFF717171))),
                        Expanded(child: SizedBox()),
                        Text(
                            "1RM: " +
                                exuniq.onerm.toStringAsFixed(1) +
                                "/${exuniq.goal.toStringAsFixed(1)}${userdata.weight_unit}",
                            textScaleFactor: 0.8,
                            style: TextStyle(color: Color(0xFF717171))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _chartExerciseSetsWidget(sets) {
    return Container(
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.all(5.0),
              height: 28,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 25,
                          child: Text(
                            "Set",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: 70,
                      child: Text(
                        "Weight(${_userProvider.userdata.weight_unit})",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Container(width: 35),
                  Container(
                      width: 40,
                      child: Text(
                        "Reps",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Container(
                      width: 70,
                      child: Text(
                        "1RM",
                        textScaleFactor: 1.1,
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ],
              )),
          SizedBox(
            child: ListView.separated(
                itemBuilder: (BuildContext _context, int index) {
                  return Container(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 25,
                                child: Text(
                                  "${index + 1}",
                                  textScaleFactor: 1.7,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 70,
                          child: Text(
                            sets[index].weight.toStringAsFixed(1),
                            textScaleFactor: 1.7,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            width: 35,
                            child: SvgPicture.asset("assets/svg/multiply.svg",
                                color: Theme.of(context).primaryColorLight,
                                height: 19)),
                        Container(
                          width: 40,
                          child: Text(
                            sets[index].reps.toString(),
                            textScaleFactor: 1.7,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            width: 70,
                            child: (sets[index].reps != 1)
                                ? Text(
                                    "${(sets[index].weight * (1 + sets[index].reps / 30)).toStringAsFixed(1)}",
                                    textScaleFactor: 1.7,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    "${sets[index].weight}",
                                    textScaleFactor: 1.7,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    textAlign: TextAlign.center,
                                  )),
                      ],
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
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: sets.length),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _chartIndex = Provider.of<ChartIndexProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _getChartSourcefromDay();
    _PopProvider = Provider.of<PopProvider>(context, listen: false);

    return Consumer<PopProvider>(builder: (builder, provider, child) {
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
      return Scaffold(
        body: _delete
            ? Container()
            : CustomScrollView(slivers: [
                SliverAppBar(
                  snap: false,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).canvasColor,
                  actions: [
                    _exProvider.exercisesdata.exercises[widget.eindex].custom &&
                            !widget.isroutine
                        ? Container(
                            child: IconButton(
                              onPressed: () {
                                _showMyDialog();
                              },
                              icon: Icon(
                                Icons.delete,
                                size: 25,
                                color: Theme.of(context).primaryColorLight,
                              ),
                            ),
                          )
                        : Container()
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
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            child: Text(
                          _exProvider
                              .exercisesdata.exercises[widget.eindex].name,
                          textScaleFactor: 1.1,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                        )),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, _index) {
                      return Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Status(),
                              SizedBox(height: 20),
                              exercisenote(),
                              SizedBox(height: 20),
                              _chartWidget(context)
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: 1,
                  ),
                ),
              ]),
        bottomNavigationBar: _Add_to_Plan_Button(),
      );
    });
  }
}
