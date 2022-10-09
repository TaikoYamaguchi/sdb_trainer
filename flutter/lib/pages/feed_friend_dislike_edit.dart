import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:like_button/like_button.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/workoutdata.dart' as wod;
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/src/model/userdata.dart';

class FeedFriendDislikeEdit extends StatefulWidget {
  FeedFriendDislikeEdit({Key? key}) : super(key: key);

  @override
  _FeedFriendDislikeEditState createState() => _FeedFriendDislikeEditState();
}

class _FeedFriendDislikeEditState extends State<FeedFriendDislikeEdit> {
  var _testdata0;
  late var _testdata = _testdata0;
  var _exercisesdataProvider;
  var _usersdata;
  var _userdataProvider;
  var friendsInputSwitch = false;
  var btnDisabled;

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
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
        "차단 친구 관리",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Color(0xFF101012),
    );
  }

  Widget _dislikeEditWidget() {
    return Container(
        color: Color(0xFF101012),
        child: Column(children: [
          Consumer<UserdataProvider>(builder: (builder, provider, child) {
            return Expanded(
              child: _userdataProvider.userdata.dislike.isEmpty
                  ? Container(
                      color: Color(0xFF101012),
                      child: Center(
                        child: Text("차단 친구가 없네요",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ))
                  : ListView.separated(
                      itemBuilder: (BuildContext _context, int index) {
                        return _dislikeListWidget(
                            _userdataProvider.userdata.dislike[index]);
                      },
                      separatorBuilder: (BuildContext _context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          height: 1,
                          color: Color(0xFF101012),
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            height: 1,
                            color: Color(0xFF717171),
                          ),
                        );
                      },
                      itemCount: _userdataProvider.userdata.dislike.length,
                    ),
            );
          }),
        ]));
  }

  Widget _dislikeListWidget(email) {
    User user = _userdataProvider.userFriendsAll.userdatas
        .where((user) => user.email == email)
        .toList()[0];
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child:
                  Icon(Icons.account_circle, color: Colors.white, size: 28.0),
            ),
            Text(user.nickname,
                style: TextStyle(color: Colors.white, fontSize: 18.0)),
          ]),
          _dislikeEditButton(user)
        ],
      ),
    ));
  }

  Widget _dislikeEditButton(User) {
    var buttonSize = 28.0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LikeButton(
        size: buttonSize,
        isLiked: onIsLikedCheck(User),
        circleColor:
            CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
        bubblesColor: BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return Icon(
            Icons.remove_circle,
            color: isLiked ? Colors.red.shade200 : Colors.grey,
            size: buttonSize,
          );
        },
        onTap: (bool isLiked) async {
          return onLikeButtonTapped(isLiked, User);
        },
      ),
    );
  }

  bool onIsLikedCheck(User) {
    if (_userdataProvider.userdata.dislike.contains(User.email)) {
      return true;
    } else {
      return false;
    }
  }

  bool onLikeButtonTapped(bool isLiked, User) {
    if (isLiked == true) {
      var user = UserLike(
              liked_email: User.email,
              user_email: _userdataProvider.userdata.email,
              status: "remove",
              disorlike: "dislike")
          .patchUserLike();
      _userdataProvider.patchUserDislikedata(User.email, "remove");
      return false;
    } else {
      var user = UserLike(
              liked_email: User.email,
              user_email: _userdataProvider.userdata.email,
              status: "append",
              disorlike: "dislike")
          .patchUserLike();
      _userdataProvider.patchUserDislikedata(User.email, "append");
      return !isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    _testdata0 = _exercisesdataProvider.exercisesdata.exercises;
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    if (friendsInputSwitch == false) {
      _usersdata = _userdataProvider.userFriendsAll;
    }

    return WillPopScope(
      child: Scaffold(
        appBar: _appbarWidget(),
        body: _dislikeEditWidget(),
      ),
      onWillPop: () async {
        return true;
      },
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
