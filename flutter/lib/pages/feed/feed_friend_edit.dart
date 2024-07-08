import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/pages/feed/friendProfile.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/feed/feed_friend_dislike_edit.dart';

class FeedFriendEdit extends StatefulWidget {
  FeedFriendEdit({Key? key}) : super(key: key);

  @override
  _FeedFriendEditState createState() => _FeedFriendEditState();
}

class _FeedFriendEditState extends State<FeedFriendEdit> {
  var _usersdata;
  var _userProvider;
  var friendsInputSwitch = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    if (friendsInputSwitch == false) {
      _usersdata = _userProvider.userFriendsAll;
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

  PreferredSizeWidget _appbarWidget() {
    bool btnDisabled = false;
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
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
              Text("친구 찾기",
                  style: TextStyle(color: Theme.of(context).primaryColorLight)),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        Transition(
                            child: const FeedFriendDislikeEdit(),
                            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  },
                  child: Text("차단친구",
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight))),
            ],
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _friend_searchWidget() {
    bool btnDisabled = false;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onPanUpdate: (details) {
        if (details.delta.dx > 10 && btnDisabled == false) {
          btnDisabled = true;
          Navigator.of(context).pop();
          print("Dragging in +X direction");
        }
      },
      child: Container(
          child: Column(children: [
        Consumer<UserdataProvider>(builder: (builder, provider, child) {
          return Container(
            margin: const EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: TextField(
                autofocus: true,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF717171),
                  ),
                  hintText: "닉네임 검색",
                  hintStyle:
                      const TextStyle(fontSize: 20.0, color: Color(0xFF717171)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 1, color: Theme.of(context).primaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 1.5),
                  ),
                ),
                onChanged: (text) {
                  if (text.toString() == "") {
                    friendsInputSwitch = false;
                    setState(() => _usersdata = _userProvider.userFriendsAll);
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
                      height: 0.5,
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: 0.5,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    );
                  },
                  itemCount: _usersdata.userdatas.length,
                ),
        )
      ])),
    );
  }

  void searchFriend(String query) async {
    final suggestions =
        await UserNicknameAll(userNickname: query).getUsersByNickname();

    setState(() => _usersdata = suggestions);
  }

  Widget _friend_listWidget(user) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    Transition(
                        child: FriendProfile(user: user),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
              },
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: user.image == ""
                      ? const Icon(
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(50)),
                                image: DecorationImage(
                                  image: imageProivder,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),
                ),
                Text(user.nickname,
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ])),
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
            const CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
        bubblesColor: const BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return User.email == _userProvider.userdata.email
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
    if (_userProvider.userdata.like.contains(User.email)) {
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
