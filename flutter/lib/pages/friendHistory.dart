import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/historydata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/static_exercise.dart';
import 'package:sdb_trainer/providers/themeMode.dart';

class FriendHistory extends StatefulWidget {
  SDBdata sdbdata;
  FriendHistory({Key? key, required this.sdbdata}) : super(key: key);

  @override
  _FriendHistoryState createState() => _FriendHistoryState();
}

class _FriendHistoryState extends State<FriendHistory>
    with TickerProviderStateMixin {
  var _userProvider;
  var _themeProvider;
  late FlutterGifController controller1;
  @override
  void initState() {
    super.initState();
    controller1 = FlutterGifController(vsync: this);
  }

  PreferredSizeWidget _appbarWidget() {
    bool btnDisabled = false;
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              btnDisabled == true
                  ? null
                  : [
                      btnDisabled = true,
                      Navigator.of(context).pop(),
                    ];
            },
          ),
          title: Text(
            widget.sdbdata.nickname!,
            textScaleFactor: 2.0,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _friendHistoryWidget() {
    bool btnDisabled = false;
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 0 && btnDisabled == false) {
          btnDisabled = true;
          Navigator.of(context).pop();
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Consumer<HistorydataProvider>(
                    builder: (builder, provider, child) {
                  var exercises = provider
                      .historydataAll
                      .sdbdatas[provider.historydataAll.sdbdatas
                          .indexWhere((sdbdata) {
                    if (sdbdata.id == widget.sdbdata.id) {
                      return true;
                    } else {
                      return false;
                    }
                  })]
                      .exercises;
                  return _onechartExercisesWidget(exercises);
                }))),
      ),
    );
  }

  Widget _onechartExercisesWidget(exercises) {
    print(widget.sdbdata.id);
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext _context, int index) {
          return _onechartExerciseWidget(exercises, widget.sdbdata.id,
              _userProvider.userdata, true, index);
        },
        separatorBuilder: (BuildContext _context, int index) {
          return Container(
            alignment: Alignment.center,
            height: 0,
            color: Color(0xFF212121),
            child: Container(
              alignment: Alignment.center,
              height: 0,
              color: Color(0xFF717171),
            ),
          );
        },
        shrinkWrap: true,
        itemCount: exercises.length,
        scrollDirection: Axis.vertical);
  }

  Widget _onechartExerciseWidget(
      exuniq, history_id, userdata, bool shirink, index) {
    double top = 0;
    double bottom = 0;
    var _exImage;
    try {
      _exImage = extra_completely_new_Ex[extra_completely_new_Ex
              .indexWhere((element) => element.name == exuniq[index].name)]
          .image;
      if (_exImage == null) {
        _exImage = "";
      }
    } catch (e) {
      _exImage = "";
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _exImage != ""
                          ? Image.asset(
                              _exImage,
                              height: 48,
                              width: 48,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 48,
                              width: 48,
                              child: Icon(Icons.image_not_supported,
                                  color: Theme.of(context).primaryColorDark),
                              decoration: BoxDecoration(shape: BoxShape.circle),
                            ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(exuniq[index].name,
                            textScaleFactor: 1.4,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                      ),
                    ],
                  ),
                ),
                widget.sdbdata.user_email == userdata.email
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              Transition(
                                  child: StaticsExerciseDetails(
                                      exercise: exuniq[index],
                                      index: index,
                                      origin_exercises: exuniq,
                                      history_id: history_id),
                                  transitionEffect:
                                      TransitionEffect.RIGHT_TO_LEFT));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.settings,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ))
                    : Container()
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                        topLeft: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _chartExerciseSetsWidget(exuniq[index].sets),
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
                                  exuniq[index].onerm.toStringAsFixed(1) +
                                  "/${exuniq[index].goal.toStringAsFixed(1)}${userdata.weight_unit}",
                              textScaleFactor: 1.0,
                              style: TextStyle(color: Color(0xFF717171)))
                        ],
                      ),
                    ),
                    SizedBox(height: 4.0)
                  ],
                ),
              ),
            )
          ],
        ),
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
                            textScaleFactor: 1.0,
                            style: TextStyle(
                              color: Colors.grey,
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
                        textScaleFactor: 1.0,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Container(width: 35),
                  Container(
                      width: 40,
                      child: Text(
                        "Reps",
                        textScaleFactor: 1.0,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  Container(
                      width: 70,
                      child: Text(
                        "1RM",
                        textScaleFactor: 1.0,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ],
              )),
          SizedBox(
            child: ListView.separated(
                itemBuilder: (BuildContext _context, int index) {
                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                height:
                                    19 * _themeProvider.userFontSize / 0.8)),
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
                    height: 0,
                    child: Container(
                      alignment: Alignment.center,
                      height: 0,
                      color: Color(0xFF717171),
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
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: _appbarWidget(),
      body: _friendHistoryWidget(),
    );
  }
}
