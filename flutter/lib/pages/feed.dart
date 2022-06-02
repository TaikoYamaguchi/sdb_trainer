import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';

import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';

import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class Feed extends StatefulWidget {
  Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  var _feedListCtrl = 1;

  final Map<int, Widget> _feedList = const <int, Widget>{
    1: Padding(
      child: Text("모두 보기", style: TextStyle(color: Colors.white, fontSize: 14)),
      padding: const EdgeInsets.all(10.0),
    ),
    2: Padding(
        child:
            Text("친구 보기", style: TextStyle(color: Colors.white, fontSize: 14)),
        padding: const EdgeInsets.all(10.0)),
    3: Padding(
        child:
            Text("나만 보기", style: TextStyle(color: Colors.white, fontSize: 14)),
        padding: const EdgeInsets.all(10.0))
  };

  var _historydataAll;

  @override
  Widget build(BuildContext context) {
    _historydataAll = Provider.of<HistorydataProvider>(context, listen: false);
    _historydataAll.getHistorydataAll();
    print("111111");
    print(_historydataAll.historydataAll.sdbdatas[0].exercises[0]);
    return Scaffold(
        appBar: AppBar(
            title: Text("피드", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black),
        body: _feedCardList(context));
  }

  Widget _feedCardList(context) {
    return Column(
      children: [
        _feedControllerWidget(),
        Expanded(
          child: ListView.separated(
              itemBuilder: (BuildContext _context, int index) {
                return Center(
                    child: _feedCard(
                        _historydataAll.historydataAll.sdbdatas[index]));
              },
              separatorBuilder: (BuildContext _context, int index) {
                return Container(
                  alignment: Alignment.center,
                  height: 1,
                  color: Colors.black,
                  child: Container(
                    alignment: Alignment.center,
                    height: 1,
                    color: Color(0xFF717171),
                  ),
                );
              },
              itemCount: _historydataAll.historydataAll.sdbdatas.length),
        ),
      ],
    );
  }

  Widget _feedCard(SDBdata) {
    var user;
    return Container(
      height: 200,
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            color: Color(0xFF717171),
            child: Column(
              children: [
                FutureBuilder(
                    future: UserInfo(userEmail: SDBdata.user_email)
                        .getUserByEmail()
                        .then((data) => {user = data}),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData == false) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Row(
                              children: [
                                Text(
                                  SDBdata.user_email,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ],
                            ));
                      } else {
                        return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user.nickname,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                                Text(SDBdata.date.substring(2, 10),
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white))
                              ],
                            ));
                      }
                    }),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: 120,
                          child: Text(
                            "운동",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          )),
                      Container(
                          width: 70,
                          child: Text("sets",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center)),
                      Container(
                          width: 80,
                          child: Text("1rm",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center))
                    ],
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: ListView.separated(
                      itemBuilder: (BuildContext _context, int index) {
                        return Center(
                            child: _exerciseWidget(
                                SDBdata.exercises[index], index));
                      },
                      separatorBuilder: (BuildContext _context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          height: 1,
                          color: Colors.black,
                          child: Container(
                            alignment: Alignment.center,
                            height: 1,
                            color: Color(0xFF717171),
                          ),
                        );
                      },
                      itemCount: SDBdata.exercises.length),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: null, icon: Icon(Icons.thumb_up)),
                    IconButton(onPressed: null, icon: Icon(Icons.thumb_down))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        color: Colors.black,
        child: CupertinoSlidingSegmentedControl(
            groupValue: _feedListCtrl,
            children: _feedList,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            backgroundColor: Colors.black,
            thumbColor: Color.fromRGBO(25, 106, 223, 20),
            onValueChanged: (i) {
              setState(() {
                _feedListCtrl = i as int;
                print(_feedListCtrl);
              });
            }),
      ),
    );
  }

  Widget _exerciseWidget(Exercises, index) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 120,
              child: Text(
                Exercises.name,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            Container(
              width: 70,
              child: Text(
                Exercises.sets.length.toString(),
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 80,
              child: Text(
                Exercises.onerm.toString(),
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
