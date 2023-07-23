import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import '../../src/model/historydata.dart' as historyModel;
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/src/utils/my_flexible_space_bar.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
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
  late Map<DateTime, List<historyModel.SDBdata>> selectedEvents;
  var _userProvider;
  var _exProvider;
  var _themeProvider;
  var _workoutProvider;
  final TextEditingController _exercisenoteCtrl =
      TextEditingController(text: '');
  bool editing = false;
  var _hisProvider;
  var selectedItem = '기타';
  var selectedItem2 = '기타';
  var _customExUsed = false;
  var _delete = false;
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  List<historyModel.Exercises>? _sdbChartData = [];
  final TextEditingController _workoutNameCtrl =
      TextEditingController(text: "");

  @override
  void initState() {
    // TODO: implement initState
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
    return SizedBox(
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
                      const SizedBox(height: 4),
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
                      const SizedBox(height: 4),
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
                      const SizedBox(height: 4),
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
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold)),
                          )),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Center(
                          child: Text(
                              '${provier.exercisesdata.exercises[widget.eindex].goal.toStringAsFixed(0)}${_userProvider.userdata.weight_unit}',
                              textScaleFactor: 1.2,
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
    return Padding(
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
                          ? IconButton(
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
                            )
                          : IconButton(
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
                                provier.exercisesdata.exercises[widget.eindex]
                                        .note ??
                                    '나만의 운동노트를 적어주세요',
                                textScaleFactor: 1.3,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.bold));
                          }),
                        ),
                ],
              ),
            )));
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
                disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
                padding: const EdgeInsets.all(12.0),
              ),
              onPressed: () {
                planlist();
              },
              child: Text("플랜에 운동 추가하기",
                  textScaleFactor: 1.7,
                  style: TextStyle(color: Theme.of(context).highlightColor)))),
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

  Widget _myWorkout() {
    return Container(
      decoration: const BoxDecoration(
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
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (BuildContext _context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _workoutProvider.addexAt(
                          provider.workoutdata.routinedatas.indexWhere(
                              (e) => e.name == routinelist[index].name),
                          wod.Exercises(
                              name: _exProvider
                                  .exercisesdata.exercises[widget.eindex].name,
                              sets: wod.Setslist().setslist,
                              rest: 90,
                              isCardio: _exProvider.exercisesdata
                                          .exercises[widget.eindex].category ==
                                      "유산소"
                                  ? true
                                  : false));
                      _editWorkoutCheck();
                      Navigator.of(context).pop();
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
                    child: Column(
                      children: [
                        Card(
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 0.3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 6.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15.0)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5.0),
                              leading: Container(
                                  height: double.infinity,
                                  padding: const EdgeInsets.only(right: 15.0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              width: 1.0,
                                              color: Theme.of(context)
                                                  .primaryColorLight))),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
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
                                    color: Theme.of(context).primaryColorLight,
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
                              color: Theme.of(context).highlightColor,
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: _myWorkout());
      },
    );
  }

  void _displayTextInputDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              buttonPadding: const EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).cardColor,
              contentPadding: const EdgeInsets.all(12.0),
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
                  const SizedBox(height: 20),
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
                      ? const Color(0xFF212121)
                      : Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (!_customExUsed && _workoutNameCtrl.text != "") {
                _workoutProvider.addroutine(wod.Routinedatas(
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
    color.add(const Color(0xFffc60a8).withOpacity(0.7));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(Theme.of(context).primaryColor.withOpacity(0.9));
    color.add(const Color(0xFffc60a8).withOpacity(0.7));

    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.4);
    stops.add(0.6);
    stops.add(1.0);

    return (Center(
        child: Column(
      children: [
        Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
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
                    minimum: _sdbChartData!.isEmpty
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
                    color: const Color(0xFF101012),
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
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 0,
              color: const Color(0xFF717171),
            ),
          );
        },
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: exercises.length,
        scrollDirection: Axis.vertical);
  }

  Widget _onechartExerciseWidget(
      exuniq, historyId, userdata, bool shirink, index) {
    double top = 20;
    double bottom = 20;
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(exuniq.date,
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Theme.of(context).primaryColorLight)),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("",
                        textScaleFactor: 1.0,
                        style: TextStyle(color: Color(0xFF717171))),
                    const Expanded(child: SizedBox()),
                    Text(
                        "1RM: " +
                            exuniq.onerm.toStringAsFixed(1) +
                            "/${exuniq.goal.toStringAsFixed(1)}${userdata.weight_unit}",
                        textScaleFactor: 0.8,
                        style: const TextStyle(color: Color(0xFF717171))),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _chartExerciseSetsWidget(sets) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(5.0),
            height: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
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
                SizedBox(
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
                SizedBox(
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
                SizedBox(
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
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
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
                      SizedBox(
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
                      SizedBox(
                          width: 35,
                          child: SvgPicture.asset("assets/svg/multiply.svg",
                              color: Theme.of(context).primaryColorLight,
                              height: 14 * _themeProvider.userFontSize / 0.8)),
                      SizedBox(
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
                      SizedBox(
                          width: 70,
                          child: (sets[index].reps != 1)
                              ? Text(
                                  "${(sets[index].weight * (1 + sets[index].reps / 30)).toStringAsFixed(1)}",
                                  textScaleFactor: 1.7,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "${sets[index].weight}",
                                  textScaleFactor: 1.7,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight),
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
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 0.5,
                    color: Theme.of(context).primaryColorDark,
                  ),
                );
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sets.length),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _getChartSourcefromDay();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);

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
                  automaticallyImplyLeading: false,
                  snap: false,
                  floating: false,
                  pinned: true,
                  backgroundColor:
                      Theme.of(context).canvasColor.withOpacity(0.9),
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
                        begin: const EdgeInsets.only(left: 12.0, bottom: 8),
                        end: const EdgeInsets.only(left: 60.0, bottom: 8)),
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
                      var _exImage;
                      try {
                        _exImage = extra_completely_new_Ex[
                                extra_completely_new_Ex.indexWhere((element) =>
                                    element.name ==
                                    _exProvider.exercisesdata
                                        .exercises[widget.eindex].name)]
                            .image;
                        _exImage ??= "";
                      } catch (e) {
                        _exImage = "";
                      }

                      return Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _exImage != ""
                                  ? Image.asset(
                                      _exImage,
                                      height: 240,
                                      width: 240,
                                      fit: BoxFit.cover,
                                    )
                                  : const SizedBox(height: 12),
                              Status(),
                              const SizedBox(height: 20),
                              exercisenote(),
                              const SizedBox(height: 20),
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
