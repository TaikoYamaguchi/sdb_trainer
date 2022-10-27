import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/feed_friend_dislike_edit.dart';

class FeedFriendEdit extends StatefulWidget {
  FeedFriendEdit({Key? key}) : super(key: key);

  @override
  _FeedFriendEditState createState() => _FeedFriendEditState();
}

class _FeedFriendEditState extends State<FeedFriendEdit> {
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("친구 찾기", style: TextStyle(color: Colors.white)),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    Transition(
                        child: FeedFriendDislikeEdit(),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
              },
              child: Text("차단친구", style: TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: Color(0xFF101012),
    );
  }

  Widget _friend_searchWidget() {
    return Container(
        color: Color(0xFF101012),
        child: Column(children: [
          Consumer<UserdataProvider>(builder: (builder, provider, child) {
            return Container(
              margin: const EdgeInsets.fromLTRB(10, 16, 10, 16),
              child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF717171),
                    ),
                    hintText: "닉네임 검색",
                    hintStyle:
                        TextStyle(fontSize: 20.0, color: Color(0xFF717171)),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 3, color: Color(0xFF717171)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onChanged: (text) {
                    if (text.toString() == "") {
                      friendsInputSwitch = false;
                      setState(
                          () => _usersdata = _userdataProvider.userFriendsAll);
                    } else {
                      searchFriend(text.toString());
                      friendsInputSwitch = true;
                    }
                  }),
            );
          }),
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
                        color: Color(0xFF101012),
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

    setState(() => _usersdata = suggestions);
  }

  Widget _friend_listWidget(user) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: user.image == ""
                  ? Icon(
                      Icons.account_circle,
                      color: Colors.grey,
                      size: 28.0,
                    )
                  : CachedNetworkImage(
                      imageUrl: user.image,
                      imageBuilder: (context, imageProivder) => Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            image: DecorationImage(
                              image: imageProivder,
                              fit: BoxFit.cover,
                            )),
                      ),
                    ),
            ),
            Text(user.nickname,
                style: TextStyle(color: Colors.white, fontSize: 18.0)),
          ]),
          _feedLikeButton(user)
        ],
      ),
    ));
  }

  Widget _feedLikeButton(User) {
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
          return User.email == _userdataProvider.userdata.email
              ? Container()
              : Icon(
                  Icons.favorite,
                  color: isLiked ? Theme.of(context).primaryColor : Colors.grey,
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
    if (_userdataProvider.userdata.like.contains(User.email)) {
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
              disorlike: "like")
          .patchUserLike();
      _userdataProvider.patchUserLikedata(User, "remove");
      return false;
    } else {
      var user = UserLike(
              liked_email: User.email,
              user_email: _userdataProvider.userdata.email,
              status: "append",
              disorlike: "like")
          .patchUserLike();
      _userdataProvider.patchUserLikedata(User, "append");
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
        body: _friend_searchWidget(),
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
