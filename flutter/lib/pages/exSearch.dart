import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/exercise_filter.dart';
import 'package:sdb_trainer/pages/routine_bank.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:tutorial/tutorial.dart';
import 'package:sdb_trainer/providers/themeMode.dart';

class ExSearch extends StatefulWidget {
  ExSearch({Key? key}) : super(key: key);

  @override
  ExSearchState createState() => ExSearchState();
}

class ExSearchState extends State<ExSearch> {
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  var _userProvider;
  var _exProvider;
  var _workoutProvider;
  var _RoutineMenuProvider;
  var _PopProvider;
  var _themeProvider;
  bool modecheck = false;
  PageController? controller;
  List<Map<String, dynamic>> datas = [];
  double top = 0;
  double bottom = 0;
  int swap = 1;
  String _title = "Workout List";

  var keyPlus = GlobalKey();
  var keyContainer = GlobalKey();
  var keyCheck = GlobalKey();
  var keySearch = GlobalKey();
  var keySelect = GlobalKey();
  var _menuList;

  List<TutorialItem> itens = [];

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
              "+버튼을 눌러 원하는 이름의 루틴을 추가하세요",
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
    });

    ///FUNÇÃO QUE EXIBE O TUTORIAL.

    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          title: Row(
            children: [
              Text(
                "운동 찾기",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _workoutWidget() {
    return Container(
      child: Column(
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
      ),
    );
  }

  Widget _ExerciseControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<RoutineMenuStater>(builder: (context, provider, child) {
        _menuList = <int, Widget>{
          0: Padding(
            child: Text("개별 운동",
                textScaleFactor: 1.3,
                style: TextStyle(
                    color: provider.menustate == 0
                        ? Theme.of(context).buttonColor
                        : Theme.of(context).primaryColorDark)),
            padding: const EdgeInsets.all(5.0),
          ),
          1: Padding(
              child: Text("루틴 찾기",
                  textScaleFactor: 1.3,
                  style: TextStyle(
                      color: provider.menustate == 1
                          ? Theme.of(context).buttonColor
                          : Theme.of(context).primaryColorDark)),
              padding: const EdgeInsets.all(5.0))
        };
        return Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CupertinoSlidingSegmentedControl(
                groupValue: provider.menustate,
                children: _menuList,
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                thumbColor: Theme.of(context).primaryColor,
                onValueChanged: (i) {
                  controller!.animateToPage(i as int,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut);
                  provider.change(i);
                }),
          ),
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
          RoutineBank(),
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
        final query_s = Set.from(query);
        return (query_s.intersection(extarget).isNotEmpty) as bool;
      }
    }).toList();
    _exProvider.settestdata_f1(suggestions);
  }

  Widget group_by_target() {
    return Consumer<ThemeProvider>(builder: (builder, provider, child) {
      return Container(
        child: GridView.builder(
          itemCount: 12,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 7 / 8,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            var key_list = _themeProvider.userThemeDark == "dark"
                ? ExImage().body_part_image.keys.toList()
                : ExImageLight().body_part_image.keys.toList();
            return GestureDetector(
              onTap: () {
                _PopProvider.searchstackup();
                _exProvider.inittestdata();
                _exProvider.settags([key_list[index].toString()]);
                _exProvider.settags2(['All']);

                filterExercise(_exProvider.tags);
                Navigator.push(
                    context,
                    Transition(
                        child: ExerciseFilter(),
                        transitionEffect: TransitionEffect.BOTTOM_TO_TOP));
              },
              child: Card(
                elevation: 0,
                color: Theme.of(context).canvasColor,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _themeProvider.userThemeDark == "dark"
                          ? Padding(
                              padding: EdgeInsets.all(1.0),
                              child: ExImage()
                                          .body_part_image[key_list[index]] !=
                                      ''
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.width / 4,
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50)),
                                          image: DecorationImage(
                                            image: new AssetImage(
                                                ExImage().body_part_image[
                                                    key_list[index]]),
                                            fit: BoxFit.cover,
                                          )))
                                  : Container(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 100,
                                      )),
                            )
                          : Padding(
                              padding: EdgeInsets.all(1.0),
                              child: ExImageLight()
                                          .body_part_image[key_list[index]] !=
                                      ''
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.width / 4,
                                      width:
                                          MediaQuery.of(context).size.width / 4,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50)),
                                          image: DecorationImage(
                                            image: new AssetImage(
                                                ExImageLight().body_part_image[
                                                    key_list[index]]),
                                            fit: BoxFit.cover,
                                          )))
                                  : Container(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 100,
                                      )),
                            ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          '${key_list[index]}',
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
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);

    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _RoutineMenuProvider =
        Provider.of<RoutineMenuStater>(context, listen: false);

    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: _appbarWidget(),
      body: Consumer2<ExercisesdataProvider, WorkoutdataProvider>(
          builder: (context, provider1, provider2, widget) {
        if (provider2.workoutdata != null) {
          return _workoutWidget();
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }),
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
