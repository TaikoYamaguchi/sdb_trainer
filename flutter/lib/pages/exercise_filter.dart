import 'package:chips_choice/chips_choice.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:dio/dio.dart';


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
  var _testdata0;
  late var _testdata = _testdata0;
  var btnDisabled;
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
                          //_displayCustomExInputDialog(provider);
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
      /*
      CustomScrollView(
          slivers: [
            SliverAppBar(
              snap: true,
              floating: true,
              pinned: false,
              expandedHeight: _appbarWidget().preferredSize.height*5,
              collapsedHeight: _appbarWidget().preferredSize.height,
              backgroundColor: Colors.black,

              leading: null,

              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    Container(height: _appbarWidget().preferredSize.height,),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black,
                      child: ChipsChoice<String>.multiple(
                        value: tags,
                        onChanged: (val) => setState((){
                          tags = val;
                          print(tags.length);
                        } ),
                        choiceItems: C2Choice.listFrom<String, String>(
                          source: options,
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
                      ),
                    ),
                  ],
                ),
              )
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate((context, _index) {
                return Container(
                    child: _exercises_searchWidget(),
                );
              },
                childCount: 1,
              ),
            )


          ]
      ),

       */

      backgroundColor: Colors.black,
    );
  }
}
