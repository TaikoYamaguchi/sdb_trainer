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
  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text(
        widget.user.nickname,
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _userProfileWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        GestureDetector(
            onTap: () {},
            child: widget.user.image == ""
                ? Icon(
                    Icons.account_circle,
                    color: Colors.grey,
                    size: 200.0,
                  )
                : CircleAvatar(
                    radius: 100.0,
                    backgroundImage: NetworkImage(widget.user.image),
                    backgroundColor: Colors.transparent)),
        Consumer<UserdataProvider>(builder: (builder, provider, child) {
          return _feedLikeButton(provider, widget.user);
        })
      ]),
    );
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
            color: isLiked ? Colors.deepPurpleAccent : Colors.grey,
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
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    print("this is profileeeeeeeeee");
    return Scaffold(
        appBar: _appbarWidget(),
        body: _userProfileWidget(),
        backgroundColor: Colors.black);
  }
}
