import 'package:flutter/material.dart';
import 'package:sdb_trainer/pages/profile/htmlEditor_Notification.dart';
import 'package:sdb_trainer/providers/notification.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userdata.dart';
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
    print(_notificationprovider.notificationdata.notifications[0].content.html);
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
                                          /*
                                          _showInterviewDetailBottomSheet(
                                              _notificationDatas[index]);

                                           */
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
                                                  /*
                                                  Container(
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          right: 4.0),
                                                      child: Text(
                                                        _notificationDatas[
                                                        index]
                                                            .date,
                                                        textScaleFactor:
                                                        1.0,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                context)
                                                                .primaryColorDark),
                                                      ),
                                                    ),
                                                  ),

                                                   */
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
