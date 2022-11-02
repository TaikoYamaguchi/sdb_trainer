import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transition/transition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/pages/feed_friend_edit.dart';
import 'package:like_button/like_button.dart';
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
  var _userdataProvider;
  var friendsInputSwitch = false;
  var btnDisabled;

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("친구관리", style: TextStyle(color: Colors.white)),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        Transition(
                            child: FeedFriendEdit(),
                            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  },
                  child: Text("친구찾기", style: TextStyle(color: Colors.white))),
            ],
          ),
          backgroundColor: Color(0xFF101012),
        ));
  }

  Widget _friend_searchWidget() {
    return Container(
        color: Color(0xFF101012),
        child: Column(children: [
          Expanded(
            child:
                Consumer<UserdataProvider>(builder: (builder, provider, child) {
              return provider.userFriends.userdatas.isEmpty
                  ? Container(
                      color: Color(0xFF101012),
                      child: Center(
                        child: Text("친구를 찾고 추가해 보세요",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ))
                  : ListView.separated(
                      itemBuilder: (BuildContext _context, int index) {
                        return _friend_listWidget(
                            provider, provider.userFriends.userdatas[index]);
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
                      itemCount: provider.userFriends.userdatas.length,
                    );
            }),
          )
        ]));
  }

  Widget _friend_listWidget(provider, user) {
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
          _feedLikeButton(provider, user)
        ],
      ),
    ));
  }

  Widget _feedLikeButton(provider, User) {
    var buttonSize = 28.0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LikeButton(
        size: buttonSize,
        isLiked: onIsLikedCheck(provider, User),
        circleColor:
            CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
        bubblesColor: BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return Icon(
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

  bool onIsLikedCheck(provider, User) {
    if (provider.userdata.like.contains(User.email)) {
      return true;
    } else {
      return false;
    }
  }

  bool onLikeButtonTapped(bool isLiked, User) {
    if (isLiked == true) {
      UserLike(
              liked_email: User.email,
              user_email: _userdataProvider.userdata.email,
              status: "remove",
              disorlike: "like")
          .patchUserLike();
      _userdataProvider.patchUserLikedata(User, "remove");
      return false;
    } else {
      UserLike(
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
