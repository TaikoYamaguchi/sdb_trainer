import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/src/model/historydata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/static_exercise.dart';

class FriendHistory extends StatefulWidget {
  SDBdata sdbdata;
  FriendHistory({Key? key, required this.sdbdata}) : super(key: key);

  @override
  _FriendHistoryState createState() => _FriendHistoryState();
}

class _FriendHistoryState extends State<FriendHistory> {
  var _userProvider;
  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    bool btnDisabled = false;
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
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
            textScaleFactor: 2.7,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF101012),
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
      child: SingleChildScrollView(
          child: Container(
              width: MediaQuery.of(context).size.width,
              color: Color(0xFF101012),
              child: Consumer<HistorydataProvider>(
                  builder: (builder, provider, child) {
                var exercises = provider
                    .historydataAll
                    .sdbdatas[
                        provider.historydataAll.sdbdatas.indexWhere((sdbdata) {
                  if (sdbdata.id == widget.sdbdata.id) {
                    return true;
                  } else {
                    return false;
                  }
                })]
                    .exercises;
                return _onechartExercisesWidget(exercises);
              }))),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Color(0xFF101012),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(exuniq[index].name,
                      textScaleFactor: 1.3,
                      style: TextStyle(color: Colors.white)),
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
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
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
                              style: TextStyle(color: Color(0xFF717171))),
                        ],
                      ),
                    )
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
                                    color: Colors.white,
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
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            width: 35,
                            child: SvgPicture.asset("assets/svg/multiply.svg",
                                color: Colors.white, height: 19)),
                        Container(
                          width: 40,
                          child: Text(
                            sets[index].reps.toString(),
                            textScaleFactor: 1.7,
                            style: TextStyle(
                              color: Colors.white,
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
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    "${sets[index].weight}",
                                    textScaleFactor: 1.7,
                                    style: TextStyle(color: Colors.white),
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
                    color: Color(0xFF101012),
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
    return Scaffold(
        appBar: _appbarWidget(),
        body: _friendHistoryWidget(),
        backgroundColor: Color(0xFF101012));
  }
}
