import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/providers/exercisesdata.dart';

class FeedFriend extends StatefulWidget {
  FeedFriend({Key? key}) : super(key: key);

  @override
  _FeedFriendState createState() => _FeedFriendState();
}

class _FeedFriendState extends State<FeedFriend> {
  var _testdata0;
  late var _testdata = _testdata0;
  var _exercisesdataProvider;
  var _usersdata;

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _friend_searchWidget() {
    return Container(
        color: Colors.black,
        child: Column(children: [
          Container(
            margin: const EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF717171),
                  ),
                  hintText: "친구 검색",
                  hintStyle:
                      TextStyle(fontSize: 20.0, color: Color(0xFF717171)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Color(0xFF717171)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onChanged: (text) {
                  searchFriend(text.toString());
                }),
          ),
          Expanded(
            child: _usersdata == null
                ? Container()
                : ListView.separated(
                    itemBuilder: (BuildContext _context, int index) {
                      return _friend_listWidget(_usersdata.userdatas[index]);
                    },
                    separatorBuilder: (BuildContext _context, int index) {
                      return Container(
                        alignment: Alignment.center,
                        height: 1,
                        color: Colors.black,
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 1,
                          color: Color(0xFF717171),
                        ),
                      );
                    },
                    itemCount: _usersdata.userdatas.length,
                  ),
          )
        ]));
  }

  void searchFriend(String query) async {
    final suggestions =
        await UserNicknameAll(userNickname: query).getUsersByNickname();
    print(suggestions);

    setState(() => _usersdata = suggestions);
  }

  Widget _friend_listWidget(user) {
    return Container(
        child: Text(user.nickname, style: TextStyle(color: Colors.white)));
  }

  @override
  Widget build(BuildContext context) {
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _testdata0 = _exercisesdataProvider.exercisesdata.exercises;
    return Scaffold(
      appBar: _appbarWidget(),
      body: _friend_searchWidget(),
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
