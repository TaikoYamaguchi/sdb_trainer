import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';

import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';

import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';

class Feed extends StatelessWidget {
  Feed({Key? key}) : super(key: key);

  var _historydata;

  @override
  Widget build(BuildContext context) {
    _historydata = Provider.of<HistorydataProvider>(context, listen: false);
    _historydata.getdata();
    print("111111");
    print(_historydata.historydata.sdbdatas[0].exercises[0]);
    return Scaffold(
        appBar: AppBar(
            title: Text("피드", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black),
        body: _feedCardList(context));
  }

  Widget _feedCardList(context) {
    return ListView.separated(
        itemBuilder: (BuildContext _context, int index) {
          return Center(
              child: _feedCard(_historydata.historydata.sdbdatas[index]));
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
        itemCount: _historydata.historydata.sdbdatas.length);
  }

  Widget _feedCard(SDBdata) {
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
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Row(
                      children: [
                        Text(
                          SDBdata.user_email,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    )),
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
                )
              ],
            ),
          ),
        ),
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
