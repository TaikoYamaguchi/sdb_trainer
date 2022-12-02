import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/feed_friend.dart';
import 'package:sdb_trainer/src/utils/feedCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Feed extends StatefulWidget {
  Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  var _feedListCtrl = 1;

  final Map<int, Widget> _feedList = const <int, Widget>{
    1: Padding(
      child: Text("모두 보기", style: TextStyle(color: Colors.white, fontSize: 16)),
      padding: const EdgeInsets.all(5.0),
    ),
    2: Padding(
        child:
            Text("친구 보기", style: TextStyle(color: Colors.white, fontSize: 16)),
        padding: const EdgeInsets.all(5.0)),
    3: Padding(
        child:
            Text("내 피드", style: TextStyle(color: Colors.white, fontSize: 16)),
        padding: const EdgeInsets.all(5.0))
  };

  var _hisProvider;
  var _historydata;
  var _userProvider;
  final _pageController = ScrollController();
  var _final_history_id;
  var _hasMore = true;

  final _isPageController = PageController(initialPage: 4242, keepPage: true);

  final binding = WidgetsFlutterBinding.ensureInitialized();
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
  }

  Future _fetchHistoryPage(context) async {
    try {
      var nextPage =
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
                          }
                      }
                    else
                      {
                        setState(() {
                          _hasMore = false;
                        })
                      }
                  });
    } catch (e) {
      setState(() {
        _hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Color(0xFF101012),
      extendBody: true,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // here the desired height
          child: AppBar(
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("피드",
                      style: TextStyle(color: Colors.white, fontSize: 25)),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            Transition(
                                child: FeedFriend(),
                                transitionEffect:
                                    TransitionEffect.RIGHT_TO_LEFT));
                      },
                      child:
                          Text("친구관리", style: TextStyle(color: Colors.white))),
                ],
              ),
              backgroundColor: Color(0xFF101012))),
      body: _userProvider.userdata != null
          ? Center(child: _feedCardList(context))
          : Center(child: CircularProgressIndicator()),
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
      color: Color(0xFF101012),
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
                        child: ListView.separated(
                            controller: _pageController,
                            itemBuilder: (BuildContext _context, int index) {
                              if (index < _historydata.length) {
                                return Center(
                                    child: FeedCard(
                                        sdbdata: _historydata[index],
                                        index: index,
                                        feedListCtrl: _feedListCtrl));
                              } else {
                                _final_history_id = _historydata[index - 1].id;
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                      child: _hasMore
                                          ? CircularProgressIndicator()
                                          : Text("데이터 없음",
                                              style: TextStyle(
                                                  color: Colors.white))),
                                );
                              }
                            },
                            separatorBuilder:
                                (BuildContext _context, int index) {
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
                            itemCount: _historydata.length + 1));
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
    return SizedBox(
      width: double.infinity,
      child: Container(
        color: Color(0xFF101012),
        child: CupertinoSlidingSegmentedControl(
            groupValue: _feedListCtrl,
            children: _feedList,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            backgroundColor: Color(0xFF101012),
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
