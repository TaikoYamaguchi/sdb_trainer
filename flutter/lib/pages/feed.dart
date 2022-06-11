import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:sdb_trainer/pages/feed_friend.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:like_button/like_button.dart';
import 'package:sdb_trainer/providers/userdata.dart';

class Feed extends StatefulWidget {
  Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  var _feedListCtrl = 1;

  final Map<int, Widget> _feedList = const <int, Widget>{
    1: Padding(
      child: Text("모두 보기", style: TextStyle(color: Colors.white, fontSize: 14)),
      padding: const EdgeInsets.all(10.0),
    ),
    2: Padding(
        child:
            Text("친구 보기", style: TextStyle(color: Colors.white, fontSize: 14)),
        padding: const EdgeInsets.all(10.0)),
    3: Padding(
        child:
            Text("내 피드", style: TextStyle(color: Colors.white, fontSize: 14)),
        padding: const EdgeInsets.all(10.0))
  };

  var _historydataAll;
  var _userdataProvider;
  var _historyCommentCtrl;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _historydataAll = Provider.of<HistorydataProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    print("111111");
    return Scaffold(
        appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("피드", style: TextStyle(color: Colors.white)),
                FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          Transition(
                              child: FeedFriend(),
                              transitionEffect:
                                  TransitionEffect.RIGHT_TO_LEFT));
                    },
                    child: Text("친구관리", style: TextStyle(color: Colors.white))),
              ],
            ),
            backgroundColor: Colors.black),
        body: _userdataProvider.userdata != null
            ? _feedCardList(context)
            : Center(child: CircularProgressIndicator()));
  }

  Widget _feedCardList(context) {
    return Column(
      children: [
        _feedControllerWidget(),
        Expanded(
          child: Consumer<HistorydataProvider>(
              builder: (builder, provider, child) {
            return ListView.separated(
                itemBuilder: (BuildContext _context, int index) {
                  return Center(
                      child: _feedCard(
                          provider.historydataAll.sdbdatas[index], index));
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
                itemCount: provider.historydataAll.sdbdatas.length);
          }),
        ),
      ],
    );
  }

  Widget _feedCard(SDBdata, index) {
    var user;
    print(SDBdata.comment);
    print("comment");
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            color: Color(0xFF717171),
            child: Column(
              children: [
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder(
                            future: UserInfo(userEmail: SDBdata.user_email)
                                .getUserByEmail(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData == false) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Error: ${snapshot.error}',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                );
                              } else {
                                return Text(
                                  snapshot.data.nickname,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                );
                              }
                            }),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text(SDBdata.date.substring(2, 10),
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                            ),
                            SDBdata.user_email ==
                                    _userdataProvider.userdata.email
                                ? GestureDetector(
                                    onTap: () {
                                      _historyCommentCtrl =
                                          TextEditingController(
                                              text: SDBdata.comment);
                                      ;
                                      _displayTextInputDialog(
                                          context, SDBdata.id);
                                    },
                                    child: Icon(Icons.menu,
                                        color: Colors.white, size: 18.0))
                                : Container()
                          ],
                        ),
                      ],
                    )),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                    itemBuilder: (BuildContext _context, int index) {
                      return Center(
                          child:
                              _exerciseWidget(SDBdata.exercises[index], index));
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
                    itemCount: SDBdata.exercises.length),
                SDBdata.comment != ""
                    ? _feedTextField(SDBdata.comment)
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_feedLikeButton(SDBdata), _feedCommentButton()],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, history_id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('코멘트를 입력해주세요'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  print(value);
                });
              },
              controller: _historyCommentCtrl,
              decoration: InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              _historyCommentSubmitButton(context, history_id),
            ],
          );
        });
  }

  Widget _historyCommentSubmitButton(context, history_id) {
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
                      history_id: history_id,
                      user_email: _userdataProvider.userdata.email,
                      comment: _historyCommentCtrl.text)
                  .patchHistoryComment();

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

  Widget _feedCommentButton() {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(
                onPressed: null,
                icon: Icon(Icons.message, color: Colors.grey, size: 28.0)),
            Text("0", style: TextStyle(color: Colors.white, fontSize: 18.0))
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

  Future<bool?> onLikeButtonTapped(bool isLiked, SDBdata) async {
    print(isLiked);
    if (isLiked == true) {
      var history = await HistoryLike(
              history_id: SDBdata.id,
              user_email: _userdataProvider.userdata.email,
              status: "remove",
              disorlike: "like")
          .patchHistoryLike();
      print("false");
      print(history);
      return false;
    } else {
      var history = await HistoryLike(
              history_id: SDBdata.id,
              user_email: _userdataProvider.userdata.email,
              status: "append",
              disorlike: "like")
          .patchHistoryLike();
      print(history);
      print("true");
      return !isLiked;
    }
  }

  Widget _feedControllerWidget() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        color: Colors.black,
        child: CupertinoSlidingSegmentedControl(
            groupValue: _feedListCtrl,
            children: _feedList,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            backgroundColor: Colors.black,
            thumbColor: Color.fromRGBO(25, 106, 223, 20),
            onValueChanged: (i) {
              setState(() {
                _feedListCtrl = i as int;
                if (_feedListCtrl == 2) {
                  _historydataAll
                      .getFriendsHistorydata(_userdataProvider.userdata.email);
                } else if (_feedListCtrl == 1) {
                  _historydataAll.getHistorydataAll();
                } else if (_feedListCtrl == 3) {
                  print("나만보기");
                  _historydataAll.getdata();
                }
                print(_feedListCtrl);
              });
            }),
      ),
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
