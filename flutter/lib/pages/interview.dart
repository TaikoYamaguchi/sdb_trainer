import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/interviewdata.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/interview_repository.dart';
import 'package:sdb_trainer/src/utils/alerts.dart';
import 'package:sdb_trainer/src/utils/util.dart';
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
  var _themeProvider;
  var _hasMore = true;
  List<String> _tagsList = [
    '버그',
    '기능 개선',
    '질문',
    '기타',
  ];
  List<String>? _tags = [];

  TextEditingController _titleCtrl = TextEditingController(text: "");
  TextEditingController _contentCtrl = TextEditingController(text: "");

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
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("기능 제안하기",
                    textScaleFactor: 1.5,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
              ],
            ),
            actions: [
              GestureDetector(
                  onTap: () {
                    _showInterviewPostBottomSheet();
                    print("등록");
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.open_in_new,
                        size: 28, color: Theme.of(context).primaryColor),
                  )),
            ],
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
    return Container(
      width: MediaQuery.of(context).size.width,
      child:
          Consumer<InterviewdataProvider>(builder: (builder, provider, child) {
        var _interviewDatas =
            _interviewProvider.interviewdataAll.interviewDatas;
        return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
                controller: _pageController,
                itemBuilder: (BuildContext _context, int index) {
                  if (index < _interviewDatas.length) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              child: _interviewDatas[index].progress == "open"
                                  ? Icon(
                                      Icons.radio_button_unchecked,
                                      color: Color(0xFF26A943),
                                      size: 28,
                                    )
                                  : _interviewDatas[index].progress == "closed"
                                      ? Icon(Icons.radio_button_checked,
                                          color: Theme.of(context).primaryColor,
                                          size: 28)
                                      : Icon(Icons.radio_button_checked,
                                          color: Theme.of(context).primaryColor,
                                          size: 28),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _interviewDatas[index].title,
                                            textAlign: TextAlign.start,
                                            textScaleFactor: 1.5,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorLight),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: Text(
                                              _interviewDatas[index]
                                                  .date
                                                  .substring(2, 10),
                                              textScaleFactor: 1.1,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _interviewDatas[index].content,
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      child: Wrap(
                                          children: _interviewDatas[index]
                                              .tags
                                              .map<Widget>(
                                        (tag) {
                                          bool isSelected = true;

                                          return GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 4, vertical: 2),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 8),
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .buttonColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      border: Border.all(
                                                          color: isSelected
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                          width: 1)),
                                                  child: Text(
                                                    tag,
                                                    style: TextStyle(
                                                        color: isSelected
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Theme.of(context)
                                                                .primaryColorDark,
                                                        fontSize: 12 *
                                                            _themeProvider
                                                                .userFontSize /
                                                            0.8),
                                                  ),
                                                )),
                                          );
                                        },
                                      ).toList()),
                                    ),
                                    Divider(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        thickness: 0.3)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (_interviewDatas.length == 0) {
                    return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                            child: Text("데이터 없음",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).primaryColorLight))));
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
                      color: Theme.of(context).primaryColorDark,
                    ),
                  );
                },
                itemCount: _interviewDatas.length + 1));
      }),
    );
  }

  void _showInterviewPostBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: Container(
                        height: 6.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                      ),
                    ),
                    Container(
                        child: TextFormField(
                            controller: _titleCtrl,
                            style: TextStyle(
                                fontSize:
                                    14 * _themeProvider.userFontSize / 0.8,
                                color: Theme.of(context).primaryColorLight),
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                                filled: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 3),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 3),
                                ),
                                hintText: "제안의 제목을 작성해 보세요",
                                hintStyle: TextStyle(
                                    fontSize:
                                        14 * _themeProvider.userFontSize / 0.8,
                                    color: Theme.of(context).primaryColorDark)),
                            onChanged: (text) {})),
                    SizedBox(height: 12),
                    Container(
                        child: TextFormField(
                            controller: _contentCtrl,
                            style: TextStyle(
                                fontSize:
                                    14 * _themeProvider.userFontSize / 0.8,
                                color: Theme.of(context).primaryColorLight),
                            textAlign: TextAlign.start,
                            minLines: 4,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                                filled: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 3),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 3),
                                ),
                                hintText: "자세한 내용을 작성해 보세요",
                                hintStyle: TextStyle(
                                    fontSize:
                                        14 * _themeProvider.userFontSize / 0.8,
                                    color: Theme.of(context).primaryColorDark)),
                            onChanged: (text) {})),
                    SizedBox(height: 8.0),
                    Consumer<InterviewdataProvider>(
                        builder: (context, provider, child) {
                      return Container(
                        child: Wrap(
                          children: _tagsList.map(
                            (tag) {
                              bool isSelected = false;
                              if (_interviewProvider.selectedTags!
                                  .contains(tag)) {
                                isSelected = true;
                              }
                              return GestureDetector(
                                onTap: () {
                                  if (!_interviewProvider.selectedTags!
                                      .contains(tag)) {
                                    _interviewProvider.addTag(tag);
                                  } else {
                                    _interviewProvider.removeTag(tag);
                                  }
                                },
                                child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 4),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 12),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).buttonColor,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                              color: isSelected
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Theme.of(context)
                                                      .primaryColorDark,
                                              width: 1)),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context)
                                                    .primaryColorDark,
                                            fontSize: 14 *
                                                _themeProvider.userFontSize /
                                                0.8),
                                      ),
                                    )),
                              );
                            },
                          ).toList(),
                        ),
                      );
                    }),
                    Column(
                      children: [
                        Container(
                          child: Text('의견 주심에 감사합니다🤗 소중한 의견으로 발전해볼게요!',
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark)),
                        ),
                        Container(
                          child: Text('삭제 및 수정이 안됨을 양해 부탁드려요🙏',
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark)),
                        ),
                      ],
                    ),
                  ],
                ),
                _submitConfirmButton()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _submitConfirmButton() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
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
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (_titleCtrl.text == "" || _contentCtrl.text == "") {
                showToast("제목과 내용을 확인 부탁드려요!");
              } else {
                InterviewPost(
                        user_email: _userProvider.userdata.email,
                        user_nickname: _userProvider.userdata.email,
                        title: _titleCtrl.text,
                        content: _contentCtrl.text,
                        tags: _interviewProvider.selectedTags)
                    .postinterview()
                    .then((value) => {
                          _interviewProvider.getinterviewdataFirst(),
                          Navigator.pop(context),
                          _titleCtrl.clear(),
                          _interviewProvider.initTags(),
                          _contentCtrl.clear(),
                        });
              }
            },
            child: Text("제안하기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).buttonColor))));
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
