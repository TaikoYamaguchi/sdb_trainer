import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:sdb_trainer/pages/profile/htmlEditor_Notification.dart';
import 'package:sdb_trainer/providers/notification.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/model/notification.dart' as mnoti;
import 'dart:async';

import 'package:transition/transition.dart';

class AppNotification extends StatefulWidget {
  AppNotification({Key? key}) : super(key: key);

  @override
  _AppNotificationState createState() => _AppNotificationState();
}

class _AppNotificationState extends State<AppNotification> {
  var _userProvider;
  var _PopProvider;
  var _notificationprovider;
  final _scrollController = ScrollController();
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _PopProvider=Provider.of<PopProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _notificationprovider = Provider.of<NotificationdataProvider>(context, listen: false);
    _onRefresh();
    return Consumer<PopProvider>(builder: (Builder, provider, child) {
      bool _popable = provider.isprostacking;
      _popable == false
          ? null
          : [
        provider.profilestackdown(),
        provider.propopoff(),
        Future.delayed(Duration.zero, () async {
          Navigator.of(context).pop();
        })
      ];
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appbarWidget(),
        body: _AppNotificationWidget(),
      );
    });
  }

  PreferredSizeWidget _appbarWidget() {
    var _btnDisabled = false;
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              _btnDisabled == true
                  ? null
                  : [
                Navigator.of(context).pop(),
                _btnDisabled = true,
              ];
            },
          ),
          title: Text(
            "공지사항",
            textScaleFactor: 1.5,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          actions: [
            GestureDetector(
                onTap: () {
                  _PopProvider.profilestackup();
                  Navigator.push(
                      context,
                      Transition(
                          child: NotificationHtmlEditor(),
                          transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.open_in_new,
                      size: 28, color: Theme.of(context).primaryColor),
                )),
          ],
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Future<void> _onRefresh() {
    print("here?");
    setState(() {
      _notificationprovider.getdata();
    });
    return Future<void>.value();
  }

  Widget _AppNotificationWidget() {
    //print(_notificationprovider.notificationdata.notifications[0].content.html);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child:
      Consumer<NotificationdataProvider>(builder: (builder, provider, child) {
        var _notificationDatas = provider.notificationdata != null
            ? provider.notificationdata.notifications
            : [];
        return _userProvider.userdata != null
            ? provider.notificationdata != null
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
                                  '''공지를 참고해주세요''',
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
                        controller: _scrollController,
                        itemBuilder: (BuildContext _context, int index) {
                          if (index < _notificationDatas.length) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {

                                          _showNotificationDetailBottomSheet(_notificationDatas[index]);


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
                                                      _notificationDatas[
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
                                                        _notificationDatas[
                                                        index]
                                                            .date.substring(
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
                                                    text: _notificationDatas[
                                                    index].content.html,
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
                                                          _notificationDatas[
                                                          index]
                                                              .content.html,
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
                                                    _notificationDatas[index]
                                                        .content.html,
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
                        itemCount: _notificationDatas.length+1),
                  ],
                ),
              ))
              : const Center(child: CircularProgressIndicator())
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  void _showNotificationDetailBottomSheet(mnoti.Notification notificationdata) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        var afterparse = parse(notificationdata.content.html);
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                /*
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

                                 */
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notificationdata.title,
                                        textScaleFactor: 1.8,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                      ),
                                      Text(
                                        notificationdata.date!.substring(2, 10),
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
                                //onTapDown: _storePosition,
                                onTap: () {
                                  /*
                                  interviewData.user_email ==
                                      _userProvider.userdata.email
                                      ? _myInterviewMenu(
                                      true, interviewData, setState)
                                      : _myInterviewMenu(
                                      false, interviewData, setState);

                                   */
                                },
                                child: const Icon(Icons.more_vert,
                                    color: Colors.grey, size: 18.0))
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              color: Theme.of(context).canvasColor,
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(afterparse.children[0].innerHtml,
                                    textScaleFactor: 0.8,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColorLight)),
                              ),
                            )),

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
                        //_commentContent(interviewData),
                      ],
                    ),
                  ),
                ),
                /*
                Column(
                  children: [
                    _isCommentInputOpen
                        ? _commentTextInput(interviewData, setState)
                        : Container(),
                    _closeInterviewDetailButton()
                  ],
                ),

                 */
              ],
            ),
          );
        }));
      },
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
