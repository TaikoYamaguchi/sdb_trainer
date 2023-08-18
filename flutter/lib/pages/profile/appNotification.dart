import 'package:cached_network_image/cached_network_image.dart';
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
  var _tapPosition;
  var _isCommentInputOpen = false;
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
            _userProvider.userdata.is_superuser
                ? GestureDetector(
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
                    ))
                : Container(),
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
        int length;
        var afterparse = parse(notificationdata.content.html);
        var body = afterparse.getElementsByTagName("body")[0];
        length = body.getElementsByTagName("p").length;
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
                                onTapDown: _storePosition,
                                onTap: () {
                                  _userProvider.userdata.is_superuser
                                  ? _myInterviewMenu(notificationdata, setState)
                                  : null;

                                },
                                child: const Icon(Icons.more_vert,
                                    color: Colors.grey, size: 18.0))
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                  physics: const ScrollPhysics(),
                                  itemBuilder: (BuildContext _context, int index) {
                                    return body.getElementsByTagName("p")[index].getElementsByTagName("img").length != 0
                                        ? CachedNetworkImage(
                                        imageUrl: notificationdata.images![int.parse(body.getElementsByTagName("p")[index].getElementsByTagName("img")[0].attributes["src"]!)],
                                        imageBuilder:
                                            (context, imageProivder) =>
                                            Container(
                                              height: MediaQuery.of(context).size.width-20,
                                              width: MediaQuery.of(context).size.width-20,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(20)),
                                                  image: DecorationImage(
                                                    image: imageProivder,
                                                    fit: BoxFit.cover,
                                                  )),
                                            ))
                                        : Text(body.getElementsByTagName("p")[index].text,
                                        textScaleFactor: 1.5,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight));

                                  },
                                  shrinkWrap: true,
                                  itemCount: length
                              ),
                            )),

                        const SizedBox(height: 4.0),
                        Column(
                          children: [
                            Text('Supero를 사랑해 주심에 감사합니다🤗',
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

              ],
            ),
          );
        }));
      },
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Future<dynamic> _myInterviewMenu(
      mnoti.Notification notificationdata, StateSetter setState) {
    return showMenu(
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
                title: Text("No-Show",
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight)),
                onTap: () async {
                  notificationdata.ispopup = false;
                  _notificationprovider.editdata(notificationdata);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }))


      ],
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
