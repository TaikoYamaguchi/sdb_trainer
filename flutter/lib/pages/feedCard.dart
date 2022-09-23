import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/friendProfile.dart';
import 'package:sdb_trainer/pages/friendHistory.dart';
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
import 'package:cached_network_image/cached_network_image.dart';

import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();
  TextEditingController _commentInputCtrl = TextEditingController(text: "");
  late var _commentInfo = {
    "feedList": widget.feedListCtrl,
    "feedVisible": false
  };

  late var _photoInfo = {"feedList": widget.feedListCtrl, "feedVisible": false};
  @override
  void initState() {
    _tapPosition = Offset(0.0, 0.0);
    super.initState();
  }

  Future<void> _pickImg(SDBdata) async {
    final XFile? selectImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (selectImage != null) {
      dynamic sendData = selectImage.path;
      HistoryImageEdit(file: sendData, history_id: SDBdata.id)
          .patchHistoryImage()
          .then((data) {
        _historyProvider.getdata();
        _historyProvider.getHistorydataAll();
      });
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      user.image == ""
                                          ? Icon(
                                              Icons.account_circle,
                                              color: Colors.grey,
                                              size: 46.0,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: user.image,
                                              imageBuilder:
                                                  (context, imageProivder) =>
                                                      Container(
                                                height: 46,
                                                width: 46,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                50)),
                                                    image: DecorationImage(
                                                      image: imageProivder,
                                                      fit: BoxFit.cover,
                                                    )),
                                              ),
                                            ),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Text(SDBdata.date.substring(2, 10),
                                          style: TextStyle(
                                              fontSize: 14,
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
                                                            leading: Icon(
                                                                Icons.mode_edit,
                                                                color: Colors
                                                                    .white),
                                                            title: Text("코멘트",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white))),
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
                                                            leading: Icon(
                                                                Icons
                                                                    .add_photo_alternate,
                                                                color: Colors
                                                                    .white),
                                                            title: Text("사진추가",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white))),
                                                        onTap: () {
                                                          _pickImg(SDBdata);
                                                        }),
                                                    PopupMenuItem(
                                                        child: ListTile(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        4.0,
                                                                    vertical:
                                                                        0.0),
                                                            leading: Icon(
                                                                Icons
                                                                    .no_photography,
                                                                color: Colors
                                                                    .white),
                                                            title: Text("사진삭제",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white))),
                                                        onTap: () {
                                                          if (SDBdata.image
                                                                  .length !=
                                                              0) {
                                                            HistoryImageDelete(
                                                                    history_id:
                                                                        SDBdata
                                                                            .id)
                                                                .deleteHistoryIamge()
                                                                .then((value) {
                                                              _historyProvider
                                                                  .getdata();
                                                              _historyProvider
                                                                  .getHistorydataAll();
                                                            });
                                                          }
                                                        }),
                                                    PopupMenuItem(
                                                        child: ListTile(
                                                            contentPadding: EdgeInsets.symmetric(
                                                                horizontal: 4.0,
                                                                vertical: 0.0),
                                                            leading: SDBdata
                                                                    .isVisible
                                                                ? Icon(Icons.filter_list_off,
                                                                    color: Colors
                                                                        .white)
                                                                : Icon(Icons.filter_list,
                                                                    color: Colors
                                                                        .white),
                                                            title: SDBdata.isVisible
                                                                ? Text("숨김",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white))
                                                                : Text("보임",
                                                                    style: TextStyle(
                                                                        color: Colors.white))),
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
                                                            leading: Icon(
                                                                Icons
                                                                    .remove_circle_outlined,
                                                                color: Colors
                                                                    .white),
                                                            title: Text("신고",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white))),
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
                        SDBdata.comment != ""
                            ? _feedTextField(SDBdata.comment)
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  width: 180,
                                  child: Text(
                                    "운동",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  )),
                              Container(
                                  width: 50,
                                  child: Text("세트",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center)),
                              Container(
                                  width: 70,
                                  child: Text("1rm",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center))
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                Transition(
                                    child: FriendHistory(sdbdata: SDBdata),
                                    transitionEffect:
                                        TransitionEffect.RIGHT_TO_LEFT));
                          },
                          child: ListView.separated(
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
                                  height: 0,
                                  color: Colors.black,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 0,
                                    color: Color(0xFF717171),
                                  ),
                                );
                              },
                              itemCount: SDBdata.exercises.length),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 20.0, top: 15.0, bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SDBdata.isVisible == false
                                  ? Text("숨겨진 피드",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14))
                                  : Container(),
                              _feedPhotoButton(SDBdata),
                              _feedLikeButton(SDBdata),
                              _feedCommentButton(SDBdata)
                            ],
                          ),
                        ),
                        _photoInfo["feedList"] == widget.feedListCtrl &&
                                _photoInfo["feedVisible"] == true &&
                                SDBdata.image.length != 0
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
                                  _imageContent(SDBdata),
                                ],
                              )
                            : Container(),
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

  Widget _imageContent(SDBdata) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext _context, int index) {
                  return Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CachedNetworkImage(
                        imageUrl: SDBdata.image[index],
                        imageBuilder: (context, imageProivder) => Container(
                          height: MediaQuery.of(context).size.width - 64.0,
                          width: MediaQuery.of(context).size.width - 64.0,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              image: DecorationImage(
                                image: imageProivder,
                                fit: BoxFit.cover,
                              )),
                        ),
                      ));
                },
                separatorBuilder: (BuildContext _context, int index) {
                  return Container(
                    height: 1,
                    alignment: Alignment.center,
                    color: Colors.black,
                    child: Container(
                      height: 1,
                      alignment: Alignment.center,
                      color: Color(0xFF717171),
                    ),
                  );
                },
                itemCount: SDBdata.image.length),
          ),
        ),
        GestureDetector(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 30.0,
                child: Center(
                    child: Icon(Icons.keyboard_control_key,
                        color: Colors.grey, size: 28.0))),
            onTap: () {
              setState(() {
                if (_photoInfo["feedList"] == widget.feedListCtrl) {
                  if (_photoInfo["feedVisible"] == true) {
                    _photoInfo = {
                      "feedList": widget.feedListCtrl,
                      "feedVisible": false
                    };
                  } else {
                    _photoInfo = {
                      "feedList": widget.feedListCtrl,
                      "feedVisible": true
                    };
                  }
                } else {
                  _photoInfo = {
                    "feedList": widget.feedListCtrl,
                    "feedVisible": true
                  };
                }
              });
            })
      ],
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        Transition(
                            child: FriendProfile(user: user),
                            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                  },
                  child: Row(
                    children: [
                      user.image == ""
                          ? Icon(
                              Icons.account_circle,
                              color: Colors.grey,
                              size: 38.0,
                            )
                          : CachedNetworkImage(
                              imageUrl: user.image,
                              imageBuilder: (context, imageProivder) =>
                                  Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                    image: DecorationImage(
                                      image: imageProivder,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ),
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
                                      leading: Icon(Icons.delete,
                                          color: Colors.white),
                                      title: Text("삭제",
                                          style:
                                              TextStyle(color: Colors.white)))),
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
                                      leading: Icon(
                                          Icons.remove_circle_outlined,
                                          color: Colors.white),
                                      title: Text("신고",
                                          style:
                                              TextStyle(color: Colors.white)))),
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
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              buttonPadding: EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Theme.of(context).cardColor,
              contentPadding: EdgeInsets.all(12.0),
              title: Text('운동에 글을 남겨 보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('코멘트를 입력해 주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('외부를 터치하면 취소 할 수 있어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(height: 20),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      null;
                    });
                  },
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                  textAlign: TextAlign.center,
                  controller: _historyCommentCtrl,
                  decoration: InputDecoration(
                      filled: true,
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 3),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 3),
                      ),
                      hintText: "운동 글 남기기",
                      hintStyle:
                          TextStyle(fontSize: 16.0, color: Colors.white)),
                ),
              ]),
              actions: <Widget>[
                _historyCommentSubmitButton(context, SDBdata),
              ],
            );
          });
        });
  }

  Widget _historyCommentSubmitButton(context, SDBdata) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: _historyCommentCtrl.text == ""
                ? Color(0xFF212121)
                : Theme.of(context).primaryColor,
            textColor: Colors.white,
            disabledColor: Color(0xFF212121),
            disabledTextColor: Colors.white,
            padding: EdgeInsets.all(12.0),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () {
              _historyCommentCtrl.text == ""
                  ? null
                  : HistoryCommentEdit(
                          history_id: SDBdata.id,
                          user_email: _userdataProvider.userdata.email,
                          comment: _historyCommentCtrl.text)
                      .patchHistoryComment();
              _historyProvider.patchHistoryCommentdata(
                  SDBdata, _historyCommentCtrl.text);

              _historyCommentCtrl.clear();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("글 남기기",
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
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
        child: GestureDetector(
            onTap: () {
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child:
                        Icon(Icons.message, color: Colors.white, size: 24.0)),
                Text(_commentListbyId.length.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 16.0))
              ],
            )));
  }

  Widget _feedPhotoButton(SDBdata) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 4.0, 12.0, 4.0),
        child: GestureDetector(
            onTap: () {
              setState(() {
                if (_photoInfo["feedList"] == widget.feedListCtrl) {
                  if (_photoInfo["feedVisible"] == true) {
                    _photoInfo = {
                      "feedList": widget.feedListCtrl,
                      "feedVisible": false
                    };
                  } else {
                    _photoInfo = {
                      "feedList": widget.feedListCtrl,
                      "feedVisible": true
                    };
                  }
                } else {
                  _photoInfo = {
                    "feedList": widget.feedListCtrl,
                    "feedVisible": true
                  };
                }
              });
            },
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child: Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 24.0)),
                Text(SDBdata.image.length.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 16.0))
              ],
            )));
  }

  Widget _feedLikeButton(SDBdata) {
    var buttonSize = 24.0;
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
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              Icons.favorite,
              color: isLiked ? Theme.of(context).primaryColor : Colors.white,
              size: buttonSize,
            ),
          );
        },
        onTap: (bool isLiked) async {
          return onLikeButtonTapped(isLiked, SDBdata);
        },
        likeCount: SDBdata.like.length,
        countBuilder: (int? count, bool isLiked, String text) {
          var color = isLiked ? Theme.of(context).primaryColor : Colors.white;
          Widget result;
          if (count == 0) {
            result = Text(
              text,
              style: TextStyle(color: color, fontSize: 16.0),
            );
          } else
            result = Text(
              text,
              style: TextStyle(
                  color: color, fontSize: 16.0, fontWeight: FontWeight.bold),
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
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Theme.of(context).primaryColor,
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
            child: Text("차단하기",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _displayDislikeAlert(email) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            title: Text('사용자를 차단 할 수 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24)),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('피드와 댓글을 모두 차단 할 수 있어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text(
                    '친구 관리에서 다시 차단 해제 할 수 있어요',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
              width: 180,
              child: Text(
                Exercises.name,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            Container(
              width: 50,
              child: Text(
                Exercises.sets.length.toString(),
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 70,
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
