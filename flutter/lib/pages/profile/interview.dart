import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/feed/friendProfile.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/interviewdata.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/comment_repository.dart';
import 'package:sdb_trainer/repository/interview_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/model/historydata.dart';
import 'package:sdb_trainer/src/model/interviewdata.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Interview extends StatefulWidget {
  Interview({Key? key}) : super(key: key);

  @override
  State<Interview> createState() => _InterviewState();
}

class _InterviewState extends State<Interview> {
  var _userProvider;
  var _interviewProvider;
  var _historyProvider;
  final _pageController = ScrollController();
  var _final_interview_id;
  var _themeProvider;
  var _hasMore = true;
  final TextEditingController _commentInputCtrl =
      TextEditingController(text: "");
  var _tapPosition;
  final List<String> _tagsList = [
    '버그',
    '기능 개선',
    '질문',
    '기타',
  ];

  var _isCommentInputOpen = false;

  final TextEditingController _titleCtrl = TextEditingController(text: "");
  final TextEditingController _contentCtrl = TextEditingController(text: "");

  final binding = WidgetsFlutterBinding.ensureInitialized();
  @override
  void initState() {
    super.initState();
    _tapPosition = const Offset(0.0, 0.0);
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
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _interviewProvider =
        Provider.of<InterviewdataProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _historyProvider = Provider.of<HistorydataProvider>(context, listen: false);

    bool btnDisabled = false;
    return Scaffold(
        extendBody: true,
        appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(40.0), // here the desired height
            child: AppBar(
              elevation: 0,
              leading: IconButton(
                color: Theme.of(context).primaryColorLight,
                icon: const Icon(Icons.arrow_back_ios_outlined),
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
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                ],
              ),
              actions: [
                GestureDetector(
                    onTap: () {
                      _showInterviewPostBottomSheet();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.open_in_new,
                          size: 28, color: Theme.of(context).primaryColor),
                    )),
              ],
              backgroundColor: Theme.of(context).canvasColor,
            )),
        body: GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dx > 10 && btnDisabled == false) {
                btnDisabled = true;
                Navigator.of(context).pop();
                print("Dragging in +X direction");
              }
            },
            child: SizedBox(
                height: double.infinity, child: _interviewCardList(context))));
  }

  Future<void> _onRefresh() {
    setState(() {
      _interviewProvider.getInterviewdataFirst();
    });
    return Future<void>.value();
  }

  Widget _interviewCardList(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child:
          Consumer<InterviewdataProvider>(builder: (builder, provider, child) {
        var _interviewDatas = provider.interviewdataAll != null
            ? provider.interviewdataAll.interviewDatas
            : [];
        return _userProvider.userdata != null
            ? provider.interviewdataAll != null
                ? RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '''필요한 부분을 마음껏 알려주세요\nSupero는 여러분의 의견을 좋아해요👏''',
                                        textScaleFactor: 1.4,
                                        style: TextStyle(
                                            height: 1.5,
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ListView.separated(
                              controller: _pageController,
                              itemBuilder: (BuildContext _context, int index) {
                                if (index < _interviewDatas.length) {
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            child: _interviewDatas[index]
                                                        .progress ==
                                                    "open"
                                                ? const Icon(
                                                    Icons
                                                        .radio_button_unchecked,
                                                    color: Color(0xFF26A943),
                                                    size: 28,
                                                  )
                                                : _interviewDatas[index]
                                                            .progress ==
                                                        "closed"
                                                    ? Icon(
                                                        Icons
                                                            .radio_button_checked,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: 28)
                                                    : Icon(
                                                        Icons
                                                            .radio_button_checked,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: 28),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                _showInterviewDetailBottomSheet(
                                                    _interviewDatas[index]);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            _interviewDatas[
                                                                    index]
                                                                .title,
                                                            textAlign:
                                                                TextAlign.start,
                                                            textScaleFactor:
                                                                1.5,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            maxLines: 1,
                                                            softWrap: false,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorLight),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 4.0),
                                                            child: Text(
                                                              _interviewDatas[
                                                                      index]
                                                                  .date
                                                                  .substring(
                                                                      2, 10),
                                                              textScaleFactor:
                                                                  1.0,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    LayoutBuilder(builder:
                                                        (context, constraints) {
                                                      final span = TextSpan(
                                                          text: _interviewDatas[
                                                                  index]
                                                              .content,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark));
                                                      final tp = TextPainter(
                                                          text: span,
                                                          maxLines: 2,
                                                          textDirection:
                                                              TextDirection
                                                                  .ltr);
                                                      tp.layout(
                                                          maxWidth: constraints
                                                              .maxWidth);
                                                      if (tp
                                                          .didExceedMaxLines) {
                                                        // TODO: display the prompt message
                                                        return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                _interviewDatas[
                                                                        index]
                                                                    .content,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textScaleFactor:
                                                                    1.1,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorDark),
                                                              ),
                                                              Text(
                                                                "더 보기",
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textScaleFactor:
                                                                    0.9,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorDark),
                                                              )
                                                            ]);
                                                      } else {
                                                        return Text(
                                                          _interviewDatas[index]
                                                              .content,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textScaleFactor: 1.1,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                        );
                                                      }
                                                    }),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      child: Wrap(
                                                          children:
                                                              _interviewDatas[
                                                                      index]
                                                                  .tags
                                                                  .map<Widget>(
                                                        (tag) {
                                                          bool isSelected =
                                                              true;

                                                          return GestureDetector(
                                                            onTap: () {},
                                                            child: Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        4,
                                                                    vertical:
                                                                        2),
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          8),
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(context).canvasColor,
                                                                      borderRadius: BorderRadius.circular(18),
                                                                      border: Border.all(
                                                                          color: isSelected
                                                                              ? Theme.of(context).primaryColor
                                                                              // ignore: dead_code
                                                                              : Theme.of(context).primaryColorDark,
                                                                          width: 1.5)),
                                                                  child: Text(
                                                                    tag,
                                                                    style: TextStyle(
                                                                        color: isSelected
                                                                            ? Theme.of(context).primaryColor
                                                                            // ignore: dead_code
                                                                            : Theme.of(context).primaryColorDark,
                                                                        fontSize: 12 * _themeProvider.userFontSize / 0.8),
                                                                  ),
                                                                )),
                                                          );
                                                        },
                                                      ).toList()),
                                                    ),
                                                    Divider(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        thickness: 0.3)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (_interviewDatas.length == 0) {
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Center(
                                          child: Text("기능을 제안해주세요",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorLight))));
                                } else {
                                  _final_interview_id =
                                      _interviewDatas[index - 1].id;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: Center(
                                        child: _hasMore
                                            ? const CircularProgressIndicator()
                                            : Text("기능을 제안해주세요",
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
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                );
                              },
                              shrinkWrap: true,
                              itemCount: _interviewDatas.length + 1),
                        ],
                      ),
                    ))
                : const Center(child: CircularProgressIndicator())
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  void _showInterviewDetailBottomSheet(InterviewData interviewData) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        User user = _userProvider.userFriendsAll.userdatas
            .where((user) => user.email == interviewData.user_email)
            .toList()[0];
        return GestureDetector(onTap: () {
          FocusScope.of(context).unfocus();
        }, child: StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return Container(
            padding: const EdgeInsets.all(12.0),
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Container(
                    height: 6.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0))),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                Transition(
                                    child: FriendProfile(user: user),
                                    transitionEffect:
                                        TransitionEffect.RIGHT_TO_LEFT));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  user.image == ""
                                      ? const Icon(
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
                                                    const BorderRadius.all(
                                                        Radius.circular(50)),
                                                image: DecorationImage(
                                                  image: imageProivder,
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          interviewData.user_nickname,
                                          textScaleFactor: 1.5,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight),
                                        ),
                                        Text(
                                          interviewData.date!.substring(2, 10),
                                          textScaleFactor: 1.0,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                  onTapDown: _storePosition,
                                  onTap: () {
                                    interviewData.user_email ==
                                            _userProvider.userdata.email
                                        ? _myInterviewMenu(
                                            true, interviewData, setState)
                                        : _myInterviewMenu(
                                            false, interviewData, setState);
                                  },
                                  child: const Icon(Icons.more_vert,
                                      color: Colors.grey, size: 18.0))
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: interviewData.progress == "open"
                              ? Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.radio_button_unchecked,
                                        color: Color(0xFF26A943),
                                        size: 28,
                                      ),
                                      Text(" 진행 중",
                                          style: TextStyle(
                                              fontSize: 16 *
                                                  _themeProvider.userFontSize /
                                                  0.8,
                                              color: const Color(0xFF26A943)))
                                    ],
                                  ),
                                )
                              : interviewData.progress == "closed"
                                  ? Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.radio_button_checked,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 28,
                                          ),
                                          Text(" 진행 완료",
                                              style: TextStyle(
                                                  fontSize: 16 *
                                                      _themeProvider
                                                          .userFontSize /
                                                      0.8,
                                                  color: Theme.of(context)
                                                      .primaryColor))
                                        ],
                                      ),
                                    )
                                  : Icon(Icons.radio_button_checked,
                                      color: Theme.of(context).primaryColor,
                                      size: 28),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              color: Theme.of(context).canvasColor,
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(interviewData.title,
                                    style: TextStyle(
                                        fontSize: 16 *
                                            _themeProvider.userFontSize /
                                            0.8,
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                              ),
                            )),
                        const SizedBox(height: 4),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              color: Theme.of(context).cardColor,
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(interviewData.content,
                                    style: TextStyle(
                                        fontSize: 13 *
                                            _themeProvider.userFontSize /
                                            0.8,
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                              ),
                            )),
                        const SizedBox(height: 4.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Wrap(
                              children: interviewData.tags!.map<Widget>(
                            (tag) {
                              bool isSelected = true;

                              return GestureDetector(
                                onTap: () {},
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 8),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).canvasColor,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                              color: isSelected
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  // ignore: dead_code
                                                  : Theme.of(context)
                                                      .primaryColorDark,
                                              width: 1.5)),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                // ignore: dead_code
                                                : Theme.of(context)
                                                    .primaryColorDark,
                                            fontSize: 12 *
                                                _themeProvider.userFontSize /
                                                0.8),
                                      ),
                                    )),
                              );
                            },
                          ).toList()),
                        ),
                        Consumer<InterviewdataProvider>(
                            builder: (context, provider, child) {
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("공감하기",
                                        textScaleFactor: 1.5,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark)),
                                    _interviewLikeButton(interviewData),
                                  ],
                                ),
                              ));
                        }),
                        const SizedBox(height: 4.0),
                        Column(
                          children: [
                            Text('의견 주심에 감사합니다🤗 소중한 의견으로 발전해볼게요!',
                                textScaleFactor: 1.2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark)),
                          ],
                        ),
                        _commentContent(interviewData),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    _isCommentInputOpen
                        ? _commentTextInput(interviewData, setState)
                        : Container(),
                    _closeInterviewDetailButton()
                  ],
                ),
              ],
            ),
          );
        }));
      },
    );
  }

  Widget _closeInterviewDetailButton() {
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
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("닫기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  Future<dynamic> _myInterviewMenu(
      bool isMe, InterviewData interviewData, StateSetter setState) {
    return isMe
        ? showMenu(
            context: context,
            position: RelativeRect.fromRect(_tapPosition & const Size(30, 30),
                Offset.zero & const Size(0, 0)),
            items: [
              PopupMenuItem(
                  child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 0.0),
                      leading: Icon(Icons.delete,
                          color: Theme.of(context).primaryColorLight),
                      title: Text("삭제",
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                      onTap: () async {
                        InterviewDelete(interview_id: interviewData.id)
                            .deleteInterview();
                        _interviewProvider
                            .deleteInterviewdata(interviewData.id);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      })),
              PopupMenuItem(
                  child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 0.0),
                      leading: Icon(Icons.open_in_new,
                          color: Theme.of(context).primaryColorLight),
                      title: Text(_isCommentInputOpen ? "댓글 닫기" : "댓글 열기",
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                      onTap: () async {
                        _isCommentInputOpen
                            ? setState(() {
                                _isCommentInputOpen = false;
                                Navigator.of(context).pop();
                              })
                            : setState(() {
                                _isCommentInputOpen = true;
                                Navigator.of(context).pop();
                              });
                      })),
              _userProvider.userdata.is_superuser
                  ? PopupMenuItem(
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 0.0),
                          leading: Icon(Icons.open_in_new,
                              color: Theme.of(context).primaryColorLight),
                          title: Text(
                              interviewData.progress == "open"
                                  ? "완료 수정"
                                  : "진행 수정",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          onTap: () async {
                            interviewData.progress == "open"
                                ? {
                                    InterviewManage(
                                      interview_id: interviewData.id,
                                      user_email: _userProvider.userdata.email,
                                      status: "closed",
                                    ).patchInterviewStatus(),
                                    _interviewProvider.patchInterviewStatusdata(
                                        interviewData,
                                        _userProvider.userdata.email,
                                        "closed"),
                                    Navigator.pop(context),
                                    Navigator.pop(context)
                                  }
                                : {
                                    InterviewManage(
                                      interview_id: interviewData.id,
                                      user_email: _userProvider.userdata.email,
                                      status: "open",
                                    ).patchInterviewStatus(),
                                    _interviewProvider.patchInterviewStatusdata(
                                        interviewData,
                                        _userProvider.userdata.email,
                                        "open"),
                                    Navigator.pop(context),
                                    Navigator.pop(context)
                                  };
                          }))
                  : PopupMenuItem(
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 0.0),
                          leading: Icon(Icons.open_in_new,
                              color: Theme.of(context).primaryColorLight),
                          title: Text(
                              interviewData.progress == "open" ? "완료" : "진행",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          onTap: () async {}))
            ],
          )
        : showMenu(
            context: context,
            position: RelativeRect.fromRect(_tapPosition & const Size(30, 30),
                Offset.zero & const Size(0, 0)),
            items: [
              PopupMenuItem(
                  child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 0.0),
                      leading: Icon(Icons.open_in_new,
                          color: Theme.of(context).primaryColorLight),
                      title: Text(_isCommentInputOpen ? "댓글 닫기" : "댓글 열기",
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                      onTap: () async {
                        _isCommentInputOpen
                            ? setState(() {
                                _isCommentInputOpen = false;
                                Navigator.of(context).pop();
                              })
                            : setState(() {
                                _isCommentInputOpen = true;
                                Navigator.of(context).pop();
                              });
                      })),
              _userProvider.userdata.is_superuser == true
                  ? PopupMenuItem(
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 0.0),
                          leading: Icon(Icons.open_in_new,
                              color: Theme.of(context).primaryColorLight),
                          title: Text(
                              interviewData.progress == "open"
                                  ? "완료 수정"
                                  : "진행 수정",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          onTap: () async {
                            interviewData.progress == "open"
                                ? {
                                    InterviewManage(
                                      interview_id: interviewData.id,
                                      user_email: _userProvider.userdata.email,
                                      status: "closed",
                                    ).patchInterviewStatus(),
                                    _interviewProvider.patchInterviewStatusdata(
                                        interviewData,
                                        _userProvider.userdata.email,
                                        "closed"),
                                    Navigator.pop(context),
                                    Navigator.pop(context)
                                  }
                                : {
                                    InterviewManage(
                                      interview_id: interviewData.id,
                                      user_email: _userProvider.userdata.email,
                                      status: "open",
                                    ).patchInterviewStatus(),
                                    _interviewProvider.patchInterviewStatusdata(
                                        interviewData,
                                        _userProvider.userdata.email,
                                        "open"),
                                    Navigator.pop(context),
                                    Navigator.pop(context)
                                  };
                          }))
                  : PopupMenuItem(
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 0.0),
                          leading: Icon(Icons.open_in_new,
                              color: Theme.of(context).primaryColorLight),
                          title: Text(
                              interviewData.progress == "open" ? "완료" : "진행",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          onTap: () async {}))
            ],
          );
  }

  void _showInterviewPostBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: const EdgeInsets.all(12.0),
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: Container(
                        height: 6.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0))),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                                child: TextFormField(
                                    controller: _titleCtrl,
                                    style: TextStyle(
                                        fontSize: 14 *
                                            _themeProvider.userFontSize /
                                            0.8,
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                        filled: true,
                                        enabledBorder: UnderlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 3),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 3),
                                        ),
                                        hintText: "제안의 제목을 작성해 보세요",
                                        hintStyle: TextStyle(
                                            fontSize: 14 *
                                                _themeProvider.userFontSize /
                                                0.8,
                                            color: Theme.of(context)
                                                .primaryColorDark)),
                                    onChanged: (text) {})),
                            const SizedBox(height: 12),
                            Container(
                                child: TextFormField(
                                    controller: _contentCtrl,
                                    style: TextStyle(
                                        fontSize: 14 *
                                            _themeProvider.userFontSize /
                                            0.8,
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    textAlign: TextAlign.start,
                                    minLines: 4,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        filled: true,
                                        enabledBorder: UnderlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 3),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 3),
                                        ),
                                        hintText: "자세한 내용을 작성해 보세요",
                                        hintStyle: TextStyle(
                                            fontSize: 14 *
                                                _themeProvider.userFontSize /
                                                0.8,
                                            color: Theme.of(context)
                                                .primaryColorDark)),
                                    onChanged: (text) {})),
                            const SizedBox(height: 8.0),
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
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 4),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 12),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  border: Border.all(
                                                      color: isSelected
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .primaryColorDark,
                                                      width: 1.5)),
                                              child: Text(
                                                tag,
                                                style: TextStyle(
                                                    color: isSelected
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .primaryColorDark,
                                                    fontSize: 14 *
                                                        _themeProvider
                                                            .userFontSize /
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
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                                ),
                                Container(
                                  child: Text('삭제 및 수정이 안됨을 양해 부탁드려요🙏',
                                      textScaleFactor: 1.2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              if (_titleCtrl.text == "" || _contentCtrl.text == "") {
                showToast("제목과 내용을 확인 부탁드려요!");
              } else {
                InterviewPost(
                        user_email: _userProvider.userdata.email,
                        user_nickname: _userProvider.userdata.nickname,
                        title: _titleCtrl.text,
                        content: _contentCtrl.text,
                        tags: _interviewProvider.selectedTags)
                    .postInterview()
                    .then((value) => {
                          _interviewProvider.getInterviewdataFirst(),
                          Navigator.pop(context),
                          _titleCtrl.clear(),
                          _interviewProvider.initTags(),
                          _contentCtrl.clear(),
                        });
              }
            },
            child: Text("제안하기",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  Widget _interviewLikeButton(interviewData) {
    var buttonSize = 24.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: LikeButton(
        size: buttonSize,
        isLiked: onIsLikedCheck(interviewData),
        circleColor:
            const CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
        bubblesColor: const BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return Icon(Icons.favorite,
              color: isLiked
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColorDark,
              size: buttonSize);
        },
        onTap: (bool isLiked) async {
          return onLikeButtonTapped(isLiked, interviewData);
        },
        likeCount: interviewData.like.length,
        countBuilder: (int? count, bool isLiked, String text) {
          var color = isLiked
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColorDark;
          Widget result;
          if (count == 0) {
            result = Text(
              text,
              textScaleFactor: 1.3,
              style: TextStyle(color: color),
            );
          } else
            result = Text(
              text,
              textScaleFactor: 1.3,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            );
          return result;
        },
      ),
    );
  }

  bool onIsLikedCheck(interviewData) {
    if (interviewData.like.contains(_userProvider.userdata.email)) {
      return true;
    } else {
      return false;
    }
  }

  bool onLikeButtonTapped(bool isLiked, interviewData) {
    if (isLiked == true) {
      InterviewLike(
              interview_id: interviewData.id,
              user_email: _userProvider.userdata.email,
              status: "remove",
              disorlike: "like")
          .patchInterviewLike();
      _interviewProvider.patchInterviewLikedata(
          interviewData, _userProvider.userdata.email, "remove");
      return false;
    } else {
      InterviewLike(
              interview_id: interviewData.id,
              user_email: _userProvider.userdata.email,
              status: "append",
              disorlike: "like")
          .patchInterviewLike();
      _interviewProvider.patchInterviewLikedata(
          interviewData, _userProvider.userdata.email, "append");
      return !isLiked;
    }
  }

  Widget _commentContent(InterviewData) {
    var _commentListbyId = _historyProvider.commentAll.comments
        .where((comment) => comment.reply_id == InterviewData.id)
        .toList();
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext _context, int index) {
          return Padding(
              padding: const EdgeInsets.all(4.0),
              child: _commentContentCore(_commentListbyId[index]));
        },
        separatorBuilder: (BuildContext _context, int index) {
          return Container(
            alignment: Alignment.center,
            height: 0.3,
            child: Container(
              alignment: Alignment.center,
              height: 0.3,
              color: Theme.of(context).primaryColorDark,
            ),
          );
        },
        itemCount: _commentListbyId.length);
  }

  Widget _commentContentCore(Comment) {
    User user = _userProvider.userFriendsAll.userdatas
        .where((user) => user.email == Comment.writer_email)
        .toList()[0];
    return _userProvider.userdata.dislike.contains(Comment.writer_email)
        ? Container(
            child: const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text("차단된 사용자 입니다",
                    textScaleFactor: 1.0,
                    style: TextStyle(color: Colors.grey))))
        : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    user.image == ""
                        ? const Icon(
                            Icons.account_circle,
                            color: Colors.grey,
                            size: 38.0,
                          )
                        : CachedNetworkImage(
                            imageUrl: user.image,
                            imageBuilder: (context, imageProivder) => Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
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
                                textScaleFactor: 1.0,
                                style: const TextStyle(color: Colors.grey)),
                            Text(Comment.content,
                                textScaleFactor: 1.1,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).primaryColorLight)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTapDown: _storePosition,
              onTap: () {
                _userProvider.userdata.email == Comment.writer_email
                    ? showMenu(
                        context: context,
                        position: RelativeRect.fromRect(
                            _tapPosition & const Size(30, 30),
                            Offset.zero & const Size(0, 0)),
                        items: [
                            PopupMenuItem(
                                onTap: () {
                                  _historyProvider.deleteCommentAll(Comment);
                                  Future<void>.delayed(
                                      const Duration(), // OR const Duration(milliseconds: 500),
                                      () =>
                                          CommentDelete(comment_id: Comment.id)
                                              .deleteComment());
                                },
                                padding: const EdgeInsets.all(0.0),
                                child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 0.0),
                                    leading: Icon(Icons.delete,
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    title: Text("삭제",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight)))),
                          ])
                    : showMenu(
                        context: context,
                        position: RelativeRect.fromRect(
                            _tapPosition & const Size(30, 30),
                            Offset.zero & const Size(0, 0)),
                        items: [
                            PopupMenuItem(
                                onTap: () {
                                  Future<void>.delayed(
                                      const Duration(), // OR const Duration(milliseconds: 500),
                                      () => _displayDislikeAlert(
                                          Comment.writer_email));
                                },
                                padding: const EdgeInsets.all(0.0),
                                child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 0.0),
                                    leading: Icon(Icons.remove_circle_outlined,
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    title: Text("신고",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight)))),
                          ]);
              },
              child: const Icon(
                Icons.more_vert,
                color: Colors.grey,
                size: 18.0,
              ),
            )
          ]);
  }

  Widget _commentTextInput(Interview, StateSetter setState) {
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              controller: _commentInputCtrl,
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight, fontSize: 12.0),
              decoration: InputDecoration(
                hintText: "댓글 신고시 이용이 제한 될 수 있습니다.",
                hintStyle: TextStyle(
                    color: Theme.of(context).primaryColorLight, fontSize: 12.0),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColorLight, width: 0.3),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColorLight, width: 0.3),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            child: Icon(Icons.arrow_upward,
                color: Theme.of(context).primaryColorLight),
            onTap: () {
              _historyProvider.addCommentAll(Comment(
                  history_id: 0,
                  reply_id: Interview.id,
                  writer_email: _userProvider.userdata.email,
                  writer_nickname: _userProvider.userdata.nickname,
                  content: _commentInputCtrl.text));
              CommentCreate(
                      history_id: 0,
                      reply_id: Interview.id,
                      writer_email: _userProvider.userdata.email,
                      writer_nickname: _userProvider.userdata.nickname,
                      content: _commentInputCtrl.text)
                  .postComment();
              _commentInputCtrl.clear();
              setState(() {
                _isCommentInputOpen = false;
              });
            },
          ),
        )
      ],
    );
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
                textScaleFactor: 2.0,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).primaryColorLight)),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('피드와 댓글을 모두 차단 할 수 있어요',
                      textScaleFactor: 1.3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                  const Text(
                    '친구 관리에서 다시 차단 해제 할 수 있어요',
                    textScaleFactor: 1.0,
                    style: TextStyle(color: Colors.grey),
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

  Widget _onDisLikeButtonTapped(email) {
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
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(12.0),
            ),
            onPressed: () {
              UserLike(
                      liked_email: email,
                      user_email: _userProvider.userdata.email,
                      status: "append",
                      disorlike: "dislike")
                  .patchUserLike();
              _userProvider.patchUserDislikedata(email, "append");

              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("차단하기",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
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
