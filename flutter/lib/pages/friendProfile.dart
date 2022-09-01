import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class FriendProfile extends StatefulWidget {
  User user;
  FriendProfile({Key? key, required this.user}) : super(key: key);

  @override
  _FriendProfileState createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  var _userdataProvider;
  var btnDisabled;
  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
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
        widget.user.nickname,
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _userProfileWidget() {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          GestureDetector(
              onTap: () {},
              child: widget.user.image == ""
                  ? Icon(
                      Icons.account_circle,
                      color: Colors.grey,
                      size: 160.0,
                    )
                  : CircleAvatar(
                      radius: 80.0,
                      backgroundImage: NetworkImage(widget.user.image),
                      backgroundColor: Colors.transparent)),
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
          })
        ]),
      ),
    );
  }

  Widget _feedLikeButton(provider, User) {
    bool isLiked = onIsLikedCheck(provider, User);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: FlatButton(
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
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    print("this is profileeeeeeeeee");
    return Scaffold(
        appBar: _appbarWidget(),
        body: _userProfileWidget(),
        backgroundColor: Colors.black);
  }
}
