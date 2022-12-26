import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:like_button/like_button.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart' as uex;
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'dart:io';
import 'dart:async';

class ProgramDownload extends StatefulWidget {
  Famous program;
  ProgramDownload({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  _ProgramDownloadState createState() => _ProgramDownloadState();
}

class _ProgramDownloadState extends State<ProgramDownload> {
  var _userProvider;
  var _famousdataProvider;
  var _workoutProvider;
  var _exProvider;
  var _PopProvider;
  var _routinetimeProvider;
  var _btnDisabled;
  List<JustTheController> tooltipController = [];
  List<TextEditingController> _onermController = [];
  TextEditingController _famousimageCtrl = TextEditingController(text: "");
  TextEditingController _programtitleCtrl = TextEditingController(text: "");
  TextEditingController _programcommentCtrl = TextEditingController(text: "");
  TextEditingController _workoutNameCtrl = TextEditingController(text: "");
  Map item_map = {0: "뉴비", 1: "초급", 2: '중급', 3: '상급', 4: '엘리트'};
  Map item_map2 = {
    0: "기타",
    1: "근비대",
    2: '근력',
    3: '근지구력',
    4: '바디빌딩',
    5: '파워리프팅',
    6: '역도'
  };
  List<ExpandableController> Controllerlist = [];
  var _selectImage;
  List ref_exercise = [];
  List do_exercise = [];
  List exercise_names = [];
  List ref_exercise_index = [];
  var _customRuUsed = false;

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    _btnDisabled = false;
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              _btnDisabled == true
                  ? null
                  : [
                      _btnDisabled = true,
                      Navigator.of(context).pop(),
                    ];
            },
          ),
          title: Text(
            "",
            textScaleFactor: 2.7,
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _programDownloadWidget() {
    _famousdataProvider.weekchangepre(0);
    return Column(
      children: [
        Container(
            child: Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    widget.program.image != ""
                        ? CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(widget.program.image),
                            backgroundColor: Colors.transparent)
                        : Icon(
                            Icons.account_circle,
                            color: Colors.grey,
                            size: 100.0,
                          ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.program.category.toString(),
                                textScaleFactor: 1.2,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold)),
                            Text(widget.program.routinedata.name,
                                textScaleFactor: 2.0,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: Center(
                                    child: Text("기간",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                            fontWeight: FontWeight.bold)),
                                  )),
                              SizedBox(
                                width: 100,
                                child: Center(
                                  child: Text(
                                      '${widget.program.routinedata.exercises[0].plans.length.toString()}days',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)),
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
                                    child: Text("난이도",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                            fontWeight: FontWeight.bold)),
                                  )),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 5,
                                child: Center(
                                  child: Text(
                                      '${item_map[widget.program.level]}',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 5,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: _famousLikeButton(),
                                ),
                              )),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    child: Center(
                                  child: Icon(
                                      Icons.supervised_user_circle_sharp,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      size: 20),
                                )),
                                SizedBox(
                                    child: Center(
                                        child: Text(
                                            " ${widget.program.subscribe.toString()}",
                                            textScaleFactor: 1.3,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorLight)))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.centerLeft,
                child: Text("Program 설명",
                    textScaleFactor: 2.0,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.centerLeft,
                child: Text(widget.program.routinedata.routine_time,
                    textScaleFactor: 1.7,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.centerLeft,
                child: Text("세부사항",
                    textScaleFactor: 2.0,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontWeight: FontWeight.bold)),
              ),
              Consumer<FamousdataProvider>(builder: (builder, provider, child) {
                return Column(
                  children: [
                    Container(
                        height: 40,
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: techChips())),
                    _Nday_RoutineWidget(),
                  ],
                );
              }),
            ]),
          ),
        )),
        _Start_Program_Button()
      ],
    );
  }

  Widget _Nday_RoutineWidget() {
    return Consumer2<FamousdataProvider, ExercisesdataProvider>(
        builder: (builder, famous, exinfo, child) {
      var plandata = famous.download.routinedata.exercises[0];
      int num_week = (plandata.plans.length / 7).ceil();
      var inplandata = plandata.plans[plandata.progress].exercises;
      var uniqexinfo = exinfo.exercisesdata.exercises;
      for (int s = 0; s < 40; s++) {
        tooltipController.add(new JustTheController());
      }
      ;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        color: Color(0xFF101012),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 36,
              child: Row(
                children: [
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      padding: EdgeInsets.all(3),
                      constraints: BoxConstraints(),
                      onPressed: () {
                        if (plandata.progress % 7 > 0) {
                          _famousdataProvider
                              .progresschange(plandata.progress - 1);
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_outlined,
                        color: Theme.of(context).primaryColorLight,
                        size: 20,
                      )),
                  Container(
                    width: 10,
                  ),
                  Container(
                    child: Text(
                      'Day ${plandata.progress % 7 + 1}',
                      textScaleFactor: 2.0,
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      padding: EdgeInsets.all(3),
                      constraints: BoxConstraints(),
                      onPressed: () {
                        if (_famousdataProvider.week + 1 != num_week) {
                          if (plandata.progress % 7 < 6) {
                            _famousdataProvider
                                .progresschange(plandata.progress + 1);
                          }
                        } else if (plandata.progress % 7 <
                            plandata.plans.length % 7 - 1) {
                          _famousdataProvider
                              .progresschange(plandata.progress + 1);
                        } else if (plandata.plans.length % 7 == 0) {
                          if (plandata.progress % 7 < 6) {
                            _famousdataProvider
                                .progresschange(plandata.progress + 1);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Theme.of(context).primaryColorLight,
                        size: 20,
                      )),
                  Container(
                    width: 10,
                  ),
                ],
              ),
            ),
            Divider(
              indent: 10,
              thickness: 1.3,
              color: Colors.grey,
            ),
            ListView(
              shrinkWrap: true,
              physics: new NeverScrollableScrollPhysics(),
              children: [
                inplandata.isEmpty
                    ? Center(
                        child: Container(
                            child: Column(
                        children: [
                          Container(
                            height: 30,
                          ),
                          Text(
                            '오늘은 휴식데이!',
                            textScaleFactor: 2.0,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            height: 20,
                          ),
                          Container(
                            height: 30,
                          ),
                        ],
                      )))
                    : Container(
                        child: ListView.builder(
                          physics: new NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext _context, int index) {
                            var refinfo = uniqexinfo[uniqexinfo.indexWhere(
                                (element) =>
                                    element.name ==
                                    inplandata[index].ref_name)];
                            Controllerlist.add(ExpandableController(
                              initialExpanded: true,
                            ));
                            return Container(
                              child: Column(
                                children: [
                                  ExpandablePanel(
                                      controller: Controllerlist[index],
                                      theme: ExpandableThemeData(
                                        headerAlignment:
                                            ExpandablePanelHeaderAlignment
                                                .center,
                                        hasIcon: true,
                                        iconColor:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                      header: Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              inplandata[index].name,
                                              textScaleFactor: 1.7,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorLight),
                                            ),
                                            Container(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: Text(
                                                  '기준: ${inplandata[index].ref_name}',
                                                  textScaleFactor: 1.1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                tooltipController[index]
                                                    .showTooltip();
                                              },
                                              child: JustTheTooltip(
                                                controller:
                                                    tooltipController[index],
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.info_outline_rounded,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                content: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '각자의 기준 운동 1rm X 무게비(%)로 운동 중량이 설정됩니다. 내 ${inplandata[index].ref_name} 1rm: ${refinfo.onerm.toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColorLight),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      collapsed:
                                          Container(), // body when the widget is Collapsed, I didnt need anything here.
                                      expanded: Container(
                                        child: ListView.builder(
                                          physics:
                                              new NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext _context,
                                              int setindex) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(),
                                                Row(
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        '기준 1rm   X   ${(inplandata[index].sets[setindex].weight).toStringAsFixed(0)}%    X    ${inplandata[index].sets[setindex].reps}reps',
                                                        textScaleFactor: 1.7,
                                                        style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorLight,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                          shrinkWrap: true,
                                          itemCount:
                                              inplandata[index].sets.length,
                                        ),
                                      ) // body when the widget is Expanded
                                      ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 10,
                                      ),
                                      Container(
                                        width: 10,
                                      ),
                                      Container(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    indent: 10,
                                    thickness: 1.3,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            );
                          },
                          shrinkWrap: true,
                          itemCount: inplandata.length,
                        ),
                      ),
                Container(
                  height: 10,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  List<Widget> techChips() {
    List<Widget> chips = [];
    int num_week =
        (widget.program.routinedata.exercises[0].plans.length / 7).ceil();
    for (int i = 0; i < num_week; i++) {
      Widget item = Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: ChoiceChip(
          label: Text('week${i + 1}'),
          labelStyle: TextStyle(color: Theme.of(context).primaryColorLight),
          selected: _famousdataProvider.week == i,
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onSelected: (bool value) {
            _famousdataProvider.weekchange(i);
          },
        ),
      );
      chips.add(item);
    }
    return chips;
  }

  Widget _famousLikeButton() {
    var buttonSize = 20.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: LikeButton(
        size: buttonSize,
        isLiked: onIsLikedCheck(),
        circleColor:
            CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
        bubblesColor: BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              Icons.thumb_up_off_alt_rounded,
              color: isLiked
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColorLight,
              size: buttonSize,
            ),
          );
        },
        onTap: (bool isLiked) async {
          return onLikeButtonTapped(isLiked);
        },
        likeCount: widget.program.like.length,
        countBuilder: (int? count, bool isLiked, String text) {
          var color = isLiked
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColorLight;
          Widget result;
          if (count == 0) {
            result = Text(
              text,
              textScaleFactor: 1.3,
              style: TextStyle(color: color),
            );
          } else
            result = Text(
              text,
              textScaleFactor: 1.3,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            );
          return result;
        },
      ),
    );
  }

  bool onIsLikedCheck() {
    if (widget.program.like.contains(_userProvider.userdata.email)) {
      return true;
    } else {
      return false;
    }
  }

  bool onLikeButtonTapped(
    bool isLiked,
  ) {
    if (isLiked == true) {
      FamousLike(
              famous_id: widget.program.id,
              user_email: _userProvider.userdata.email,
              status: "remove",
              disorlike: "like")
          .patchFamousLike();
      _famousdataProvider.patchFamousLikedata(
          widget.program, _userProvider.userdata.email, "remove");
      return false;
    } else {
      FamousLike(
              famous_id: widget.program.id,
              user_email: _userProvider.userdata.email,
              status: "append",
              disorlike: "like")
          .patchFamousLike();
      _famousdataProvider.patchFamousLikedata(
          widget.program, _userProvider.userdata.email, "append");
      return !isLiked;
    }
  }

  Widget _Start_Program_Button() {
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
                for (int p = 0;
                    p < widget.program.routinedata.exercises[0].plans.length;
                    p++) {
                  for (int e = 0;
                      e <
                          widget.program.routinedata.exercises[0].plans[p]
                              .exercises.length;
                      e++) {
                    ref_exercise.add(widget.program.routinedata.exercises[0]
                        .plans[p].exercises[e].ref_name);
                    do_exercise.add(widget.program.routinedata.exercises[0]
                        .plans[p].exercises[e].name);
                  }
                }
                for (int s = 0;
                    s < _exProvider.exercisesdata.exercises.length;
                    s++) {
                  exercise_names
                      .add(_exProvider.exercisesdata.exercises[s].name);
                }
                ref_exercise = ref_exercise.toSet().toList();
                do_exercise = do_exercise.toSet().toList();
                for (int i = 0; i < do_exercise.length; i++) {
                  exercise_names.contains(do_exercise[i])
                      ? null
                      : [
                          _exProvider.addExdata(uex.Exercises(
                              name: do_exercise[i],
                              onerm: 0,
                              goal: 0,
                              image: null,
                              category: 'custom',
                              target: ['custom'],
                              custom: true,
                              note: '')),
                          exercise_names.add(do_exercise[i])
                        ];
                }
                for (int i = 0; i < ref_exercise.length; i++) {
                  exercise_names.contains(ref_exercise[i])
                      ? null
                      : _exProvider.addExdata(uex.Exercises(
                          name: ref_exercise[i],
                          onerm: 0,
                          goal: 0,
                          image: null,
                          category: 'custom',
                          target: ['custom'],
                          custom: true,
                          note: ''));
                  ref_exercise_index.add(_exProvider.exercisesdata.exercises
                      .indexWhere(
                          (element) => element.name == ref_exercise[i]));
                }
                _postExerciseCheck();
                ref_exercise_index = ref_exercise_index.toSet().toList();

                _displayStartAlert();
              },
              child: Text("시작하기",
                  textScaleFactor: 1.7,
                  style:
                      TextStyle(color: Theme.of(context).primaryColorLight)))),
    );
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

  void _displayStartAlert() {
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
              '운동을 시작 할 수 있어요',
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('운동을 시작 할까요?',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                Text('외부를 터치하면 취소 할 수 있어요',
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            actions: <Widget>[
              _StartConfirmButton(),
            ],
          );
        });
  }

  Widget _StartConfirmButton() {
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
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              setSetting();
            },
            child: Text("운동 시작 하기",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  void setSetting() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(12.0),
          height: MediaQuery.of(context).size.height * 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            children: [
              Container(
                child: Text(
                  '본인의 1rm이 맞나요? ',
                  textScaleFactor: 2.0,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
              ),
              Container(
                child: Text('아니라면 값을 수정 해주세요',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ),
              Container(
                child: Text('외부를 터치하면 취소 할 수 있어요',
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: MediaQuery.of(context).size.width * 2 / 4,
                        child: Center(
                          child: Text(
                            "운동",
                            textScaleFactor: 1.5,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: MediaQuery.of(context).size.width * 1 / 4,
                        child: Center(
                          child: Text("1rm",
                              textScaleFactor: 1.5,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        )),
                  ],
                ),
              ),
              _neededlist(),
              _1rmConfirmButton()
            ],
          ),
        );
      },
    );
  }

  void titleSetting() {
    _workoutNameCtrl.text = widget.program.routinedata.name;
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(12.0),
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              children: [
                Container(
                  child: Text(
                    '프로그램 이름을 정해주세요',
                    textScaleFactor: 2.0,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                ),
                Container(
                  child: Text('외부를 터치하면 취소 할 수 있어요',
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ),
                SizedBox(height: 20),
                TextField(
                  onChanged: (value) {
                    _workoutProvider.workoutdata.routinedatas
                        .indexWhere((routine) {
                      if (routine.name == _workoutNameCtrl.text) {
                        state(() {
                          _customRuUsed = true;
                        });
                        return true;
                      } else {
                        state(() {
                          _customRuUsed = false;
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
                SizedBox(height: 20),
                _finalConfirmButton(state)
              ],
            ),
          );
        });
      },
    );
  }

  Widget _finalConfirmButton(state) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor:
                  _workoutNameCtrl.text == "" || _customRuUsed == true
                      ? Color(0xFF212121)
                      : Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (_customRuUsed == false || _workoutNameCtrl.text == "") {
                _famousdataProvider.weekchange(0);
                _workoutProvider.addroutine(new Routinedatas(
                    name: _workoutNameCtrl.text,
                    mode: 3,
                    exercises: widget.program.routinedata.exercises,
                    routine_time: widget.program.routinedata.routine_time));
                _editWorkoutCheck();
                Navigator.of(context).popUntil((route) => route.isFirst);
                ProgramSubscribe(id: widget.program.id).subscribeProgram().then(
                    (data) => data["user_email"] != null
                        ? [showToast("done!"), _famousdataProvider.getdata()]
                        : showToast("입력을 확인해주세요"));
                _workoutNameCtrl.clear();
              }
            },
            child: Text(_customRuUsed == true ? "존재하는 이름" : "이 이름으로 저장",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  Widget _neededlist() {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (BuildContext _context, int index) {
          return Center(
              child: _exerciseWidget(
                  _exProvider
                      .exercisesdata.exercises[ref_exercise_index[index]],
                  index));
        },
        itemCount: ref_exercise_index.length,
        shrinkWrap: true,
      ),
    );
  }

  Widget _exerciseWidget(Exercises, index) {
    _onermController.add(
        new TextEditingController(text: Exercises.onerm.toStringAsFixed(1)));
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 2 / 4,
                child: Center(
                  child: Text(
                    Exercises.name,
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 1 / 4,
                child: Center(
                  child: TextFormField(
                      controller: _onermController[index],
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColorLight),
                      textAlign: TextAlign.center,
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
                          hintText: Exercises.onerm.toStringAsFixed(1),
                          hintStyle: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColorLight)),
                      onChanged: (text) {
                        double changeweight;
                        if (text == "") {
                          changeweight = 0.0;
                        } else {
                          changeweight = double.parse(text);
                        }
                        setState(() {
                          _exProvider
                              .exercisesdata
                              .exercises[ref_exercise_index[index]]
                              .onerm = changeweight;
                        });
                      }),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            height: 1,
            color: Color(0xFF101012),
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 1,
              color: Color(0xFF717171),
            ),
          )
        ],
      ),
    );
  }

  Widget _1rmConfirmButton() {
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
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              List rname = [];
              for (int i = 0;
                  i < _workoutProvider.workoutdata.routinedatas.length;
                  i++) {
                rname.add(_workoutProvider.workoutdata.routinedatas[i].name);
              }
              if (rname.contains(widget.program.routinedata.name)) {
                _customRuUsed = true;
              }
              Navigator.pop(context);
              titleSetting();
            },
            child: Text("1rm 확인",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
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

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _workoutProvider = Provider.of<WorkoutdataProvider>(context, listen: false);
    _exProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
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
          resizeToAvoidBottomInset: false,
          appBar: _appbarWidget(),
          body: _programDownloadWidget(),
          backgroundColor: Color(0xFF101012));
    });
  }
}
