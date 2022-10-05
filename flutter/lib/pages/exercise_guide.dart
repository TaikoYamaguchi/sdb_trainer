import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/src/utils/my_flexible_space_bar.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class ExerciseGuide extends StatefulWidget {
  int eindex;
  ExerciseGuide({Key? key, required this.eindex}) : super(key: key);

  @override
  State<ExerciseGuide> createState() => _ExerciseGuideState();
}

class _ExerciseGuideState extends State<ExerciseGuide> {
  var btnDisabled;
  var _userdataProvider;
  var _exercisesdataProvider;
  TextEditingController _exercisenoteCtrl = TextEditingController(text: '');
  bool editing = false;
  var _exercises;
  var selectedItem = '기타';
  var selectedItem2 = '기타';
  var _customExUsed = false;
  var _delete = false;
  TextEditingController _customExNameCtrl = TextEditingController(text: "");

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return AppBar(
      titleSpacing: 0,
      leading:Center(
        child: GestureDetector(
          child: Icon(Icons.arrow_back_ios_outlined),
          onTap: () {
            btnDisabled == true
                ? null
                : [btnDisabled = true, Navigator.of(context).pop()];
          },
        ),
      ),
      title: Container(
      ),
      actions: null,
      backgroundColor: Colors.black,
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
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8.0),
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
                              child: Text("1rm",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            )),
                        SizedBox(
                          width: 100,
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
                          width: 100,
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
              }
            ),
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
                      onPressed: (){
                        _exercisesdataProvider.exercisesdata.exercises[widget.eindex].note = _exercisenoteCtrl.text;
                        _postExerciseCheck();
                        setState(() {
                          editing = !editing;


                        });
                      },
                      icon: Icon(Icons.check, size: 30, color: Theme.of(context).primaryColor,),
                    ),
                  )

                  : Container(
                    child: IconButton(
                      onPressed: (){
                        setState(() {
                          editing = !editing;
                        });
                      },
                      icon: Icon(Icons.edit, size: 25, color: Colors.white,),
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
                    return Text(provier.exercisesdata.exercises[widget.eindex].note ?? '나만의 운동노트를 적어주세요',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold));
                  }
                ),
              ),
        ],
      ),
    );
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
        user_email: _userdataProvider.userdata.email, exercises: _exercisesdataProvider.exercisesdata.exercises)
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
                  _customExNameCtrl.text = _exercisesdataProvider.exercisesdata.exercises[widget.eindex].name;
                  selectedItem = _exercisesdataProvider.exercisesdata.exercises[widget.eindex].target;
                  selectedItem2 = _exercisesdataProvider.exercisesdata.exercises[widget.eindex].category;
                  return Container(
                    padding: EdgeInsets.all(12.0),
                    height: 390,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      color: Theme.of(context).cardColor,
                    ),
                    child:  Column(
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
                                    color: Theme.of(context).primaryColor, width: 3),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor, width: 3),
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
                                    dropdownColor: Colors.black,
                                    decoration: InputDecoration(
                                      filled: true,
                                      enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 3),
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
                                    items: options.map((item) => DropdownMenuItem<String>(
                                        value: item.toString(),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(item,
                                              style: TextStyle(color: Colors.white),)
                                        ))).toList(),
                                    onChanged: (item) =>
                                        setState(() => selectedItem = item as String),
                                  )
                              ),
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
                                    dropdownColor: Colors.black,
                                    decoration: InputDecoration(
                                      filled: true,
                                      enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide:
                                        BorderSide(color: Colors.white, width: 3),
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
                                    items: options2.map((item) => DropdownMenuItem<String>(
                                        value: item.toString(),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(item,
                                              style: TextStyle(color: Colors.white),)
                                        ))).toList(),
                                    onChanged: (item) =>
                                        setState(() => selectedItem2 = item as String),
                                  )
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _customExSubmitButton(context, provider)
                      ],
                    ),
                  );
                }
            ),
          );
        });
  }

  Widget _customExSubmitButton(context, provider) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),),
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: _customExNameCtrl.text == "" || _customExUsed == true
                  ? Color(0xFF212121)
                  : Theme.of(context).primaryColor,
              textStyle: TextStyle(color: Colors.white,),
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
    _exercisenoteCtrl.text= _exercisesdataProvider.exercisesdata.exercises[widget.eindex].note ?? '';
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

  Widget _FinishConfirmButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),),
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor,
              textStyle: TextStyle(color: Colors.white,),
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
    _exercisesdataProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    return Scaffold(
      body: _delete
          ? Container()
          : CustomScrollView(
          slivers: [
            SliverAppBar(
              snap: true,
              floating: true,
              pinned: true,
              actions: [
                _exercisesdataProvider.exercisesdata.exercises[widget.eindex].custom
                    ? Container(
                        child: IconButton(
                          onPressed: (){
                            _displayFinishAlert();
                          },
                          icon: Icon(Icons.delete, size: 25, color: Colors.white,),
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
              expandedHeight: _appbarWidget().preferredSize.height*2,
              collapsedHeight: _appbarWidget().preferredSize.height,
              backgroundColor: Colors.black,

              flexibleSpace: myFlexibleSpaceBar(
                expandedTitleScale: 1.2,
                titlePaddingTween: EdgeInsetsTween(begin: EdgeInsets.only(left: 12.0, bottom: 8), end: EdgeInsets.only(left: 60.0, bottom: 8)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        _exercisesdataProvider.exercisesdata.exercises[widget.eindex].name,
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      )
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, _index) {
                return Container(
                  child: Column(
                    children: [
                      Status(),
                      exercisenote()
                    ],
                  ),
                );
              },
                childCount: 1,
              ),
            )
          ]
      ),
      backgroundColor: Colors.black,
    );
  }
}
