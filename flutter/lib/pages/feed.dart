import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/pages/userProfile.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:sdb_trainer/pages/feed_friend.dart';
import 'package:sdb_trainer/pages/feedCard.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:like_button/like_button.dart';

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
  var _historydata;
  var _userdataProvider;
  var _historyCommentCtrl;
  @override
  void initState() {
    super.initState();
    initialProviderGet();
  }

  void initialProviderGet() async {
    final _initUserdataProvider =
        Provider.of<UserdataProvider>(context, listen: false);
    final _initHistorydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);

    final _initExercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    await _initUserdataProvider.getdata();
    _initHistorydataProvider
        .getFriendsHistorydata(_initUserdataProvider.userdata.email);
    _initUserdataProvider.getFriendsdata(_initUserdataProvider.userdata.email);
    _initUserdataProvider.getUsersFriendsAll(context);
    _initExercisesdataProvider.getdata();
    _initHistorydataProvider.getHistorydataAll();
    _initHistorydataProvider.getdata();
    _initHistorydataProvider.getCommentAll();

    _initUserdataProvider.userdata != null
        ? [
            _initUserdataProvider
                .getFriendsdata(_initUserdataProvider.userdata.email),
            _initHistorydataProvider
                .getFriendsHistorydata(_initUserdataProvider.userdata.email)
          ]
        : null;
  }

  @override
  Widget build(BuildContext context) {
    _historydataAll = Provider.of<HistorydataProvider>(context, listen: false);
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);

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
        body: RefreshIndicator(
          child: _userdataProvider.userdata != null
              ? _feedCardList(context)
              : Center(child: CircularProgressIndicator()),
          onRefresh: _onRefresh,
        ));
  }

  Future<void> _onRefresh() {
    _historydataAll.getFriendsHistorydata(_userdataProvider.userdata.email);
    _historydataAll.getdata();
    _historydataAll.getCommentAll();
    return Future<void>.value();
  }

  Widget _feedCardList(context) {
    return Column(
      children: [
        _feedControllerWidget(),
        Expanded(
          child: Consumer<HistorydataProvider>(
              builder: (builder, provider, child) {
            _feedController(_feedListCtrl);
            return ListView.separated(
                itemBuilder: (BuildContext _context, int index) {
                  return Center(
                      child: FeedCard(
                          sdbdata: _historydata[index],
                          index: index,
                          feedListCtrl: _feedListCtrl));
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
                itemCount: _historydata.length);
          }),
        ),
      ],
    );
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
                _feedController(_feedListCtrl);
              });
            }),
      ),
    );
  }

  void _feedController(_feedListCtrl) {
    if (_feedListCtrl == 2) {
      _historydata =
          _historydataAll.historydataFriends.sdbdatas.where((sdbdata) {
        if (sdbdata.isVisible == true) {
          return true;
        } else {
          return false;
        }
      }).toList();
    } else if (_feedListCtrl == 1) {
      _historydata = _historydataAll.historydataAll.sdbdatas.where((sdbdata) {
        if (sdbdata.isVisible == true) {
          return true;
        } else {
          return false;
        }
      }).toList();
    } else if (_feedListCtrl == 3) {
      _historydata = _historydataAll.historydata.sdbdatas;
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
