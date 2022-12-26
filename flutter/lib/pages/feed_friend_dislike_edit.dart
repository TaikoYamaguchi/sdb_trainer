import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/userdata.dart';

class FeedFriendDislikeEdit extends StatefulWidget {
  FeedFriendDislikeEdit({Key? key}) : super(key: key);

  @override
  _FeedFriendDislikeEditState createState() => _FeedFriendDislikeEditState();
}

class _FeedFriendDislikeEditState extends State<FeedFriendDislikeEdit> {
  var _userProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);

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

  PreferredSizeWidget _appbarWidget() {
    bool btnDisabled = false;
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
          title: Text(
            "차단 친구 관리",
            textScaleFactor: 2.7,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
        ));
  }

  Widget _dislikeEditWidget() {
    bool btnDisabled = false;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onPanUpdate: (details) {
          if (details.delta.dx > 0 && btnDisabled == false) {
            btnDisabled = true;
            Navigator.of(context).pop();
            print("Dragging in +X direction");
          }
        },
        child: Container(
            child: Column(children: [
          Consumer<UserdataProvider>(builder: (builder, provider, child) {
            return Expanded(
              child: _userProvider.userdata.dislike.isEmpty
                  ? Container(
                      child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("차단 친구가 없어요",
                              textScaleFactor: 2.0,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Text("차단 친구는 여기서 관리 해요",
                              textScaleFactor: 1.3,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ))
                        ],
                      ),
                    ))
                  : ListView.separated(
                      itemBuilder: (BuildContext _context, int index) {
                        return _dislikeListWidget(
                            _userProvider.userdata.dislike[index]);
                      },
                      separatorBuilder: (BuildContext _context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          height: 1,
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            height: 1,
                            color: Color(0xFF717171),
                          ),
                        );
                      },
                      itemCount: _userProvider.userdata.dislike.length,
                    ),
            );
          }),
        ])));
  }

  Widget _dislikeListWidget(email) {
    User user = _userProvider.userFriendsAll.userdatas
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
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).primaryColorLight)),
          ]),
          _dislikeEditButton(user)
        ],
      ),
    ));
  }

  Widget _dislikeEditButton(User user) {
    var buttonSize = 28.0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LikeButton(
        size: buttonSize,
        isLiked: onIsLikedCheck(user),
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
          return onLikeButtonTapped(isLiked, user);
        },
      ),
    );
  }

  bool onIsLikedCheck(User user) {
    if (_userProvider.userdata.dislike.contains(user.email)) {
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
              disorlike: "dislike")
          .patchUserLike();
      _userProvider.patchUserDislikedata(User.email, "remove");
      return false;
    } else {
      UserLike(
              liked_email: User.email,
              user_email: _userProvider.userdata.email,
              status: "append",
              disorlike: "dislike")
          .patchUserLike();
      _userProvider.patchUserDislikedata(User.email, "append");
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
