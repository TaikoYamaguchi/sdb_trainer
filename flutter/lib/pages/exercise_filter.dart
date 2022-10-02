import 'package:chips_choice/chips_choice.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/exercise_guide.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:dio/dio.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/src/utils/util.dart';


class ExerciseFilter extends StatefulWidget {
  const ExerciseFilter({Key? key}) : super(key: key);

  @override
  State<ExerciseFilter> createState() => _ExerciseFilterState();
}

class _ExerciseFilterState extends State<ExerciseFilter> {
  var _exercisesdataProvider;
  var _workoutdataProvider;
  var _userdataProvider;
  var _exercises;
  TextEditingController _exSearchCtrl = TextEditingController(text: "");
  TextEditingController _customExNameCtrl = TextEditingController(text: "");
  var _testdata0;
  late var _testdata = _testdata0;
  var btnDisabled;
  var _customExUsed = false;
  var selectedItem = '기타';
  var selectedItem2 = '기타';
  ExpandableController _menucontroller = ExpandableController(initialExpanded: true);




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
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: TextField(
              controller: _exSearchCtrl,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
                hintText: "운동 검색",
                hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
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
                searchExercise(_exSearchCtrl.text);
              }),
        ),
      ),
      actions: null,
      backgroundColor: Colors.black,
    );
  }


  void searchExercise(String query) {
    final suggestions = _exercisesdataProvider.exercisesdata.exercises.where((exercise) {
      final exTitle = exercise.name;
      return (exTitle.contains(query)) as bool;
    }).toList();
    _exercisesdataProvider.settestdata_s(suggestions);

  }

  void filterExercise(List query) {
    final suggestions = _exercisesdataProvider.exercisesdata.exercises.where((exercise) {
      if (query[0]=='All'){
        print('imall');
        return true;
      } else {
        final extarget = Set.from(exercise.target);
        final query_s = Set.from(query);
        return (query_s.intersection(extarget).isNotEmpty) as bool;
      }
    }).toList();
    print(suggestions.length);
    _exercisesdataProvider.settestdata_f1(suggestions);
  }

  void filterExercise2(List query) {
    final suggestions = _exercisesdataProvider.exercisesdata.exercises.where((exercise) {
      if (query[0]=='All'){
        print('imall');
        return true;
      } else {
        final excate = exercise.category;
        return (query.contains(excate)) as bool;
      }
    }).toList();
    print(suggestions.length);
    _exercisesdataProvider.settestdata_f2(suggestions);
  }

  Widget _exercises_searchWidget() {
    return Container(
      color: Colors.black,
      child: Consumer<ExercisesdataProvider>(
          builder: (builder, provider, child) {
            return Container(
              width: MediaQuery.of(context).size.width ,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, right: 1.0),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    exercisesWidget(provider.testdata, true),
                    GestureDetector(
                        onTap: () {
                          _displayCustomExInputDialog(provider);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              height: 80,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
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
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text("커스텀 운동을 추가 해보세요",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18)),
                                            Text("개인 운동을 추가 할 수 있어요",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                        )),

                  ],
                ),
              ),
            );
          }),
    );
  }

  void _displayCustomExInputDialog(provider) {
    showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext context) {
          List<String> options = _exercisesdataProvider.options;
          options.remove('All');
          List<String> options2 = _exercisesdataProvider.options2;
          options2.remove('All');
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
                  '커스텀 운동을 만들어보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                Text('운동의 이름을 입력해 주세요',
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
        });
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
        user_email: _userdataProvider.userdata.email, exercises: _exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
        ? {showToast("수정 완료"), _exercisesdataProvider.getdata()}
        : showToast("입력을 확인해주세요"));
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
                    custom: true));
                _postExerciseCheck();
                print("nulllllllllllll");
                _customExNameCtrl.clear();

                _testdata = provider.exercisesdata.exercises;

                Navigator.of(context).pop();
              }
            },
            child: Text(_customExUsed == true ? "존재하는 운동" : "커스텀 운동 추가",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  Widget exercisesWidget(aaa, bool shirink) {
    double top = 0;
    double bottom = 0;
    return Consumer2<WorkoutdataProvider, ExercisesdataProvider>(
        builder: (builder, provider, provider2, child) {
          var exuniq = provider2.testdata;
          return ListView.separated(
            physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 2),
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
                ;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        Transition(
                            child: ExerciseGuide(exinfo: exuniq[index]),
                            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  },
                  child: Container(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
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
                          Row(
                            children: [
                              Text(
                                exuniq[index].name,
                                style: TextStyle(
                                    fontSize: 21,
                                    color: Colors.white),
                              ),
                              Expanded(child: SizedBox()),
                              Text(
                                  "1RM: ${exuniq[index].onerm.toStringAsFixed(0)}/${exuniq[index].goal.toStringAsFixed(0)}${_userdataProvider.userdata.weight_unit}",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white)),
                            ],
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
              shrinkWrap: true,
              itemCount: exuniq.length);
        });
  }

  Widget exp1() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Consumer<ExercisesdataProvider>(
          builder: (context, provider, child) {
          return ChipsChoice<String>.multiple(
            value: provider.tags,
            onChanged: (val) {
              val.indexOf('All') == val.length-1
                  ? provider.settags(['All'])
                  : [val.remove('All'),provider.settags(val),];
              filterExercise(provider.tags);
            },
            choiceItems: C2Choice.listFrom<String, String>(
              source: provider.options,
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
        }
      ),
    );
  }

  Widget exp2() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Consumer<ExercisesdataProvider>(
        builder: (context, provider, child) {
          return ChipsChoice<String>.multiple(
            value: provider.tags2,
            onChanged: (val) {
              val.indexOf('All') == val.length-1
                  ? provider.settags2(['All'])
                  : [val.remove('All'),provider.settags2(val),];
              filterExercise2(provider.tags2);
            },
            choiceItems: C2Choice.listFrom<String, String>(
              source: provider.options2,
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
        }
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    return Scaffold(
      appBar: _appbarWidget(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Container(
              child: Consumer<ExercisesdataProvider>(
                builder: (context, provider, child) {
                  return ExpandablePanel(
                      controller: _menucontroller,
                      theme: const ExpandableThemeData(
                        headerAlignment:
                        ExpandablePanelHeaderAlignment
                            .center,
                        hasIcon: false,
                        iconColor: Colors.white,
                      ),
                      header: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: (){
                                provider.setfiltmenu(1);
                                _menucontroller.expanded = true;
                            },
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Container(
                                width: MediaQuery.of(context).size.width/2-10,
                                height: _appbarWidget().preferredSize.height*2/3,
                                child: Center(
                                  child: Text("운동부위",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18)),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                                provider.setfiltmenu(2);
                                _menucontroller.expanded = true;
                            },
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Container(
                                width: MediaQuery.of(context).size.width/2-10,
                                height: _appbarWidget().preferredSize.height*2/3,
                                child: Center(
                                  child: Text("운동유형",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18)),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                      collapsed: Container(),
                      expanded: provider.filtmenu == 1 ? exp1() : provider.filtmenu == 2 ? exp2() : Container(),
                  );
                }
              ),
            ),
          ),
          Expanded(child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is UserScrollNotification) {
                  if (notification.direction == ScrollDirection.forward) {
                    //_menucontroller.expanded = true;
                  } else if (notification.direction == ScrollDirection.reverse) {
                    _menucontroller.expanded = false;
                  }
                }

                // Returning null (or false) to
                // "allow the notification to continue to be dispatched to further ancestors".
                return false;
              },
              child: _exercises_searchWidget())),

        ],
      ),

      backgroundColor: Colors.black,
    );
  }
}
