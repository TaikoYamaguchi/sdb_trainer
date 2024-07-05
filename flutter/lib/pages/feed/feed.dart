import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/feed/feed_friend_edit.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/feed/feed_friend.dart';
import 'package:sdb_trainer/src/utils/feedCard.dart';
import 'package:flutter/cupertino.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  var _feedListCtrl = 1;
  var _hisProvider;
  var _historydata;
  var _userProvider;
  var _final_history_id;
  final _pageController = ScrollController();
  var _hasMore = true;

  final _isPageController = PageController(initialPage: 4242, keepPage: true);

  final binding = WidgetsFlutterBinding.ensureInitialized();
  Map<String, String> UNIT_ID = kReleaseMode
      ? {
          'ios': 'ca-app-pub-1921739371491657/3676809918',
          'android': 'ca-app-pub-1921739371491657/2555299930',
        }
      : {
          'ios': 'ca-app-pub-3940256099942544/2934735716',
          'android': 'ca-app-pub-3940256099942544/6300978111',
        };
  BannerAd? banner;

  @override
  void initState() {
    super.initState();
    binding.addPostFrameCallback((_) async {
      BuildContext context = binding.renderViewElement!;
      _pageController.addListener(() {
        if (_pageController.position.maxScrollExtent ==
            _pageController.offset) {
          _fetchHistoryPage(context);
        }
      });
    });
    banner = BannerAd(
      size: AdSize.banner,
      adUnitId: UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {},
        onAdLoaded: (_) {},
      ),
      request: const AdRequest(),
    )..load();
  }

  Future _fetchHistoryPage(context) async {
    _hasMore = true;
    try {
      await HistorydataPagination(final_history_id: _final_history_id)
          .loadSDBdataPagination()
          .then((data) => {
                if (data.sdbdatas.isEmpty != true)
                  {
                    _hisProvider.addHistorydataPage(data),
                    if (context != null)
                      {
                        for (var history in data.sdbdatas)
                          {
                            if (history.image!.isEmpty != true)
                              {
                                for (var image in history.image!)
                                  {
                                    precacheImage(
                                        CachedNetworkImageProvider(image),
                                        context)
                                  }
                              }
                          }
                      },
                    setState(() {
                      print("noooo");
                      if (_feedListCtrl == 1) {
                        _hasMore = true;
                      }
                    })
                  }
                else
                  {
                    setState(() {
                      print("noooo");
                      if (_feedListCtrl == 1) {
                        _hasMore = false;
                      }
                    })
                  }
              });
    } catch (e) {
      setState(() {
        if (_feedListCtrl == 1) {
          _hasMore = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0), // here the desired height
          child: AppBar(
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("피드",
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          Transition(
                              child: const FeedFriend(),
                              transitionEffect:
                                  TransitionEffect.RIGHT_TO_LEFT));
                    },
                    child: Text("친구관리",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight))),
              ],
            ),
            backgroundColor: Theme.of(context).canvasColor,
          )),
      body: _userProvider.userdata != null
          ? Center(child: _feedCardList(context))
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _onRefresh() {
    _hisProvider.getFriendsHistorydata();
    _hisProvider.getdata();
    _hisProvider.getCommentAll();
    _hisProvider.getHistorydataAll();
    return Future<void>.value();
  }

  Widget _feedCardList(context) {
    return Container(
      child: Column(
        children: [
          Container(
              height: 40,
              alignment: Alignment.center,
              child: Center(child: _feedControllerWidget())),
          Expanded(
            child: Consumer<HistorydataProvider>(
                builder: (builder, provider, child) {
              _feedController(_feedListCtrl);
              return PageView.builder(
                  controller: _isPageController,
                  itemBuilder: (_, page) {
                    return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: _historydata.isEmpty
                            ? _feedListCtrl == 2
                                ? feedEmptySearchFriend()
                                : feedEmptyMyEx()
                            : ListView.separated(
                                controller: _pageController,
                                itemBuilder:
                                    (BuildContext _context, int index) {
                                  if (index <
                                      _historydata.length +
                                          (_historydata.length / 3).floor()) {
                                    return Center(
                                        child: FeedCard(
                                            sdbdata: _historydata[index -
                                                ((index + 1) / 3).floor()],
                                            index: index -
                                                ((index + 1) / 3).floor(),
                                            feedListCtrl: _feedListCtrl,
                                            ad: (index + 1) % 3 == 0
                                                ? true
                                                : false,
                                            openUserDetail: true));
                                  } else {
                                    _final_history_id = _historydata[index -
                                            ((index + 1) / 3).floor() -
                                            1]
                                        .id;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Center(
                                          child: _hasMore == true
                                              ? _feedListCtrl == 1
                                                  ? const CircularProgressIndicator()
                                                  : Container()
                                              : Text("데이터 없음",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorLight))),
                                    );
                                  }
                                },
                                separatorBuilder:
                                    (BuildContext _context, int index) {
                                  return Container(
                                    alignment: Alignment.center,
                                    height: 0,
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 0,
                                      color: const Color(0xFF717171),
                                    ),
                                  );
                                },
                                itemCount: _historydata.length +
                                    1 +
                                    (_historydata.length / 3).floor()));
                  },
                  onPageChanged: (page) {
                    setState(() {
                      _feedListCtrl = (page % 3) + 1 as int;
                      _feedController(_feedListCtrl);
                    });
                  });
            }),
          ),
        ],
      ),
    );
  }

  Widget _feedControllerWidget() {
    Map<int, Widget> _feedList = <int, Widget>{
      1: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text("모두 보기",
            textScaleFactor: 1.3,
            style: TextStyle(
              color: _feedListCtrl == 1
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).primaryColorDark,
            )),
      ),
      2: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text("친구 보기",
              textScaleFactor: 1.3,
              style: TextStyle(
                color: _feedListCtrl == 2
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColorDark,
              ))),
      3: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text("내 피드",
              textScaleFactor: 1.3,
              style: TextStyle(
                color: _feedListCtrl == 3
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).primaryColorDark,
              )))
    };
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: CupertinoSlidingSegmentedControl(
            groupValue: _feedListCtrl,
            children: _feedList,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            thumbColor: Theme.of(context).primaryColor,
            onValueChanged: (i) {
              setState(() {
                _feedListCtrl = i as int;
                _isPageController.jumpToPage(4241 + i);
                _feedController(_feedListCtrl);
              });
            }),
      ),
    );
  }

  Widget feedEmptySearchFriend() {
    return Center(
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "친구를 추가 할 수 있어요",
              textScaleFactor: 2.0,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
            const Text("아래를 눌러 친구를 추가해보세요",
                textScaleFactor: 1.3, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
                width: MediaQuery.of(context).size.width * 2 / 3,
                child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).primaryColor,
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                      ),
                      padding: const EdgeInsets.all(12.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          Transition(
                              child: FeedFriendEdit(),
                              transitionEffect:
                                  TransitionEffect.RIGHT_TO_LEFT));
                    },
                    child: Text("친구 찾기",
                        textScaleFactor: 1.5,
                        style: TextStyle(
                            color: Theme.of(context).highlightColor))))
          ]),
        ),
      ),
    );
  }

  Widget feedEmptyMyEx() {
    var bodyStater = Provider.of<BodyStater>(context, listen: false);
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "첫 운동을 시작해보세요",
          textScaleFactor: 2.0,
          style: TextStyle(color: Theme.of(context).primaryColorLight),
        ),
        const Text("아래를 눌러서 운동 할 수 있어요",
            textScaleFactor: 1.3, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        SizedBox(
            width: MediaQuery.of(context).size.width * 2 / 3,
            child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).primaryColor,
                  textStyle: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                  ),
                  padding: const EdgeInsets.all(12.0),
                ),
                onPressed: () {
                  bodyStater.change(0);
                },
                child: Text("첫 운동 하기",
                    textScaleFactor: 1.5,
                    style: TextStyle(color: Theme.of(context).highlightColor))))
      ]),
    );
  }

  void _feedController(_feedListCtrl) {
    if (_feedListCtrl == 2) {
      _historydata = _hisProvider.historydataFriends.sdbdatas.where((sdbdata) {
        if (sdbdata.isVisible == true) {
          return true;
        } else {
          return false;
        }
      }).toList();
    } else if (_feedListCtrl == 1) {
      _historydata = _hisProvider.historydataAll.sdbdatas.where((sdbdata) {
        if (sdbdata.isVisible == true) {
          return true;
        } else {
          return false;
        }
      }).toList();
    } else if (_feedListCtrl == 3) {
      _historydata = _hisProvider.historydata.sdbdatas;
    }
  }

  @override
  void dispose() {
    print('dispose');
    _pageController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }
}
