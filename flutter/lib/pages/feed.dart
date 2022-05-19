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
    _historydata = Provider.of<HistorydataProvider>(context);
    _historydata.getdata();
    print("111111");
    print(_historydata.historydata.sdbdatas[0].user_email);
    return Scaffold(
        appBar: AppBar(
            title: Text("피드", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black),
        body: Container(child: _feedCard(context)));
  }

  Widget _feedCard(context) {
    return Card(
        child: Column(children: [
      Text(_historydata.historydata.sdbdatas[0].user_email),
      Text(_historydata.historydata.sdbdatas[0].exercises[0].date),
      Text(_historydata.historydata.sdbdatas[0].exercises[0].name),
      Text(_historydata.historydata.sdbdatas[0].exercises[1].name),
    ]));
  }
}
