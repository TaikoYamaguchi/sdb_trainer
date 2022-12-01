import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/pages/feedCard.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileNickname.dart';
import 'package:sdb_trainer/pages/userProfileBody.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_button/like_button.dart';
import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/repository/history_repository.dart';

class FriendProfile extends StatefulWidget {
  User user;
  FriendProfile({Key? key, required this.user}) : super(key: key);

  @override
  _FriendProfileState createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  var _userProvider;
  var _hisProvider;
  var _btnDisabled;
  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    _btnDisabled = false;
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              _btnDisabled == true
                  ? null
                  : [
                      _btnDisabled = true,
                      Navigator.of(context).pop(),
                    ];
            },
          ),
          title: Text(
            widget.user.nickname,
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          backgroundColor: Color(0xFF101012),
        ));
  }

  Widget _userProfileWidget() {
    _hisProvider.getUserEmailHistorydata(widget.user.email);
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Color(0xFF101012),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                  onTap: () {},
                  child: widget.user.image == ""
                      ? Icon(
                          Icons.account_circle,
                          color: Colors.grey,
                          size: 160.0,
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.user.image,
                          imageBuilder: (context, imageProivder) => Container(
                            height: 160.0,
                            width: 160.0,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                image: DecorationImage(
                                  image: imageProivder,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        )),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.user.liked.length.toString(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 24,
                          ),
                        ),
                        Text("팔로워",
                            style: TextStyle(color: Colors.white, fontSize: 16))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.user.like.length.toString(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 24,
                          ),
                        ),
                        Text("팔로잉",
                            style: TextStyle(color: Colors.white, fontSize: 16))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.user.history_cnt.toString(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 24,
                          ),
                        ),
                        Text("운동기록",
                            style: TextStyle(color: Colors.white, fontSize: 16))
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 32),
              Consumer<UserdataProvider>(builder: (builder, provider, child) {
                return _feedLikeButton(provider, widget.user);
              }),
              _feedCardList(context),
            ]),
      ),
    );
  }

  Widget _feedLikeButton(provider, User) {
    bool isLiked = onIsLikedCheck(provider, User);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: TextButton(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 40.0,
          decoration: BoxDecoration(
              color: isLiked ? Colors.deepPurpleAccent : Colors.grey,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  provider.userdata.email == User.email
                      ? "본 계정입니다"
                      : isLiked
                          ? "팔로잉 중 "
                          : "팔로우 하기 ",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
        onPressed: () {
          if (provider.userdata.email != User.email) {
            onLikeButtonTapped(isLiked, User);
          }
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
              user_email: _userProvider.userdata.email,
              status: "remove",
              disorlike: "like")
          .patchUserLike();
      _userProvider.patchUserLikedata(User, "remove");
      return false;
    } else {
      UserLike(
              liked_email: User.email,
              user_email: _userProvider.userdata.email,
              status: "append",
              disorlike: "like")
          .patchUserLike();
      _userProvider.patchUserLikedata(User, "append");
      return !isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    return Scaffold(
        appBar: _appbarWidget(),
        body: _userProfileWidget(),
        backgroundColor: Color(0xFF101012));
  }
}

Widget _feedCardList(context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Consumer<HistorydataProvider>(builder: (builder, provider, child) {
        try {
          return provider.historydataUserEmail.sdbdatas.isEmpty != true
              ? ListView.separated(
                  itemBuilder: (BuildContext _context, int index) {
                    if (index < provider.historydataUserEmail.sdbdatas.length) {
                      return Center(
                          child: FeedCard(
                              sdbdata:
                                  provider.historydataUserEmail.sdbdatas[index],
                              index: index,
                              feedListCtrl: 0));
                    } else {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                            child: Text("데이터 없음",
                                style: TextStyle(color: Colors.white))),
                      );
                    }
                  },
                  physics: NeverScrollableScrollPhysics(),
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
                  shrinkWrap: true,
                  itemCount: provider.historydataUserEmail.sdbdatas.length + 1)
              : CircularProgressIndicator();
        } catch (e) {
          return CircularProgressIndicator();
        }
      }),
    ],
  );
}
