import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html/parser.dart';
import 'package:sdb_trainer/pages/mystat/my_stat.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/notification.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/notification_repository.dart';
import 'package:sdb_trainer/repository/version_repository.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/navigators/exercise_navi.dart';
import 'package:sdb_trainer/navigators/exSearch_navi.dart';
import 'package:sdb_trainer/navigators/profile_navi.dart';
import 'package:sdb_trainer/pages/login/login.dart';
import 'package:sdb_trainer/pages/login/signup.dart';
import 'package:sdb_trainer/pages/feed/feed.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/supero_version.dart';
import 'dart:math' as math;
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/exercise/exercise_done.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'statistics/statics.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _hisProvider;
  var _exProvider;
  var _routinetimeProvider;
  var _notificationProvider;
  var _PopProvider;
  late List<hisdata.Exercises> exerciseList = [];
  var _workoutProvider;
  var _bodyStater;
  var _loginState;
  var _userProvider;
  int updatecount = 0;
  bool _isUpdateNeeded = false;
  final String iOSTestId = 'ca-app-pub-3940256099942544/2934735716';
  final String androidTestId = 'ca-app-pub-3940256099942544/6300978111';

  BannerAd? banner;

  @override
  void initState() {
    openAlert();

    super.initState();
  }

  openAlert() async {
    final order2 = await checkNoti();
    final order = await checkVersion();

    return order2;
  }

  checkVersion() {
    var appUpdateVersion = SuperoVersion.getSuperoVersion().toString();
    VersionService.loadVersionData().then((data) {
      if (data.substring(0, data.length - 1) ==
          appUpdateVersion.substring(0, appUpdateVersion.length - 1)) {
        initialExImageGet(context);
      } else {
        _isUpdateNeeded = true;
        showUpdateVersion(data, context);
      }
    });
    return 0;
  }

  checkNoti() async {
    bool isChecked = false;
    List notiBanlist;
    const storage = FlutterSecureStorage();
    String? storageNotiBanList = await storage.read(key: "sdb_NotiBanList");
    if (storageNotiBanList == null || storageNotiBanList == "") {
      notiBanlist = [];
    } else {
      notiBanlist = jsonDecode(storageNotiBanList);
    }
    NotificationRepository.loadNotificationdataAll().then((value) {
      if (value.notifications.isNotEmpty) {
        for (int i = 0; i < value.notifications.length; i++) {
          if (notiBanlist.contains(value.notifications[i].id)) continue;
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => AlertDialog(
                    insetPadding: const EdgeInsets.all(10),
                    contentPadding: EdgeInsets.zero,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    content: StatefulBuilder(
                      // You need this, notice the parameters below:
                      builder: (BuildContext context, StateSetter setState) {
                        var notificationdata = value.notifications[i];
                        int length;
                        var afterparse = parse(notificationdata.content.html);
                        var body = afterparse.getElementsByTagName("body")[0];
                        length = body.getElementsByTagName("p").length;
                        return Container(
                          padding: const EdgeInsets.all(12.0),
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                                bottom: Radius.circular(10)),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notificationdata.title,
                                              textScaleFactor: 1.8,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorLight),
                                            ),
                                            Text(
                                              notificationdata.date!
                                                  .substring(2, 10),
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      },
                                      icon: Icon(
                                        Icons.cancel_rounded,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ))
                                ],
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListView.builder(
                                                physics: const ScrollPhysics(),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return body
                                                          .getElementsByTagName(
                                                              "p")[index]
                                                          .getElementsByTagName(
                                                              "img")
                                                          .isNotEmpty
                                                      ? Column(
                                                          children: [
                                                            Image(
                                                              image:
                                                                  CachedNetworkImageProvider(
                                                                notificationdata
                                                                        .images![
                                                                    int.parse(body
                                                                        .getElementsByTagName("p")[
                                                                            index]
                                                                        .getElementsByTagName(
                                                                            "img")[0]
                                                                        .attributes["src"]!)],
                                                              ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            const SizedBox(
                                                                height: 5)
                                                          ],
                                                        )
                                                      : body
                                                              .getElementsByTagName(
                                                                  "p")[index]
                                                              .getElementsByTagName(
                                                                  "a")
                                                              .isNotEmpty
                                                          ? Center(
                                                              child: RichText(
                                                                  textScaleFactor:
                                                                      1.2,
                                                                  text: TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                            style:
                                                                                const TextStyle(color: Colors.blueAccent),
                                                                            text: body.getElementsByTagName("p")[index].text,
                                                                            recognizer: TapGestureRecognizer()
                                                                              ..onTap = () async {
                                                                                var url = body.getElementsByTagName("p")[index].getElementsByTagName("a")[0].attributes["href"]!;
                                                                                if (await canLaunchUrlString(url)) {
                                                                                  await launchUrlString(url);
                                                                                } else {
                                                                                  throw 'Could not launch $url';
                                                                                }
                                                                              }),
                                                                        /*
                                                                TextSpan(
                                                                    style: linkText,
                                                                    text: "Click here",

                                                                ),

                                                                 */
                                                                      ])),
                                                            )
                                                          : Column(
                                                              children: [
                                                                Text(
                                                                    body
                                                                        .getElementsByTagName("p")[
                                                                            index]
                                                                        .text,
                                                                    textScaleFactor:
                                                                        1.2,
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .primaryColorLight)),
                                                                const SizedBox(
                                                                    height: 5)
                                                              ],
                                                            );
                                                },
                                                shrinkWrap: true,
                                                itemCount: length),
                                          )),

                                      const SizedBox(height: 4.0),
                                      Column(
                                        children: [
                                          Text('Supero를 사랑해 주심에 감사합니다🤗',
                                              textScaleFactor: 1.2,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark)),
                                        ],
                                      ),
                                      //_commentContent(interviewData),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor:
                                        Theme.of(context).highlightColor,
                                    activeColor: Theme.of(context).primaryColor,
                                    side: BorderSide(
                                        width: 1,
                                        color:
                                            Theme.of(context).primaryColorDark),
                                    value: isChecked,
                                    onChanged: (newvalue) {
                                      setState(() {
                                        isChecked = !isChecked;
                                      });
                                      if (newvalue!) {
                                        addnotistorage(notificationdata.id);
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      } else {
                                        removenotistorage(notificationdata.id);
                                      }
                                    },
                                  ),
                                  Text('다음부터 보지 않기',
                                      textScaleFactor: 1.2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ));
        }
      }
    });
    return 0;
  }

  addnotistorage(nid) async {
    const storage = FlutterSecureStorage();
    String? storageNotiBanList = await storage.read(key: "sdb_NotiBanList");
    if (storageNotiBanList == null || storageNotiBanList == "") {
      List<int> listViewerBuilderString = [nid];
      await storage.write(
          key: 'sdb_NotiBanList', value: jsonEncode(listViewerBuilderString));
    } else {
      List notiBanlist = jsonDecode(storageNotiBanList);
      notiBanlist.add(nid);
      await storage.write(
          key: 'sdb_NotiBanList', value: jsonEncode(notiBanlist));
    }
  }

  removenotistorage(nid) async {
    const storage = FlutterSecureStorage();
    String? storageNotiBanList = await storage.read(key: "sdb_NotiBanList");
    if (storageNotiBanList == null || storageNotiBanList == "") {
    } else {
      List notiBanlist = jsonDecode(storageNotiBanList);
      notiBanlist.removeWhere((item) => item == nid);
      await storage.write(
          key: 'sdb_NotiBanList', value: jsonEncode(notiBanlist));
    }
  }

  void initialExImageGet(context) async {
    final binding = WidgetsFlutterBinding.ensureInitialized();

    binding.addPostFrameCallback((_) async {
      BuildContext context = binding.rootElement!;
      for (Exercises ex in extra_completely_new_Ex) {
        try {
          await precacheImage(AssetImage(ex.image!), context);
        } catch (e) {
          null;
        }
      }
    });
  }

  BottomNavigationBarItem _bottomNavigationBarItem(
      String iconName, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: SvgPicture.asset("assets/svg/$iconName.svg",
            height: 20, width: 20, color: Theme.of(context).primaryColorDark),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: SvgPicture.asset("assets/svg/$iconName.svg",
            height: 20, width: 20, color: Theme.of(context).primaryColorLight),
      ),
      label: label,
    );
  }

  Widget _bottomNavigationBarwidget() {
    return Stack(
      children: [
        ClipRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 2.0,
                  sigmaY: 2.0,
                ),
                child: Container(
                    width: double.maxFinite,
                    height: 55,
                    color: Colors.black.withOpacity(0)))),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).indicatorColor.withOpacity(0.97),
            border: Border.all(width: 0.1, color: Colors.grey),
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Theme.of(context).primaryColorLight,
                    unselectedItemColor: Theme.of(context).primaryColorDark,
                    elevation: 0.0,
                    onTap: (int index) {
                      _bodyStater.change(index);
                    },
                    selectedFontSize: 14,
                    unselectedFontSize: 14,
                    selectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.w500),
                    currentIndex: _bodyStater.bodystate,
                    items: [
                      _bottomNavigationBarItem("search-svgrepo-com", "찾기"),
                      _bottomNavigationBarItem("dumbbell-svgrepo-com-3", "운동"),
                      _bottomNavigationBarItem("heart-svgrepo-com", "피드"),
                      _bottomNavigationBarItem("calendar-svgrepo-com", "기록"),
                      _bottomNavigationBarItem("calendar-svgrepo-com", "stat"),
                      _bottomNavigationBarItem("avatar-svgrepo-com", "프로필"),
                    ],
                  ),
                  LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    return Center(
                      child: SizedBox(
                        width: _bodyStater.bodystate == 0 ||
                                _bodyStater.bodystate == 5
                            ? width
                            : _bodyStater.bodystate == 1 ||
                            _bodyStater.bodystate == 4
                              ? width * 4/6
                              : width * 2/6,
                        child: Align(
                          alignment: _bodyStater.bodystate < 3
                              ? Alignment.bottomLeft
                              : Alignment.bottomRight,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  topLeft: Radius.circular(30)),
                            ),
                            width: width /6,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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

  void _editWorkoutwoCheck() async {
    _uncheckAllSets();

    WorkoutEdit(
      id: _workoutProvider.workoutdata.id,
      user_email: _userProvider.userdata.email,
      routinedatas: _workoutProvider.workoutdata.routinedatas,
    ).editWorkout().then((data) {
      if (data["user_email"] != null) {
        showToast("완료");
      } else {
        showToast("입력을 확인해주세요");
      }
    });
  }

  void _uncheckAllSets() {
    var routineIndex = _routinetimeProvider.nowonrindex;
    var routineData = _workoutProvider.workoutdata.routinedatas[routineIndex];

    for (var exercise in routineData.exercises) {
      for (var set in exercise.sets) {
        set.ischecked = false;
      }
    }
  }

  _showMyDialog_finish() async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return showsimpleAlerts(
            layer: 5,
            rindex: -1,
            eindex: -1,
          );
        });
    if (result == true) {
      if (_workoutProvider.workoutdata
              .routinedatas[_routinetimeProvider.nowonrindex].mode ==
          1) {
        recordExercise_plan();
        _editHistoryCheck();
      } else {
        recordExercise();
        _editHistoryCheck();
      }
      if (exerciseList.isNotEmpty) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return showsimpleAlerts(
                layer: 5,
                rindex: -1,
                eindex: 1,
              );
            });
      }
    }
  }

  void recordExercise_plan() {
    var exercise_all = _workoutProvider
        .workoutdata
        .routinedatas[_routinetimeProvider.nowonrindex]
        .exercises[0]
        .plans[_workoutProvider
            .workoutdata
            .routinedatas[_routinetimeProvider.nowonrindex]
            .exercises[0]
            .progress]
        .exercises;
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
      var eachex = _exProvider.exercisesdata.exercises[_exProvider
          .exercisesdata.exercises
          .indexWhere((element) => element.name == exercise_all[n].name)];
      if (!recordedsets.isEmpty) {
        exerciseList.add(hisdata.Exercises(
            name: exercise_all[n].name,
            sets: recordedsets,
            onerm: monerm,
            goal: eachex.goal,
            date: DateTime.now().toString().substring(0, 10),
            isCardio: eachex.category == "유산소" ? true : false));
      }
      if (monerm > eachex.onerm) {
        modifyExercise(monerm, exercise_all[n].name);
      }
    }
    _postExerciseCheck();
  }

  void recordExercise() {
    var exercise_all = _workoutProvider
        .workoutdata.routinedatas[_routinetimeProvider.nowonrindex].exercises;
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
      var eachex = _exProvider.exercisesdata.exercises[_exProvider
          .exercisesdata.exercises
          .indexWhere((element) => element.name == exercise_all[n].name)];
      if (!recordedsets.isEmpty) {
        exerciseList.add(hisdata.Exercises(
            name: exercise_all[n].name,
            sets: recordedsets,
            onerm: monerm,
            goal: eachex.goal,
            date: DateTime.now().toString().substring(0, 10),
            isCardio: eachex.category == "유산소" ? true : false));
      }

      if (monerm > eachex.onerm) {
        modifyExercise(monerm, exercise_all[n].name);
      }
    }
    _postExerciseCheck();
  }

  void _editHistoryCheck() async {
    if (exerciseList.isNotEmpty) {
      HistoryPost(
              user_email: _userProvider.userdata.email,
              exercises: exerciseList,
              new_record: _routinetimeProvider.routineNewRecord,
              workout_time: _routinetimeProvider.routineTime,
              nickname: _userProvider.userdata.nickname)
          .postHistory()
          .then((data) => data["user_email"] != null
              ? {
                  _hisProvider.getdata(),
                  _hisProvider.getHistorydataAll(),
                  Navigator.of(context, rootNavigator: true).pop(),
                  Navigator.push(
                      context,
                      Transition(
                          child: ExerciseDone(
                              exerciseList: exerciseList,
                              routinetime: _routinetimeProvider.routineTime,
                              sdbdata: hisdata.SDBdata.fromJson(data)),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT)),
                  if (_workoutProvider
                          .workoutdata
                          .routinedatas[_routinetimeProvider.nowonrindex]
                          .mode ==
                      1)
                    {_editWorkoutCheck()}
                  else
                    {_editWorkoutwoCheck()},
                  _routinetimeProvider.routinecheck(0),
                  _routinetimeProvider.getprefs(_workoutProvider.workoutdata
                      .routinedatas[_routinetimeProvider.nowonrindex].name),
                  _hisProvider.getdata(),
                  _hisProvider.getHistorydataAll(),
                  exerciseList = []
                }
              : showToast("입력을 확인해주세요"));
    } else {
      _routinetimeProvider.routinecheck(0);
    }
  }

  void modifyExercise(double newonerm, exname) {
    _exProvider
        .exercisesdata
        .exercises[_exProvider.exercisesdata.exercises
            .indexWhere((element) => element.name == exname)]
        .onerm = newonerm;
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
            user_email: _userProvider.userdata.email,
            exercises: _exProvider.exercisesdata.exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
            ? {showToast("수정 완료"), _exProvider.getdata()}
            : showToast("입력을 확인해주세요"));
  }

  Widget _initialLoginWidget() {
    return Center(
      child: Column(
        children: [
          SafeArea(
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              GestureDetector(
                onTap: () {
                  userLogOut(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("로그아웃",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              )
            ]),
          ),
          const Expanded(flex: 3, child: SizedBox(height: 6)),
          Text("SUPERO",
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 54,
                  fontWeight: FontWeight.w800)),
          Text("우리의 운동 극복 스토리",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500)),
          const Expanded(flex: 4, child: SizedBox(height: 6)),
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(),
          ),
          const SizedBox(height: 12),
          const Text("전세계 운동인들과 연결중...",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const Expanded(flex: 1, child: SizedBox(height: 6)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    _notificationProvider =
        Provider.of<NotificationdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);

    return Consumer4<BodyStater, LoginPageProvider, HistorydataProvider,
            UserdataProvider>(
        builder: (builder, provider1, provider2, provider3, provider4, child) {
      return WillPopScope(
        onWillPop: () async {
          final shouldPop;
          shouldPop = false;
          [
            _bodyStater.bodystate == 1
                ? _PopProvider.popon()
                : _bodyStater.bodystate == 4
                    ? _PopProvider.propopon()
                    : _bodyStater.bodystate == 0
                        ? _PopProvider.searchpopon()
                        : null
          ];

          return shouldPop!;
        },
        child: Scaffold(
            body: _loginState.isLogin
                ? _userProvider.userdata == null ||
                        _hisProvider.historydataAll == null
                    ? _initialLoginWidget()
                    : IndexedStack(
                        index: _bodyStater.bodystate,
                        children: const <Widget>[
                            SearchNavigator(),
                            TabNavigator(),
                            Feed(),
                            Calendar(),
                            MyStat(),
                            TabProfileNavigator()
                          ])
                : _loginState.isSignUp
                    ? const SignUpPage()
                    : LoginPage(isUpdateNeeded: _isUpdateNeeded),
            floatingActionButton: Consumer<RoutineTimeProvider>(
                builder: (builder, provider, child) {
              return Container(
                child: (provider.isstarted && _bodyStater.bodystate != 1)
                    ? ExpandableFab(
                        distance: 105,
                        children: [
                          SizedBox(
                              width: 100,
                              height: 40,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    textStyle: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                    ),
                                    disabledForegroundColor:
                                        const Color.fromRGBO(246, 58, 64, 20),
                                    padding: const EdgeInsets.all(12.0),
                                  ),
                                  onPressed: () {
                                    provider.restcheck();
                                  },
                                  child: Text(
                                      provider.userest
                                          ? provider.timeron < 0
                                              ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                                              : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                                          : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                                      style: TextStyle(
                                          color: (provider.userest &&
                                                  provider.timeron < 0)
                                              ? Colors.red
                                              : Theme.of(context)
                                                  .highlightColor)))),
                          Row(
                            children: [
                              ActionButton(
                                onPressed: () {
                                  _PopProvider.gotoon();
                                  _bodyStater.change(1);
                                },
                                icon: const Icon(Icons.play_arrow),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ActionButton(
                                onPressed: () {
                                  _showMyDialog_finish();
                                },
                                icon: const Icon(Icons.stop),
                              ),
                            ],
                          ),
                        ],
                      )
                    : null,
              );
            }),
            bottomNavigationBar: _loginState.isLogin
                ? _userProvider.userdata == null ||
                        _hisProvider.historydataAll == null
                    ? null
                    : _bottomNavigationBarwidget()
                : null),
      );
    });
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    Key? key,
    this.initialOpen,
    required this.distance,
    required this.children,
  }) : super(key: key);

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = widget.distance;
    for (var i = 0, distances = 50.0; i < count; i++, distances += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 0,
          maxDistance: distances,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: () {
              _toggle();
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Consumer<RoutineTimeProvider>(
                builder: (builder, provider, child) {
              return Text(
                  provider.userest
                      ? provider.timeron < 0
                          ? '-${(-provider.timeron / 60).floor().toString()}:${((-provider.timeron % 60) / 10).floor().toString()}${((-provider.timeron % 60) % 10).toString()}'
                          : '${(provider.timeron / 60).floor().toString()}:${((provider.timeron % 60) / 10).floor().toString()}${((provider.timeron % 60) % 10).toString()}'
                      : '${(provider.routineTime / 60).floor().toString()}:${((provider.routineTime % 60) / 10).floor().toString()}${((provider.routineTime % 60) % 10).toString()}',
                  style: TextStyle(
                      color: (provider.userest && provider.timeron < 0)
                          ? Colors.red
                          : Theme.of(context).highlightColor));
            }),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees,
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 8 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).primaryColor,
          elevation: 4.0,
          child: IconButton(
            iconSize: 20,
            onPressed: onPressed,
            icon: icon,
            color: Theme.of(context).highlightColor,
          ),
        ),
      ),
    );
  }
}
