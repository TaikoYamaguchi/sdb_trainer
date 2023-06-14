import 'package:flutter/material.dart';
import 'package:sdb_trainer/src/utils/feedCard.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'dart:io';

GlobalKey<FeedCardState> globalKey = GlobalKey();

// ignore: must_be_immutable
class ExerciseDone extends StatefulWidget {
  List<hisdata.Exercises> exerciseList = [];
  final int routinetime;
  final hisdata.SDBdata sdbdata;
  ExerciseDone(
      {Key? key,
      required this.exerciseList,
      required this.routinetime,
      required this.sdbdata})
      : super(key: key);

  @override
  _ExerciseDoneState createState() => _ExerciseDoneState();
}

class _ExerciseDoneState extends State<ExerciseDone> {
  var _btnDisabled;
  final TextEditingController _exerciseCommentCtrl =
      TextEditingController(text: "");
  File? _image;
  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    _btnDisabled = false;
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              _btnDisabled == true
                  ? null
                  : [
                      _btnDisabled = true,
                      Navigator.of(context).popUntil((route) => route.isFirst)
                    ];
            },
          ),
          title: Text(
            "운동 기록",
            textScaleFactor: 1.7,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          backgroundColor: Theme.of(context).canvasColor,
          actions: [
            _image == null
                ? Container()
                : IconButton(
                    icon: const Icon(Icons.share_rounded),
                    color: Theme.of(context).primaryColorLight,
                    onPressed: () {
                      Share.shareFiles([_image!.path],
                          text: _exerciseCommentCtrl.text);
                    },
                  ),
          ],
        ));
  }

  Widget _exerciseDoneWidget() {
    var time_hour = 0;
    var time_min = 0;
    var time_sec = 0;
    if (widget.routinetime ~/ 3600 > 0) {
      time_hour = widget.routinetime ~/ 3600;
    } else if (widget.routinetime ~/ 60 > 0) {
      time_min = widget.routinetime ~/ 60;
    } else if (widget.routinetime > 0) {
      time_sec = widget.routinetime % 60;
    }
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Center(
                                child: Icon(Icons.fitness_center,
                                    color: Theme.of(context).primaryColorLight,
                                    size: 40)),
                          ),
                          SizedBox(
                            width: 120,
                            child: Center(
                                child: Icon(Icons.access_time,
                                    color: Theme.of(context).primaryColorLight,
                                    size: 40)),
                          ),
                          SizedBox(
                              width: 60,
                              child: Center(
                                  child: Icon(Icons.celebration,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      size: 40))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 60,
                              child: Center(
                                child: Text("운동 갯수",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                              )),
                          SizedBox(
                              width: 120,
                              child: Center(
                                child: Text("운동 시간",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                              )),
                          SizedBox(
                              width: 60,
                              child: Center(
                                child: Text("신기록",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Center(
                              child: Text(widget.exerciseList.length.toString(),
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight)),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Center(
                              child: Text(
                                  "${time_hour}시 ${time_min}분 ${time_sec}초",
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight)),
                            ),
                          ),
                          SizedBox(
                              width: 60,
                              child: Center(
                                  child: Text(
                                      widget.sdbdata.new_record.toString(),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FeedCard(
                sdbdata: widget.sdbdata,
                index: 0,
                feedListCtrl: 0,
                openUserDetail: true,
                isExEdit: true,
                ad: false,
                key: globalKey),
            const SizedBox(height: 8.0),
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appbarWidget(),
      body: _exerciseDoneWidget(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).highlightColor,
        onPressed: () {
          globalKey.currentState!.submitExChange();
          // Respond to button press
        },
        label: const Text("운동 제출 하기", textScaleFactor: 1.5),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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
