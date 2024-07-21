import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/search/exercise_filter.dart';
import 'package:sdb_trainer/pages/search/routine_bank.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/themeMode.dart';

class ExSearch extends StatefulWidget {
  ExSearch({Key? key}) : super(key: key);

  @override
  ExSearchState createState() => ExSearchState();
}

class ExSearchState extends State<ExSearch> {
  var _exProvider;
  var _RoutineMenuProvider;
  var _PopProvider;
  var _themeProvider;
  bool modecheck = false;
  PageController? controller;
  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;

  var keyPlus = GlobalKey();
  var keyContainer = GlobalKey();
  var keyCheck = GlobalKey();
  var keySearch = GlobalKey();
  var keySelect = GlobalKey();
  var _menuList;

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          title: Row(
            children: [
              Text(
                "운동 찾기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _workoutWidget() {
    return Column(
      children: [
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Center(
            child: Consumer<RoutineMenuStater>(
                builder: (builder, provider, child) {
              return _ExerciseControllerWidget();
            }),
          ),
        ),
        Consumer<RoutineMenuStater>(builder: (builder, provider, child) {
          return _routinemenuPage();
        }),
      ],
    );
  }

  Widget _ExerciseControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<RoutineMenuStater>(builder: (context, provider, child) {
        _menuList = <int, Widget>{
          0: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text("개별 운동",
                textScaleFactor: 1.3,
                style: TextStyle(
                    color: provider.menustate == 0
                        ? Theme.of(context).highlightColor
                        : Theme.of(context).primaryColorDark)),
          ),
          1: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("루틴 찾기",
                  textScaleFactor: 1.3,
                  style: TextStyle(
                      color: provider.menustate == 1
                          ? Theme.of(context).highlightColor
                          : Theme.of(context).primaryColorDark)))
        };
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CupertinoSlidingSegmentedControl(
              groupValue: provider.menustate,
              children: _menuList,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              thumbColor: Theme.of(context).primaryColor,
              onValueChanged: (i) {
                controller!.animateToPage(i as int,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut);
                provider.change(i);
              }),
        );
      }),
    );
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
          group_by_target(),
          const RoutineBank(),
        ],
      ),
    );
  }

  void filterExercise(List query) {
    final suggestions = _exProvider.exercisesdata.exercises.where((exercise) {
      if (query[0] == 'All') {
        return true;
      } else {
        final extarget = Set.from(exercise.target);
        final queryS = Set.from(query);
        return (queryS.intersection(extarget).isNotEmpty);
      }
    }).toList();
    _exProvider.settestdata_f1(suggestions);
  }

  Widget group_by_target() {
    return Consumer<ThemeProvider>(builder: (builder, provider, child) {
      return GridView.builder(
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 7 / 8,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          var keyList = _themeProvider.userThemeDark == "dark"
              ? ExImage().body_part_image.keys.toList()
              : ExImageLight().body_part_image.keys.toList();
          return GestureDetector(
            onTap: () {
              _PopProvider.searchstackup();
              _exProvider.inittestdata();
              _exProvider.settags([keyList[index].toString()]);
              _exProvider.settags2(['All']);

              filterExercise(_exProvider.tags);
              Navigator.push(
                  context,
                  Transition(
                      child: const ExerciseFilter(),
                      transitionEffect: TransitionEffect.BOTTOM_TO_TOP));
            },
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    color: Colors.grey.withOpacity(0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _themeProvider.userThemeDark == "dark"
                            ? Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: ExImage().body_part_image[keyList[index]] != ''
                                    ? Container(
                                        height: MediaQuery.of(context).size.width / 4,
                                        width: MediaQuery.of(context).size.width / 4,
                                        decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(50)),
                                            image: DecorationImage(
                                              image: AssetImage(ExImage()
                                                  .body_part_image[keyList[index]]),
                                              fit: BoxFit.cover,
                                            )))
                                    : Container(
                                        color: Theme.of(context).primaryColorLight,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 100,
                                        )),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: ExImageLight()
                                            .body_part_image[keyList[index]] !=
                                        ''
                                    ? Container(
                                        height: MediaQuery.of(context).size.width / 4,
                                        width: MediaQuery.of(context).size.width / 4,
                                        decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(50)),
                                            image: DecorationImage(
                                              image: AssetImage(ExImageLight()
                                                  .body_part_image[keyList[index]]),
                                              fit: BoxFit.cover,
                                            )))
                                    : Container(
                                        color: Theme.of(context).primaryColorLight,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 100,
                                        )),
                              ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            '${keyList[index]}',
                            textScaleFactor: 1.3,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);

    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _RoutineMenuProvider =
        Provider.of<RoutineMenuStater>(context, listen: false);

    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: _appbarWidget(),
      body: Stack(
        children: [
          Positioned(
              top: MediaQuery.of(context).size.width * 0.1,
              left: 220,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      Color(0xff7a28cb),
                      Color(0xff8369de),
                      Color(0xff8da0cb)
                    ])),
              )),
          Positioned(
              bottom: MediaQuery.of(context).size.width * 0.1,
              right: 150,
              child: Transform.rotate(
                angle: 8,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [
                        Color(0xff7a28cb),
                        Color(0xff7369de),
                        Color(0xff7da0cb)
                      ])),
                ),
              )),
          Consumer2<ExercisesdataProvider, WorkoutdataProvider>(
              builder: (context, provider1, provider2, widget) {
            if (provider2.workoutdata != null) {
              return _workoutWidget();
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
        ],
      ),
    );
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
