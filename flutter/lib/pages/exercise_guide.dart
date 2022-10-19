import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/src/utils/my_flexible_space_bar.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class ExerciseGuide extends StatefulWidget {
  int eindex;
  bool isroutine;
  ExerciseGuide({Key? key, required this.eindex, this.isroutine = false}) : super(key: key);

  @override
  State<ExerciseGuide> createState() => _ExerciseGuideState();
}

class _ExerciseGuideState extends State<ExerciseGuide> {
  var btnDisabled;
  var _userdataProvider;
  var _exercisesdataProvider;
  var _workoutdataProvider;
  TextEditingController _exercisenoteCtrl = TextEditingController(text: '');
  bool editing = false;
  var _exercises;
  var selectedItem = '기타';
  var selectedItem2 = '기타';
  var _customExUsed = false;
  var _delete = false;
  TextEditingController _customExNameCtrl = TextEditingController(text: "");
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return AppBar(
      titleSpacing: 0,
      leading: Center(
        child: GestureDetector(
          child: Icon(Icons.arrow_back_ios_outlined),
          onTap: () {
            btnDisabled == true
                ? null
                : [btnDisabled = true, Navigator.of(context).pop()];
          },
        ),
      ),
      title: Container(),
      actions: null,
      backgroundColor: Color(0xFF101012),
    );
  }

  Widget Status() {
    return Container(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Center(
                          child: Text(
                              provier.exercisesdata.exercises[widget.eindex].target.length == 1
                                  ? provier.exercisesdata.exercises[widget.eindex].target[0]
                                  : '${provier.exercisesdata.exercises[widget.eindex].target.toString().substring(1,provier.exercisesdata.exercises[widget.eindex].target.toString().length-1)}'
                              ,
                              style: TextStyle(color: Colors.white)),
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Center(
                          child: Text(
                              '${provier.exercisesdata.exercises[widget.eindex].category}'
                              ,
                              style: TextStyle(color: Colors.white)),
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Center(
                          child: Text(
                              '${provier.exercisesdata.exercises[widget.eindex].onerm.toStringAsFixed(0)}${_userdataProvider.userdata.weight_unit}',
                              style: TextStyle(color: Colors.white)),
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Center(
                          child: Text(
                              '${provier.exercisesdata.exercises[widget.eindex].goal.toStringAsFixed(0)}${_userdataProvider.userdata.weight_unit}',
                              style: TextStyle(color: Colors.white)),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.centerLeft,
                child: Text("나만의 운동 Note",
                    style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
              editing
                  ? Container(
                      child: IconButton(
                        onPressed: () {
                          _exercisesdataProvider
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
                          size: 30,
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
                          size: 25,
                          color: Colors.white,
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
                        provier.exercisesdata.exercises[widget.eindex].note ??
                            '나만의 운동노트를 적어주세요',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold));
                  }),
                ),
        ],
      ),
    );
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userdataProvider.userdata.email,
            exercises: _exercisesdataProvider.exercisesdata.exercises)
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
          List<String> options = [..._exercisesdataProvider.options];
          options.remove('All');
          List<String> options2 = [..._exercisesdataProvider.options2];
          options2.remove('All');
          return SingleChildScrollView(
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter mystate) {
              _customExNameCtrl.text = _exercisesdataProvider
                  .exercisesdata.exercises[widget.eindex].name;
              selectedItem = _exercisesdataProvider
                  .exercisesdata.exercises[widget.eindex].target;
              selectedItem2 = _exercisesdataProvider
                  .exercisesdata.exercises[widget.eindex].category;
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
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text('운동의 정보를 입력해 주세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text('외부를 터치하면 취소 할 수 있어요',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(height: 20),
                    TextField(
                      onChanged: (value) {
                        _exercisesdataProvider.exercisesdata.exercises
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
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
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
                          hintStyle:
                              TextStyle(fontSize: 24.0, color: Colors.white)),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            '운동부위:',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                        SizedBox(width: 20),
                        Container(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 2 / 5,
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                dropdownColor: Color(0xFF101012),
                                decoration: InputDecoration(
                                  filled: true,
                                  enabledBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 3),
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
                                      style: TextStyle(color: Colors.white),
                                    )),
                                items: options
                                    .map((item) => DropdownMenuItem<String>(
                                        value: item.toString(),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                  color: Colors.white),
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
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                        SizedBox(width: 20),
                        Container(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 2 / 5,
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                dropdownColor: Color(0xFF101012),
                                decoration: InputDecoration(
                                  filled: true,
                                  enabledBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 3),
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
                                      style: TextStyle(color: Colors.white),
                                    )),
                                items: options2
                                    .map((item) => DropdownMenuItem<String>(
                                        value: item.toString(),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                  color: Colors.white),
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (_customExUsed == false && _customExNameCtrl.text != "") {
                _exercisesdataProvider.addExdata(Exercises(
                    name: _customExNameCtrl.text,
                    onerm: 0,
                    goal: 0,
                    image: null,
                    category: selectedItem2,
                    target: [selectedItem],
                    custom: true,
                    note: ''));
                _postExerciseCheck();
                print("nulllllllllllll");
                _customExNameCtrl.clear();

                Navigator.of(context).pop();
              }
            },
            child: Text(_customExUsed == true ? "존재하는 운동" : "커스텀 운동 추가",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  Widget _commentWidget() {
    _exercisenoteCtrl.text =
        _exercisesdataProvider.exercisesdata.exercises[widget.eindex].note ??
            '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
          controller: _exercisenoteCtrl,
          keyboardType: TextInputType.multiline,
          //expands: true,
          maxLines: null,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit, color: Colors.white),
              labelText: '운동에 대한 노트를 적어주세요',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: Colors.white),
          style: TextStyle(color: Colors.white)),
    );
  }

  void _displayFinishAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            buttonPadding: EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.all(12.0),
            title: Text(
              '커스텀운동을 삭제 할 수 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('커스텀운동을 삭제 하시겠나요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('외부를 터치하면 취소 할 수 있어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            actions: <Widget>[
              _FinishConfirmButton(),
            ],
          );
        });
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
                  color: Colors.white,
                ),
                disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
                padding: EdgeInsets.all(12.0),
              ),
              onPressed: () {
                planlist();

              },
              child: Text("플랜에 운동 추가하기",
                  style: TextStyle(fontSize: 20.0, color: Colors.white)))),
    );
  }

  void _editWorkoutCheck() async {
    WorkoutEdit(
        user_email: _userdataProvider.userdata.email,
        id: _workoutdataProvider.workoutdata.id,
        routinedatas: _workoutdataProvider.workoutdata.routinedatas)
        .editWorkout()
        .then((data) => data["user_email"] != null
        ? [showToast("done!")]
        : showToast("입력을 확인해주세요"));
  }

  Widget _MyWorkout() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Color(0xFF101012),
      ),

      child: ListView(
        shrinkWrap: true,
        children: [
          Container(height: 10,),
          Center(
            child: Text('추가할 플랜을 선택하세요' ,style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
            ),
          ),
          Text('외부를 터치하면 취소 할 수 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          Container(height: 10,),
          Consumer<WorkoutdataProvider>(builder: (builder, provider, child) {
            final routinelist = provider.workoutdata.routinedatas.where((element){return element.mode == 0;}).toList();

            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (BuildContext _context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _workoutdataProvider.addexAt(
                          provider.workoutdata.routinedatas.indexWhere((e) => e.name == routinelist[index].name),
                          new wod.Exercises(
                              name: _exercisesdataProvider
                                  .exercisesdata.exercises[widget.eindex].name,
                              sets: wod.Setslist().setslist,
                              rest: 90));
                      _editWorkoutCheck();
                      Navigator.of(context).pop();

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
                                      borderRadius:
                                      BorderRadius.circular(15.0)),
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
                                                    color: Colors.white24))),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: SizedBox(
                                            width: 25,
                                            child: SvgPicture.asset(
                                                "assets/svg/dumbel_on.svg",
                                                color: Colors.white30),
                                          ),
                                        )
                                      ),
                                      title: Text(
                                        routinelist[index].name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          routinelist[index].mode == 0
                                              ? Text(
                                              "${routinelist[index].exercises.length}개 운동",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white30))
                                              : Text("루틴 모드",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white30)),
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
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("운동 플랜을 만들어 보세요",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                Text("원하는 이름, 종류의 플랜을 만들 수 있어요",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14)),
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
              color: Color(0xFF101012),
            ),
            child: _MyWorkout()
        );
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (!_customExUsed && _workoutNameCtrl.text != "") {
                _workoutdataProvider.addroutine(new wod.Routinedatas(
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
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  Widget _FinishConfirmButton() {
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
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              setState(() {
                _delete = !_delete;
              });

              _exercisesdataProvider.removeExdata(widget.eindex);
              _postExerciseCheck();
              _exercisesdataProvider.settestdata_d();

              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop();
            },
            child: Text("커스텀 운동 삭제 하기",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    return Scaffold(
      body: _delete
          ? Container()
          : CustomScrollView(slivers: [
              SliverAppBar(
                snap: true,
                floating: true,
                pinned: true,
                actions: [
                  _exercisesdataProvider
                          .exercisesdata.exercises[widget.eindex].custom && !widget.isroutine
                      ? Container(
                          child: IconButton(
                            onPressed: () {
                              _displayFinishAlert();
                            },
                            icon: Icon(
                              Icons.delete,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container()
                ],
                leading: Center(
                  child: GestureDetector(
                    child: Icon(Icons.arrow_back_ios_outlined),
                    onTap: () {
                      btnDisabled == true
                          ? null
                          : [btnDisabled = true, Navigator.of(context).pop()];
                    },
                  ),
                ),
                expandedHeight: _appbarWidget().preferredSize.height * 2,
                collapsedHeight: _appbarWidget().preferredSize.height,
                backgroundColor: Color(0xFF101012),
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
                        _exercisesdataProvider
                            .exercisesdata.exercises[widget.eindex].name,
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      )),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, _index) {
                    return Column(
                      children: [
                        Container(
                          child: Column(
                            children: [Status(), exercisenote()],
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: 1,
                ),
              ),

            ]
      ),
      backgroundColor: Color(0xFF101012),
      bottomNavigationBar: _Add_to_Plan_Button(),
    );
  }
}
