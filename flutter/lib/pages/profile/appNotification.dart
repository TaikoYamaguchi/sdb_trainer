import 'package:flutter/material.dart';
import 'package:sdb_trainer/providers/notification.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/src/utils/firebase_fcm.dart';
import 'dart:async';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:permission_handler/permission_handler.dart';

class AppNotification extends StatefulWidget {
  AppNotification({Key? key}) : super(key: key);

  @override
  _AppNotificationState createState() => _AppNotificationState();
}

class _AppNotificationState extends State<AppNotification> {
  var _themeProvider;
  var _userProvider;
  var _notificationprovider;
  var _final_interview_id;
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _notificationprovider = Provider.of<NotificationdataProvider>(context, listen: false);
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
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Future<void> _onRefresh() {
    setState(() {
      _notificationprovider.getdata();
    });
    return Future<void>.value();
  }

  Widget _AppNotificationWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child:
      Consumer<NotificationdataProvider>(builder: (builder, provider, child) {
        var _notificationDatas = provider.notificationdata != null
            ? provider.notificationdata
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
                                  SizedBox(
                                    width: 40,
                                    child: _notificationDatas[index]
                                        .progress ==
                                        "open"
                                        ? const Icon(
                                      Icons
                                          .radio_button_unchecked,
                                      color: Color(0xFF26A943),
                                      size: 28,
                                    )
                                        : _notificationDatas[index]
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
                                                Container(
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        right: 4.0),
                                                    child: Text(
                                                      _notificationDatas[
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
                                                  text: _notificationDatas[
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
                                                        _notificationDatas[
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
                                                  _notificationDatas[index]
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
                                                  _notificationDatas[
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
                      itemCount: _notificationDatas.length),
                ],
              ),
            ))
            : const Center(child: CircularProgressIndicator())
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  /*
  Widget _AppNotificationWidget() {
    bool btnDisabled = false;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onPanUpdate: (details) {
          if (details.delta.dx > 10 && btnDisabled == false) {
            btnDisabled = true;
            Navigator.of(context).pop();
            print("Dragging in +X direction");
          }
        },
        child: SingleChildScrollView(
          child: Column(children: [
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).cardColor)),
              child:
              Consumer<PrefsProvider>(builder: (builder, provider, child) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    color: Theme.of(context).cardColor,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("댓글 알람 받기",
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          SizedBox(
                            width: 100,
                            child: CustomSlidingSegmentedControl(
                                initialValue: provider.commentNotification!,
                                height: 24.0,
                                children: {
                                  true: Text("on",
                                      style: TextStyle(
                                          color: provider.commentNotification!
                                              ? Theme.of(context).highlightColor
                                              : Theme.of(context)
                                              .primaryColorLight)),
                                  false: Text("off",
                                      style: TextStyle(
                                          color: provider.commentNotification!
                                              ? Theme.of(context)
                                              .primaryColorLight
                                              : Theme.of(context)
                                              .highlightColor))
                                },
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(context).canvasColor),
                                innerPadding: const EdgeInsets.all(4),
                                thumbDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(context).primaryColor),
                                onValueChanged: (bool value) {
                                  if (!provider.systemNotification!) {
                                    openAppSettings();
                                  }
                                  provider.setAlarmPrefs(value);
                                  fcmSetting();
                                }),
                          )
                        ]));
              }),
            ),
          ]),
        ));
  }

   */

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
