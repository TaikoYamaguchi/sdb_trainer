import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/friendProfile.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/comment_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:sdb_trainer/pages/feed_friend.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:like_button/like_button.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';

class FeedCard extends StatefulWidget {
  hisdata.SDBdata sdbdata;
  int index;
  int feedListCtrl;
  FeedCard(
      {Key? key,
      required this.sdbdata,
      required this.index,
      required this.feedListCtrl})
      : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  var _historyCommentCtrl;
  var _userdataProvider;
  var _historyProvider;
  var _commentListbyId;
  var _tapPosition;
  TextEditingController _commentInputCtrl = TextEditingController(text: "");
  late var _commentInfo = {
    "feedList": widget.feedListCtrl,
    "feedVisible": false
  };
  @override
  void initState() {
    _tapPosition = Offset(0.0, 0.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _feedCard(widget.sdbdata, widget.index);
  }

  Widget _feedCard(SDBdata, index) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _historyProvider = Provider.of<HistorydataProvider>(context, listen: false);
    User user = _userdataProvider.userFriendsAll.userdatas
        .where((user) => user.email == SDBdata.user_email)
        .toList()[0];
    print(user.nickname);
    if (_historyProvider.commentAll != null) {
      _commentListbyId = _historyProvider.commentAll.comments
          .where((comment) => comment.history_id == SDBdata.id)
          .toList();
    } else {
      _commentListbyId = [];
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer2<HistorydataProvider, UserdataProvider>(
              builder: (builder, provider, provider2, child) {
            return _userdataProvider.userdata.dislike.contains(user.email)
                ? Container(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text("차단된 사용자 입니다",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0))))
                : Card(
                    color: Color(0xFF717171),
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        Transition(
                                            child: FriendProfile(user: user),
                                            transitionEffect: TransitionEffect
                                                .RIGHT_TO_LEFT));
                                  },
                                  child: Row(
                                    children: [
                                      user.image == ""
                                          ? Icon(
                                              Icons.account_circle,
                                              color: Colors.grey,
                                              size: 38.0,
                                            )
                                          : CircleAvatar(
                                              radius: 18.0,
                                              backgroundImage:
                                                  NetworkImage(user.image),
                                              backgroundColor:
                                                  Colors.transparent),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          SDBdata.nickname,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Text(SDBdata.date.substring(2, 10),
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey)),
                                    ),
                                    GestureDetector(
                                        onTapDown: _storePosition,
                                        onTap: () {
                                          SDBdata.user_email ==
                                                  _userdataProvider
                                                      .userdata.email
                                              ? showMenu(
                                                  context: context,
                                                  position:
                                                      RelativeRect.fromRect(
                                                          _tapPosition &
                                                              Size(30, 30),
                                                          Offset.zero &
                                                              Size(0, 0)),
                                                  items: [
                                                    PopupMenuItem(
                                                        child: ListTile(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        4.0,
                                                                    vertical:
                                                                        0.0),
                                                            leading: Icon(Icons
                                                                .mode_edit),
                                                            title: Text("코멘트")),
                                                        onTap: () {
                                                          _historyCommentCtrl =
                                                              TextEditingController(
                                                                  text: SDBdata
                                                                      .comment);
                                                          Future<void>.delayed(
                                                              const Duration(), // OR const Duration(milliseconds: 500),
                                                              () =>
                                                                  _displayTextInputDialog(
                                                                      context,
                                                                      SDBdata));
                                                        }),
                                                    PopupMenuItem(
                                                        child: ListTile(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        4.0,
                                                                    vertical:
                                                                        0.0),
                                                            leading: SDBdata
                                                                    .isVisible
                                                                ? Icon(Icons
                                                                    .filter_list_off)
                                                                : Icon(Icons
                                                                    .filter_list),
                                                            title: SDBdata
                                                                    .isVisible
                                                                ? Text("숨김")
                                                                : Text("보임")),
                                                        onTap: () {
                                                          if (SDBdata
                                                              .isVisible) {
                                                            _historyProvider
                                                                .patchHistoryVisible(
                                                                    SDBdata,
                                                                    false);
                                                            HistoryVisibleEdit(
                                                                    history_id:
                                                                        SDBdata
                                                                            .id,
                                                                    status:
                                                                        "false")
                                                                .patchHistoryVisible();
                                                          } else {
                                                            _historyProvider
                                                                .patchHistoryVisible(
                                                                    SDBdata,
                                                                    true);
                                                            HistoryVisibleEdit(
                                                                    history_id:
                                                                        SDBdata
                                                                            .id,
                                                                    status:
                                                                        "true")
                                                                .patchHistoryVisible();
                                                          }
                                                        }),
                                                  ],
                                                )
                                              : showMenu(
                                                  context: context,
                                                  position:
                                                      RelativeRect.fromRect(
                                                          _tapPosition &
                                                              Size(30, 30),
                                                          Offset.zero &
                                                              Size(0, 0)),
                                                  items: [
                                                    PopupMenuItem(
                                                        child: ListTile(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        4.0,
                                                                    vertical:
                                                                        0.0),
                                                            leading: Icon(Icons
                                                                .remove_circle_outlined),
                                                            title: Text("신고")),
                                                        onTap: () {
                                                          _historyCommentCtrl =
                                                              TextEditingController(
                                                                  text: SDBdata
                                                                      .comment);
                                                          Future<void>.delayed(
                                                              const Duration(), // OR const Duration(milliseconds: 500),
                                                              () => _displayDislikeAlert(
                                                                  SDBdata
                                                                      .user_email));
                                                        }),
                                                  ],
                                                );
                                        },
                                        child: Icon(Icons.more_vert,
                                            color: Colors.grey, size: 18.0))
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  width: 120,
                                  child: Text(
                                    "운동",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  )),
                              Container(
                                  width: 70,
                                  child: Text("sets",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center)),
                              Container(
                                  width: 80,
                                  child: Text("1rm",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center))
                            ],
                          ),
                        ),
                        ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext _context, int index) {
                              return Center(
                                  child: _exerciseWidget(
                                      SDBdata.exercises[index], index));
                            },
                            separatorBuilder:
                                (BuildContext _context, int index) {
                              return Container(
                                alignment: Alignment.center,
                                height: 1,
                                color: Colors.black,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 1,
                                  color: Color(0xFF717171),
                                ),
                              );
                            },
                            itemCount: SDBdata.exercises.length),
                        SDBdata.comment != ""
                            ? _feedTextField(SDBdata.comment)
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SDBdata.isVisible == false
                                ? Text("숨겨진 피드",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14))
                                : Container(),
                            _feedLikeButton(SDBdata),
                            _feedCommentButton(SDBdata)
                          ],
                        ),
                        _commentInfo["feedList"] == widget.feedListCtrl &&
                                _commentInfo["feedVisible"] == true
                            ? Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 1,
                                    color: Colors.black,
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 1,
                                      color: Color(0xFF717171),
                                    ),
                                  ),
                                  _commentContent(),
                                  _commentTextInput(SDBdata)
                                ],
                              )
                            : Container()
                      ],
                    ),
                  );
          }),
        ),
      ),
    );
  }

  Widget _commentContent() {
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext _context, int index) {
          return Padding(
              padding: EdgeInsets.all(4.0),
              child: _commentContentCore(_commentListbyId[index]));
        },
        separatorBuilder: (BuildContext _context, int index) {
          return Container(
            alignment: Alignment.center,
            height: 1,
            color: Colors.black,
            child: Container(
              alignment: Alignment.center,
              height: 1,
              color: Color(0xFF717171),
            ),
          );
        },
        itemCount: _commentListbyId.length);
  }

  Widget _commentContentCore(Comment) {
    User user = _userdataProvider.userFriendsAll.userdatas
        .where((user) => user.email == Comment.writer_email)
        .toList()[0];
    return _userdataProvider.userdata.dislike.contains(Comment.writer_email)
        ? Container(
            child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("차단된 사용자 입니다",
                    style: TextStyle(color: Colors.grey, fontSize: 12.0))))
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    user.image == ""
                        ? Icon(
                            Icons.account_circle,
                            color: Colors.grey,
                            size: 38.0,
                          )
                        : CircleAvatar(
                            radius: 18.0,
                            backgroundImage: NetworkImage(user.image),
                            backgroundColor: Colors.transparent),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Comment.writer_nickname,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12.0)),
                            Text(Comment.content,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                  size: 18.0,
                ),
                onTapDown: _storePosition,
                onTap: () {
                  _userdataProvider.userdata.email == Comment.writer_email
                      ? showMenu(
                          context: context,
                          position: RelativeRect.fromRect(
                              _tapPosition & Size(30, 30),
                              Offset.zero & Size(0, 0)),
                          items: [
                              PopupMenuItem(
                                  onTap: () {
                                    _historyProvider.deleteCommentAll(Comment);
                                    Future<void>.delayed(
                                        const Duration(), // OR const Duration(milliseconds: 500),
                                        () => CommentDelete(
                                                comment_id: Comment.id)
                                            .deleteComment());
                                  },
                                  padding: EdgeInsets.all(0.0),
                                  child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 0.0),
                                      leading: Icon(Icons.delete),
                                      title: Text("삭제"))),
                            ])
                      : showMenu(
                          context: context,
                          position: RelativeRect.fromRect(
                              _tapPosition & Size(30, 30),
                              Offset.zero & Size(0, 0)),
                          items: [
                              PopupMenuItem(
                                  onTap: () {
                                    Future<void>.delayed(
                                        const Duration(), // OR const Duration(milliseconds: 500),
                                        () => _displayDislikeAlert(
                                            Comment.writer_email));
                                  },
                                  padding: EdgeInsets.all(0.0),
                                  child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 0.0),
                                      leading:
                                          Icon(Icons.remove_circle_outlined),
                                      title: Text("신고"))),
                            ]);
                },
              )
            ],
          );
  }

  Future<void> _displayTextInputDialog(BuildContext context, SDBdata) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('코멘트를 입력해주세요'),
            content: TextField(
              onChanged: null,
              controller: _historyCommentCtrl,
              decoration: InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              _historyCommentSubmitButton(context, SDBdata),
            ],
          );
        });
  }

  Widget _historyCommentSubmitButton(context, SDBdata) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () {
              HistoryCommentEdit(
                      history_id: SDBdata.id,
                      user_email: _userdataProvider.userdata.email,
                      comment: _historyCommentCtrl.text)
                  .patchHistoryComment();
              _historyProvider.patchHistoryCommentdata(
                  SDBdata, _historyCommentCtrl.text);

              _historyCommentCtrl.clear();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("comment 입력",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  Widget _feedTextField(text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 10,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Text(text,
                style: TextStyle(color: Colors.white, fontSize: 14.0)),
          ),
        )
      ],
    );
  }

  Widget _feedCommentButton(SDBdata) {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    if (_commentInfo["feedList"] == widget.feedListCtrl) {
                      if (_commentInfo["feedVisible"] == true) {
                        _commentInfo = {
                          "feedList": widget.feedListCtrl,
                          "feedVisible": false
                        };
                      } else {
                        _commentInfo = {
                          "feedList": widget.feedListCtrl,
                          "feedVisible": true
                        };
                      }
                    } else {
                      _commentInfo = {
                        "feedList": widget.feedListCtrl,
                        "feedVisible": true
                      };
                    }
                  });
                },
                icon: Icon(Icons.message, color: Colors.white, size: 28.0)),
            Text(_commentListbyId.length.toString(),
                style: TextStyle(color: Colors.white, fontSize: 18.0))
          ],
        ));
  }

  Widget _feedLikeButton(SDBdata) {
    var buttonSize = 28.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: LikeButton(
        size: buttonSize,
        isLiked: onIsLikedCheck(SDBdata),
        circleColor:
            CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
        bubblesColor: BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: Icon(
              Icons.favorite,
              color: isLiked ? Colors.deepPurpleAccent : Colors.white,
              size: buttonSize,
            ),
          );
        },
        onTap: (bool isLiked) async {
          return onLikeButtonTapped(isLiked, SDBdata);
        },
        likeCount: SDBdata.like.length,
        countBuilder: (int? count, bool isLiked, String text) {
          var color = isLiked ? Colors.deepPurpleAccent : Colors.white;
          Widget result;
          if (count == 0) {
            result = Text(
              text,
              style: TextStyle(color: color, fontSize: 18.0),
            );
          } else
            result = Text(
              text,
              style: TextStyle(color: color, fontSize: 18.0),
            );
          return result;
        },
      ),
    );
  }

  bool onIsLikedCheck(SDBdata) {
    if (SDBdata.like.contains(_userdataProvider.userdata.email)) {
      return true;
    } else {
      return false;
    }
  }

  bool onLikeButtonTapped(bool isLiked, SDBdata) {
    if (isLiked == true) {
      HistoryLike(
              history_id: SDBdata.id,
              user_email: _userdataProvider.userdata.email,
              status: "remove",
              disorlike: "like")
          .patchHistoryLike();
      _historyProvider.patchHistoryLikedata(
          SDBdata, _userdataProvider.userdata.email, "remove");
      return false;
    } else {
      HistoryLike(
              history_id: SDBdata.id,
              user_email: _userdataProvider.userdata.email,
              status: "append",
              disorlike: "like")
          .patchHistoryLike();
      _historyProvider.patchHistoryLikedata(
          SDBdata, _userdataProvider.userdata.email, "append");
      return !isLiked;
    }
  }

  Widget _onDisLikeButtonTapped(email) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("Cancel",
                      style: TextStyle(fontSize: 20.0, color: Colors.red)))),
          SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: TextButton(
                  onPressed: () {
                    var user = UserLike(
                            liked_email: email,
                            user_email: _userdataProvider.userdata.email,
                            status: "append",
                            disorlike: "dislike")
                        .patchUserLike();
                    _userdataProvider.patchUserDislikedata(email, "append");

                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("Confirm",
                      style: TextStyle(fontSize: 20.0, color: Colors.blue)))),
        ],
      ),
    );
  }

  void _displayDislikeAlert(email) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              '친구 차단',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30, child: Text('피드와 댓글을 모두 차단하실 수 있어요')),
                  SizedBox(
                    height: 20,
                    child: Text('친구 관리에서 다시 차단 해제 할 수 있어요',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              _onDisLikeButtonTapped(email),
            ],
          );
        });
  }

  Widget _commentTextInput(SDBdata) {
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              controller: _commentInputCtrl,
              style: TextStyle(color: Colors.white, fontSize: 12.0),
              decoration: InputDecoration(
                hintText: "댓글 신고시 이용이 제한 될 수 있습니다.",
                hintStyle: TextStyle(color: Colors.white, fontSize: 12.0),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            child: Icon(Icons.arrow_upward, color: Colors.white),
            onTap: () {
              _historyProvider.addCommentAll(hisdata.Comment(
                  history_id: SDBdata.id,
                  reply_id: 0,
                  writer_email: _userdataProvider.userdata.email,
                  writer_nickname: _userdataProvider.userdata.nickname,
                  content: _commentInputCtrl.text));
              CommentCreate(
                      history_id: SDBdata.id,
                      reply_id: 0,
                      writer_email: _userdataProvider.userdata.email,
                      writer_nickname: _userdataProvider.userdata.nickname,
                      content: _commentInputCtrl.text)
                  .postComment();
              _commentInputCtrl.clear();
            },
          ),
        )
      ],
    );
  }

  Widget _exerciseWidget(Exercises, index) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 120,
              child: Text(
                Exercises.name,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            Container(
              width: 70,
              child: Text(
                Exercises.sets.length.toString(),
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 80,
              child: Text(
                Exercises.onerm.toStringAsFixed(1),
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
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
