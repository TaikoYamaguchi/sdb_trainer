import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/interviewdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/interview_repository.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/feed_friend.dart';
import 'package:sdb_trainer/src/utils/feedCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Interview extends StatefulWidget {
  Interview({Key? key}) : super(key: key);

  @override
  State<Interview> createState() => _InterviewState();
}

class _InterviewState extends State<Interview> {
  var _userProvider;
  var _interviewProvider;
  final _pageController = ScrollController();
  var _final_interview_id;
  var _hasMore = true;

  final binding = WidgetsFlutterBinding.ensureInitialized();
  @override
  void initState() {
    super.initState();
    binding.addPostFrameCallback((_) async {
      _fetchInterviewPage();
      _pageController.addListener(() {
        if (_pageController.position.maxScrollExtent ==
            _pageController.offset) {
          _fetchInterviewPage();
        }
      });
    });
  }

  Future _fetchInterviewPage() async {
    try {
      var nextPage =
          await InterviewdataPagination(final_interview_id: _final_interview_id)
              .loadInterviewDataAllPagination()
              .then((data) => {
                    if (data.interviewDatas.isEmpty != true)
                      {
                        _interviewProvider.addHistorydataPage(data),
                      }
                    else
                      {
                        setState(() {
                          print("noooo");
                          _hasMore = false;
                        })
                      }
                  });
    } catch (e) {
      setState(() {
        print("noooo");
        _hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _interviewProvider =
        Provider.of<InterviewdataProvider>(context, listen: false);

    bool btnDisabled = false;
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0), // here the desired height
          child: AppBar(
            elevation: 0,
            leading: IconButton(
              color: Theme.of(context).primaryColorLight,
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("기능 제안하기",
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                TextButton(
                    onPressed: () {
                      print("등록");
                    },
                    child: Text("등록",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight))),
              ],
            ),
            backgroundColor: Theme.of(context).canvasColor,
          )),
      body: _userProvider.userdata != null
          ? _interviewProvider.interviewdataAll != null
              ? Center(child: _interviewCardList(context))
              : Center(child: CircularProgressIndicator())
          : Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _onRefresh() {
    _interviewProvider.getinterviewdataFirst();
    return Future<void>.value();
  }

  Widget _interviewCardList(context) {
    var _interviewDatas = _interviewProvider.interviewdataAll.interviewDatas;
    print(MediaQuery.of(context).size.width);
    return Container(
      width: MediaQuery.of(context).size.width,
      child:
          Consumer<InterviewdataProvider>(builder: (builder, provider, child) {
        return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
                controller: _pageController,
                itemBuilder: (BuildContext _context, int index) {
                  if (index < _interviewDatas.length) {
                    print(MediaQuery.of(context).size.width);
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 120,
                      child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Text(_interviewDatas[index].content)),
                    );
                  } else {
                    _final_interview_id = _interviewDatas[index - 1].id;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                          child: _hasMore
                              ? CircularProgressIndicator()
                              : Text("데이터 없음",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .primaryColorLight))),
                    );
                  }
                },
                separatorBuilder: (BuildContext _context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 0,
                    child: Container(
                      alignment: Alignment.center,
                      height: 0,
                      color: Color(0xFF717171),
                    ),
                  );
                },
                itemCount: _interviewDatas.length + 1));
      }),
    );
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
