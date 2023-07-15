import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/feed/feedEdit.dart';
import 'package:sdb_trainer/pages/feed/friendProfile.dart';
import 'package:sdb_trainer/pages/feed/friendHistory.dart';
import 'package:sdb_trainer/pages/feed/photo_editer.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/tempimagestorage.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/comment_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transition/transition.dart';
import 'package:like_button/like_button.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/model/userdata.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
import 'package:image/image.dart' as ui;

// ignore: must_be_immutable
class FeedCard extends StatefulWidget {
  final hisdata.SDBdata sdbdata;
  final int index;
  final int feedListCtrl;
  final bool openUserDetail;
  final bool isExEdit;
  final bool ad;

  const FeedCard(
      {Key? key,
      required this.sdbdata,
      required this.index,
      required this.feedListCtrl,
      required this.openUserDetail,
      required this.ad,
      this.isExEdit = false})
      : super(key: key);

  @override
  State<FeedCard> createState() => FeedCardState();
}

class FeedCardState extends State<FeedCard> {
  final GlobalKey repaintkey = GlobalKey();
  var _userProvider;
  var _historyProvider;
  var _commentListbyId;
  var _tempImgStrage;
  var _tapPosition;
  final TextEditingController _exEditCommentCtrl =
      TextEditingController(text: "");

  final PageController _controller =
      PageController(viewportFraction: 0.93, keepPage: true);
  final PageController _feedEditcontroller =
      PageController(viewportFraction: 0.93, keepPage: true);

  List<XFile> _image = [];
  final TextEditingController _commentInputCtrl =
      TextEditingController(text: "");
  var _popProvider;
  List<dynamic> _initImage = [];
  bool _focus = false;
  final _focusNode = FocusNode();
  int num_ad = 0;
  int ad_index = 0;
  NativeAd? myNative;

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

  late var _photoInfo = {"feedList": widget.feedListCtrl, "feedVisible": true};

  final ScrollController _commentScrollController = ScrollController();

  @override
  void initState() {
    _tapPosition = const Offset(0.0, 0.0);
    _exEditCommentCtrl.text = widget.sdbdata.comment ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _feedCard(widget.sdbdata, widget.index);
  }

  Widget _feedCard(SDBdata, index) {
    //(index+1)%5 == 0 ? _ad = true : _ad = false;
    //num_ad = ((index+1)/5).floor();
    //ad_index = index-num_ad;
    _tempImgStrage = Provider.of<TempImgStorage>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _historyProvider = Provider.of<HistorydataProvider>(context, listen: false);
    if (_historyProvider.commentAll != null) {
      _commentListbyId = _historyProvider.commentAll.comments
          .where((comment) => comment.history_id == SDBdata.id)
          .toList();
    } else {
      _commentListbyId = [];
    }
    _popProvider = Provider.of<PopProvider>(context, listen: false);
    User user = _userProvider.userFriendsAll.userdatas
        .where((user) => user.email == SDBdata.user_email)
        .toList()[0];

    return widget.ad
        ? Container(
            alignment: Alignment.center,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Card(
                color: Theme.of(context).cardColor,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    color: Theme.of(context).canvasColor,
                    height: 50.0,
                    child: AdWidget(
                      ad: BannerAd(
                        size: AdSize.banner,
                        adUnitId: UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
                        listener: BannerAdListener(
                          onAdFailedToLoad: (Ad ad, LoadAdError error) {},
                          onAdLoaded: (_) {},
                        ),
                        request: const AdRequest(),
                      )..load(),
                    ),
                  ),
                ),
              ),
            ),
          )
        : SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Consumer2<HistorydataProvider, UserdataProvider>(
                    builder: (builder, provider, provider2, child) {
                  var time_diff = DateTime.now()
                      .difference(DateTime.parse(SDBdata.date))
                      .inMinutes;
                  String time_calculate;
                  if (time_diff < 1) {
                    var time_diff = DateTime.now()
                        .difference(DateTime.parse(SDBdata.date))
                        .inSeconds;
                    time_calculate = "$time_diff초 전";
                  } else if (time_diff < 60) {
                    time_calculate = "$time_diff분 전";
                  } else if (time_diff < 1440) {
                    var time_diff = DateTime.now()
                        .difference(DateTime.parse(SDBdata.date))
                        .inHours;
                    time_calculate = "$time_diff시간 전";
                  } else {
                    time_calculate =
                        DateTime.now().toString().substring(2, 4) ==
                                SDBdata.date.substring(2, 4)
                            ? SDBdata.date.substring(5, 10)
                            : SDBdata.date.substring(2, 10);
                  }
                  return _userProvider.userdata.dislike.contains(user.email)
                      ? const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text("차단된 사용자 입니다",
                              textScaleFactor: 1.0,
                              style: TextStyle(color: Colors.grey)))
                      : RepaintBoundary(
                          key: repaintkey,
                          child: Card(
                            color: Theme.of(context).cardColor,
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            child: Column(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            widget.openUserDetail
                                                ? Navigator.push(
                                                    context,
                                                    Transition(
                                                        child: FriendProfile(
                                                            user: user),
                                                        transitionEffect:
                                                            TransitionEffect
                                                                .RIGHT_TO_LEFT))
                                                : null;
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              user.image == ""
                                                  ? const Icon(
                                                      Icons.account_circle,
                                                      color: Colors.grey,
                                                      size: 46.0,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: user.image,
                                                      imageBuilder: (context,
                                                              imageProivder) =>
                                                          Container(
                                                        height: 46,
                                                        width: 46,
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            50)),
                                                                image:
                                                                    DecorationImage(
                                                                  image:
                                                                      imageProivder,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )),
                                                      ),
                                                    ),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 6.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        SDBdata.nickname,
                                                        textScaleFactor: 1.6,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorLight),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 4.0),
                                                        child: Text(
                                                            time_calculate,
                                                            textScaleFactor:
                                                                1.1,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        widget.isExEdit
                                            ? _exercise_Done_appbar_Button()
                                            : GestureDetector(
                                                onTapDown: _storePosition,
                                                onTap: () {
                                                  SDBdata.user_email ==
                                                          _userProvider
                                                              .userdata.email
                                                      ? _myFeedMenu(SDBdata)
                                                      : _otherFeedMenu(SDBdata);
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(Icons.more_vert,
                                                      color: Colors.grey,
                                                      size: 20.0),
                                                ))
                                      ],
                                    )),
                                widget.isExEdit
                                    ? _commentWidget()
                                    : SDBdata.comment != ""
                                        ? _feedTextField(SDBdata.comment)
                                        : Container(),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "운동",
                                          textScaleFactor: 1.1,
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 50,
                                          child: Text("세트",
                                              textScaleFactor: 1.1,
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center)),
                                      SizedBox(
                                          width: 70,
                                          child: Text("1rm",
                                              textScaleFactor: 1.1,
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center))
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        Transition(
                                            child:
                                                FriendHistory(sdbdata: SDBdata),
                                            transitionEffect: TransitionEffect
                                                .RIGHT_TO_LEFT));
                                  },
                                  child: ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext _context, int index) {
                                        return Center(
                                            child: _exerciseWidget(
                                                SDBdata.exercises[index],
                                                index));
                                      },
                                      separatorBuilder:
                                          (BuildContext _context, int index) {
                                        return Container(
                                          alignment: Alignment.center,
                                          height: 0,
                                          color: Colors.black,
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 0,
                                            color: const Color(0xFF717171),
                                          ),
                                        );
                                      },
                                      itemCount: SDBdata.exercises.length),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 20.0, top: 15.0, bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SDBdata.isVisible == false
                                          ? const Text("숨겨진 피드",
                                              textScaleFactor: 1.1,
                                              style:
                                                  TextStyle(color: Colors.grey))
                                          : Container(),
                                      _feedPhotoButton(SDBdata),
                                      _feedLikeButton(SDBdata),
                                      _feedCommentButton(SDBdata)
                                    ],
                                  ),
                                ),
                                SDBdata.like.length != 0
                                    ? GestureDetector(
                                        onTap: () {
                                          _showLikeFreindBottomSheet(SDBdata);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0,
                                              right: 10.0,
                                              top: 0.0,
                                              bottom: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  SDBdata.like.length == 1
                                                      ? _userProvider
                                                              .userFriendsAll
                                                              .userdatas
                                                              .where((user) =>
                                                                  user.email ==
                                                                  SDBdata
                                                                      .like[0])
                                                              .toList()[0]
                                                              .nickname +
                                                          "님이 좋아합니다"
                                                      : _userProvider
                                                              .userFriendsAll
                                                              .userdatas
                                                              .where((user) =>
                                                                  user.email ==
                                                                  SDBdata
                                                                      .like[0])
                                                              .toList()[0]
                                                              .nickname +
                                                          "님 외 ${SDBdata.like.length - 1}명이 좋아합니다",
                                                  textScaleFactor: 1.1,
                                                  style: const TextStyle(
                                                      color: Colors.grey))
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                widget.isExEdit
                                    ? Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            height: 0.1,
                                            color: Colors.black,
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 0.1,
                                              color: const Color(0xFF717171),
                                            ),
                                          ),
                                          _imageExEditContent(SDBdata),
                                        ],
                                      )
                                    : _photoInfo["feedList"] ==
                                                widget.feedListCtrl &&
                                            _photoInfo["feedVisible"] == true &&
                                            SDBdata.image.length != 0
                                        ? Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                height: 0.1,
                                                color: Colors.black,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 0.1,
                                                  color:
                                                      const Color(0xFF717171),
                                                ),
                                              ),
                                              _imageContent(SDBdata),
                                            ],
                                          )
                                        : Container(),
                              ],
                            ),
                          ),
                        );
                }),
              ),
            ),
          );
  }

  Widget _exercise_Done_appbar_Button() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
          width: 96,
          child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
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
                submitExChange();
              },
              child: Text("운동 제출",
                  textScaleFactor: 1.1,
                  style: TextStyle(color: Theme.of(context).highlightColor)))),
    );
  }

  void submitExChange() {
    if (_initImage.length >= 0) {
      HistoryImagePut(history_id: widget.sdbdata.id, images: _initImage)
          .editHistoryListImage()
          .then((data) => {
                _historyProvider.getdata(),
                _historyProvider.getHistorydataAll()
              });
    }
    HistoryCommentEdit(
            history_id: widget.sdbdata.id,
            user_email: _userProvider.userdata.email,
            comment: _exEditCommentCtrl.text)
        .patchHistoryComment()
        .then((data) => {
              _historyProvider.patchHistoryCommentdata(
                  widget.sdbdata, _exEditCommentCtrl.text)
            });
    if (_image.isEmpty == false) {
      HistoryImageEdit(history_id: widget.sdbdata.id, file: _image)
          .patchHistoryImage()
          .then((data) => {
                _historyProvider.getdata(),
                _historyProvider.getHistorydataAll()
              });
    }
    _tempImgStrage.resetimg();
    Navigator.of(context).pop();
    _popProvider.gotoonlast();
    Future.delayed(const Duration(microseconds: 30000)).then((value) {
      _popProvider.gotooff();
    });

    //Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _commentWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
      child: TextFormField(
          controller: _exEditCommentCtrl,
          keyboardType: TextInputType.multiline,
          //expands: true,
          maxLines: null,
          decoration: InputDecoration(
              labelText: '운동에 관해 기록해보세요',
              labelStyle: TextStyle(
                  fontSize: 16.0, color: Theme.of(context).primaryColorDark),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              focusedBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              fillColor: Theme.of(context).primaryColorLight),
          style: TextStyle(color: Theme.of(context).primaryColorLight)),
    );
  }

  void _captureFeed() async {
    final RenderRepaintBoundary renderRepaintBoundary =
        repaintkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await renderRepaintBoundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List data = byteData!.buffer.asUint8List();

    final dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    String? path = dir?.path;
    final file = createFile(
      '$path/stamp_image_${DateTime.now().toString()}.png',
      data,
    );

    final watermark =
        await getImageFileFromAssets("jpeg/supero_logo_round.png");

    ui.Image originalImage = ui.decodeImage(file.readAsBytesSync()) as ui.Image;
    ui.Image watermarkImage =
        ui.decodeImage(watermark.readAsBytesSync()) as ui.Image;
    watermarkImage = ui.copyResize(watermarkImage, height: 100);

    // add watermark over originalImage
    // initialize width and height of watermark image
    //ui.Image img2 = ui.Image(height: 30, width: 60);
    //ui.draw(img2, watermarkImage);

    // give position to watermark over image
    // originalImage.width - 160 - 25 (width of originalImage - width of watermarkImage - extra margin you want to give)
    // originalImage.height - 50 - 25 (height of originalImage - height of watermarkImage - extra margin you want to give)
    originalImage = ui.compositeImage(originalImage, watermarkImage,
        dstX: originalImage.width - 70 - watermarkImage.width, dstY: 40);
    final data2 = ui.encodePng(originalImage);
    final file2 = createFile(
      '$path/stamp_image_${DateTime.now().toString()}.png',
      data2,
    );

    List<XFile> xlist = [];
    xlist.add(XFile(file2.path));
    Share.shareXFiles(xlist);
    //generate(file);
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<dynamic> _myFeedMenu(SDBdata) {
    return showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & const Size(30, 30), Offset.zero & const Size(0, 0)),
      items: [
        PopupMenuItem(
            child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                leading: Icon(Icons.no_photography,
                    color: Theme.of(context).primaryColorLight),
                title: Text("피드수정",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight))),
            onTap: () async {
              await Future.delayed(Duration.zero);
              Navigator.push(
                  context,
                  Transition(
                      child: FeedEdit(sdbdata: SDBdata),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            }),
        PopupMenuItem(
            child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                leading: Icon(Icons.details,
                    color: Theme.of(context).primaryColorLight),
                title: Text("운동수정",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight))),
            onTap: () async {
              await Future.delayed(Duration.zero);
              Navigator.push(
                  context,
                  Transition(
                      child: FriendHistory(sdbdata: SDBdata),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
            }),
        PopupMenuItem(
            child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                leading: Icon(Icons.share_rounded,
                    color: Theme.of(context).primaryColorLight),
                title: Text("사진공유",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight))),
            onTap: () async {
              List<String> _imagelist = [];
              final _cachemanager = DefaultCacheManager();
              for (int i = 0; i < SDBdata.image.length; i++) {
                final _file =
                    await _cachemanager.getSingleFile(SDBdata.image[i]);
                _imagelist.add(_file.path);
              }
              _photoInfo["feedList"] == widget.feedListCtrl &&
                      _photoInfo["feedVisible"] == true &&
                      SDBdata.image.length != 0
                  ? Share.shareFiles(_imagelist)
                  : Share.share(SDBdata.comment);
            }),
        PopupMenuItem(
            child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                leading: Icon(Icons.share_rounded,
                    color: Theme.of(context).primaryColorLight),
                title: Text("피드공유",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight))),
            onTap: () async {
              _captureFeed();
            }),
        PopupMenuItem(
            child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                leading: SDBdata.isVisible
                    ? Icon(Icons.filter_list_off,
                        color: Theme.of(context).primaryColorLight)
                    : Icon(Icons.filter_list,
                        color: Theme.of(context).primaryColorLight),
                title: SDBdata.isVisible
                    ? Text("숨김",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight))
                    : Text("보임",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight))),
            onTap: () {
              if (SDBdata.isVisible) {
                _historyProvider.patchHistoryVisible(SDBdata, false);
                HistoryVisibleEdit(history_id: SDBdata.id, status: "false")
                    .patchHistoryVisible();
              } else {
                _historyProvider.patchHistoryVisible(SDBdata, true);
                HistoryVisibleEdit(history_id: SDBdata.id, status: "true")
                    .patchHistoryVisible();
              }
            }),
      ],
    );
  }

  File createFile(String? path, Uint8List? data) {
    final file = File(path!);
    file.create();
    file.writeAsBytesSync(data!);
    return file;
  }

  Future<dynamic> _otherFeedMenu(SDBdata) {
    return showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & const Size(30, 30), Offset.zero & const Size(0, 0)),
      items: [
        PopupMenuItem(
            child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
                leading: Icon(Icons.remove_circle_outlined,
                    color: Theme.of(context).primaryColorLight),
                title: Text("신고",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight))),
            onTap: () {
              Future<void>.delayed(
                  const Duration(), // OR const Duration(milliseconds: 500),
                  () => _displayDislikeAlert(SDBdata.user_email));
            }),
      ],
    );
  }

  Widget _imageContent(SDBdata) {
    var container_size;
    if (MediaQuery.of(context).size.height / 1.5 >
        MediaQuery.of(context).size.width) {
      container_size = MediaQuery.of(context).size.width - 12;
    } else {
      container_size = MediaQuery.of(context).size.height / 3;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            height: container_size,
            child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: PageView.builder(
                    controller: _controller,
                    itemCount: SDBdata.image.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext _context, int index) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 4.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: ZoomOverlay(
                                modalBarrierColor: Colors.black12,
                                // optional
                                minScale: 0.5,
                                // optional
                                maxScale: 3.0,
                                // optional
                                twoTouchOnly: true,
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                animationCurve: Curves.fastOutSlowIn,
                                onScaleStop: () {},
                                child: CachedNetworkImage(
                                    imageUrl: SDBdata.image[index]),
                              ),
                            ),
                          ),
                        ),
                      );
                    }))),
        SDBdata.image.length > 1
            ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: SDBdata.image.length,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    type: WormType.thin,
                    activeDotColor: Theme.of(context).primaryColor,
                    dotColor: Colors.grey,
                    // strokeWidth: 5,
                  ),
                ),
              )
            : Container(),
        GestureDetector(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 30.0,
                child: const Center(
                    child: Icon(Icons.keyboard_control_key,
                        color: Colors.grey, size: 28.0))),
            onTap: () {
              setState(() {
                if (_photoInfo["feedList"] == widget.feedListCtrl) {
                  if (_photoInfo["feedVisible"] == true) {
                    _photoInfo = {
                      "feedList": widget.feedListCtrl,
                      "feedVisible": false
                    };
                  } else {
                    _photoInfo = {
                      "feedList": widget.feedListCtrl,
                      "feedVisible": true
                    };
                  }
                } else {
                  _photoInfo = {
                    "feedList": widget.feedListCtrl,
                    "feedVisible": true
                  };
                }
              });
            })
      ],
    );
  }

  Widget _imageExEditContent(SDBdata) {
    var container_size;
    if (MediaQuery.of(context).size.height / 1.5 >
        MediaQuery.of(context).size.width) {
      container_size = MediaQuery.of(context).size.width - 12;
    } else {
      container_size = MediaQuery.of(context).size.height / 3;
    }
    return Card(
      color: Theme.of(context).cardColor,
      child: Consumer2<HistorydataProvider, TempImgStorage>(
          builder: (builder, provider, provider2, child) {
        if (provider2.images.isNotEmpty) {
          _image = provider2.images;
        }
        try {
          _initImage = _historyProvider
                  .historydata
                  .sdbdatas[_historyProvider.historydata.sdbdatas
                      .indexWhere((sdbdata) {
                if (sdbdata.id == widget.sdbdata.id) {
                  return true;
                } else {
                  return false;
                }
              })]
                  .image ??
              [];
        } catch (e) {
          _initImage = [];
        }
        return Column(
          children: [
            SizedBox(
                height: container_size,
                child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: PageView.builder(
                        controller: _feedEditcontroller,
                        scrollDirection: Axis.horizontal,
                        itemCount: _initImage.length + _image.length + 1,
                        itemBuilder: (BuildContext _context, int index) {
                          return Center(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0, vertical: 8.0),
                                child: GestureDetector(
                                  child: _image.length + _initImage.length <=
                                          index
                                      ? AspectRatio(
                                          aspectRatio: 1,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Center(
                                              child: Icon(
                                                  Icons.add_photo_alternate,
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                  size: 120),
                                            ),
                                          ))
                                      : Stack(children: <Widget>[
                                          _initImage.length > index
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      SDBdata.image[index],
                                                  imageBuilder:
                                                      (context,
                                                              imageProivder) =>
                                                          AspectRatio(
                                                              aspectRatio: 1,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                        borderRadius:
                                                                            const BorderRadius.all(Radius.circular(
                                                                                20)),
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              imageProivder,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )),
                                                              )),
                                                )
                                              : AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    20)),
                                                        image: DecorationImage(
                                                          image: FileImage(File(
                                                              _image[index -
                                                                      _initImage
                                                                          .length]
                                                                  .path)),
                                                          fit: BoxFit.cover,
                                                        )),
                                                  )),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (index >=
                                                    _initImage.length) {
                                                  setState(() {
                                                    _image.removeAt(index -
                                                        _initImage.length);
                                                  });
                                                } else {
                                                  setState(() {
                                                    _initImage.removeAt(index);
                                                  });
                                                }
                                              },
                                              child: SizedBox(
                                                width: 24.0,
                                                height: 24.0,
                                                child: Center(
                                                  child: Material(
                                                    shape: const CircleBorder(),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    elevation: 4.0,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 14,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ]),
                                  onTap: () {
                                    if (_initImage.length + _image.length <=
                                        index) {
                                      _displayPhotoAlert(SDBdata);
                                    }
                                  },
                                )),
                          );
                        }))),
            _initImage.length + _image.length > 0
                ? Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SmoothPageIndicator(
                      controller: _feedEditcontroller,
                      count: _initImage.length + _image.length + 1,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        type: WormType.thin,
                        activeDotColor: Theme.of(context).primaryColor,
                        dotColor: Colors.grey,
                        // strokeWidth: 5,
                      ),
                    ),
                  )
                : Container(),
          ],
        );
      }),
    );
  }

  void _displayPhotoAlert(SDBdata) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                      child: Text("사진을 올릴 방법을 고를 수 있어요",
                          textScaleFactor: 1.3,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
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
                                disabledForegroundColor:
                                    const Color.fromRGBO(246, 58, 64, 20),
                                padding: const EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    Transition(
                                        child: PhotoEditor(
                                            sdbdata: SDBdata,
                                            imageSource: ImageSource.camera),
                                        transitionEffect:
                                            TransitionEffect.RIGHT_TO_LEFT));
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 24,
                                      color: Theme.of(context).highlightColor),
                                  Text('촬영',
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .highlightColor)),
                                ],
                              ),
                            )),
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
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
                                disabledForegroundColor:
                                    const Color.fromRGBO(246, 58, 64, 20),
                                padding: const EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                //_getImage(ImageSource.gallery);
                                Navigator.pop(context);

                                Navigator.push(
                                    context,
                                    Transition(
                                        child: PhotoEditor(
                                            sdbdata: SDBdata,
                                            imageSource: ImageSource.gallery),
                                        transitionEffect:
                                            TransitionEffect.RIGHT_TO_LEFT));
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.collections,
                                      size: 24,
                                      color: Theme.of(context).highlightColor),
                                  Text('갤러리',
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .highlightColor)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _commentContent(SDBdata, StateSetter setState) {
    if (_historyProvider.commentAll != null) {
      _commentListbyId = _historyProvider.commentAll.comments
          .where((comment) => comment.history_id == SDBdata.id)
          .toList();
    } else {
      _commentListbyId = [];
    }
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext _context, int index) {
          return Padding(
              padding: const EdgeInsets.all(4.0),
              child: _commentContentCore(_commentListbyId[index], setState));
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

  Widget _commentContentCore(Comment, StateSetter setState) {
    User user = _userProvider.userFriendsAll.userdatas
        .where((user) => user.email == Comment.writer_email)
        .toList()[0];
    return _userProvider.userdata.dislike.contains(Comment.writer_email)
        ? const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text("차단된 사용자 입니다",
                textScaleFactor: 1.0, style: TextStyle(color: Colors.grey)))
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: user.image == ""
                          ? const Icon(
                              Icons.account_circle,
                              color: Colors.grey,
                              size: 38.0,
                            )
                          : CachedNetworkImage(
                              imageUrl: user.image,
                              imageBuilder: (context, imageProivder) =>
                                  Container(
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
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _commentInputCtrl.clear();
                                  _focus = false;
                                  _focusNode.unfocus();
                                });
                                setState(() {
                                  _commentInputCtrl.text =
                                      "@" + Comment.writer_nickname + "  ";
                                  _focus = true;
                                  _focusNode.requestFocus();
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0.0, vertical: 6.0),
                                child: Text("답글 달기",
                                    textScaleFactor: 0.9,
                                    style: TextStyle(color: Colors.grey)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              widget.isExEdit
                  ? _exercise_Done_appbar_Button()
                  : GestureDetector(
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
                                          _historyProvider
                                              .deleteCommentAll(Comment);
                                          Future<void>.delayed(
                                              const Duration(),
                                              // OR const Duration(milliseconds: 500),
                                              () => CommentDelete(
                                                      comment_id: Comment.id)
                                                  .deleteComment());
                                          setState(() {});
                                        },
                                        padding: const EdgeInsets.all(0.0),
                                        child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                    vertical: 0.0),
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
                                              const Duration(),
                                              // OR const Duration(milliseconds: 500),
                                              () => _displayDislikeAlert(
                                                  Comment.writer_email));
                                        },
                                        padding: const EdgeInsets.all(0.0),
                                        child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                    vertical: 0.0),
                                            leading: Icon(
                                                Icons.remove_circle_outlined,
                                                color: Theme.of(context)
                                                    .primaryColorLight),
                                            title: Text("신고",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight)))),
                                  ]);
                      },
                      child: const SizedBox(
                        height: 38,
                        width: 24,
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                          size: 18.0,
                        ),
                      ),
                    )
            ],
          );
  }

  Widget _feedTextField(text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 10,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Text(text,
                textScaleFactor: 1.3,
                style: TextStyle(color: Theme.of(context).primaryColorLight)),
          ),
        )
      ],
    );
  }

  Widget _feedCommentButton(SDBdata) {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
            onTap: () {
              _showCommentBottomSheet(SDBdata);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child: Icon(Icons.message,
                        color: Theme.of(context).primaryColorLight,
                        size: 24.0)),
                Text(_commentListbyId.length.toString(),
                    textScaleFactor: 1.3,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight))
              ],
            )));
  }

  void _showCommentBottomSheet(SDBdata) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return GestureDetector(onTap: () {
          FocusScope.of(context).unfocus();
        }, child: StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return Container(
            padding: EdgeInsets.only(
                top: 12.0,
                bottom: 12.0 + MediaQuery.of(context).viewInsets.bottom),
            height: MediaQuery.of(context).size.height * 0.7 +
                MediaQuery.of(context).viewInsets.bottom,
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
                    _feedTextField(SDBdata.comment),
                    Container(
                      alignment: Alignment.center,
                      height: 0.3,
                      child: Container(
                        alignment: Alignment.center,
                        height: 0.3,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _commentScrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: _commentContent(SDBdata, setState),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 0.3,
                      child: Container(
                        alignment: Alignment.center,
                        height: 0.3,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, bottom: 8.0),
                      child: _commentTextInput(SDBdata, setState),
                    ),
                  ],
                ),
              ],
            ),
          );
        }));
      },
    );
  }

  Widget _feedPhotoButton(SDBdata) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 4.0, 12.0, 4.0),
        child: GestureDetector(
            onTap: () {
              setState(() {
                if (_photoInfo["feedList"] == widget.feedListCtrl) {
                  if (_photoInfo["feedVisible"] == true) {
                    _photoInfo = {
                      "feedList": widget.feedListCtrl,
                      "feedVisible": false
                    };
                  } else {
                    _photoInfo = {
                      "feedList": widget.feedListCtrl,
                      "feedVisible": true
                    };
                  }
                } else {
                  _photoInfo = {
                    "feedList": widget.feedListCtrl,
                    "feedVisible": true
                  };
                }
              });
            },
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child: Icon(Icons.camera_alt_rounded,
                        color: Theme.of(context).primaryColorLight,
                        size: 24.0)),
                Text(SDBdata.image.length.toString(),
                    textScaleFactor: 1.3,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight))
              ],
            )));
  }

  Widget _feedLikeButton(SDBdata) {
    var buttonSize = 24.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: LikeButton(
        size: buttonSize,
        isLiked: onIsLikedCheck(SDBdata),
        circleColor:
            const CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
        bubblesColor: const BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              Icons.favorite,
              color: isLiked
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColorLight,
              size: buttonSize,
            ),
          );
        },
        onTap: (bool isLiked) async {
          return onLikeButtonTapped(isLiked, SDBdata);
        },
        likeCount: SDBdata.like.length,
        countBuilder: (int? count, bool isLiked, String text) {
          var color = isLiked
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColorLight;
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

  bool onIsLikedCheck(SDBdata) {
    if (SDBdata.like.contains(_userProvider.userdata.email)) {
      return true;
    } else {
      return false;
    }
  }

  bool onLikeButtonTapped(bool isLiked, SDBdata) {
    if (isLiked == true) {
      HistoryLike(
              history_id: SDBdata.id,
              user_email: _userProvider.userdata.email,
              status: "remove",
              disorlike: "like")
          .patchHistoryLike();
      _historyProvider.patchHistoryLikedata(
          SDBdata, _userProvider.userdata.email, "remove");
      return false;
    } else {
      HistoryLike(
              history_id: SDBdata.id,
              user_email: _userProvider.userdata.email,
              status: "append",
              disorlike: "like")
          .patchHistoryLike();
      _historyProvider.patchHistoryLikedata(
          SDBdata, _userProvider.userdata.email, "append");
      return !isLiked;
    }
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

  Widget _commentTextInput(SDBdata, StateSetter setState) {
    return Row(
      children: [
        _userProvider.userdata.image == ""
            ? const Icon(
                Icons.account_circle,
                color: Colors.grey,
                size: 46.0,
              )
            : CachedNetworkImage(
                imageUrl: _userProvider.userdata.image,
                imageBuilder: (context, imageProivder) => Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      image: DecorationImage(
                        image: imageProivder,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
        Flexible(
          child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: FocusScope(
                  child: Focus(
                onFocusChange: (focus) {
                  _focus = focus;
                  setState(() {});
                },
                child: TextFormField(
                  maxLines: null,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.multiline,
                  controller: _commentInputCtrl,
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 12.0),
                  decoration: InputDecoration(
                    hintText: " 댓글 신고시 이용이 제한 될 수 있습니다.",
                    hintStyle: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 12.0),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 0.0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColorLight,
                          width: 0.3),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColorLight,
                          width: 0.3),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ))),
        ),
        _focus == true
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  child: Icon(Icons.arrow_upward,
                      size: 32, color: Theme.of(context).primaryColor),
                  onTap: () {
                    _historyProvider.addCommentAll(hisdata.Comment(
                        history_id: SDBdata.id,
                        reply_id: 0,
                        writer_email: _userProvider.userdata.email,
                        writer_nickname: _userProvider.userdata.nickname,
                        content: _commentInputCtrl.text));
                    CommentCreate(
                            history_id: SDBdata.id,
                            reply_id: 0,
                            writer_email: _userProvider.userdata.email,
                            writer_nickname: _userProvider.userdata.nickname,
                            content: _commentInputCtrl.text)
                        .postComment()
                        .then((data) {
                      _historyProvider.getCommentAll();
                    });
                    _commentInputCtrl.clear();
                    setState(() {
                      _commentScrollController.animateTo(
                        _commentScrollController.position.maxScrollExtent,
                        duration: const Duration(seconds: 2),
                        curve: Curves.fastOutSlowIn,
                      );
                    });
                  },
                ),
              )
            : Container()
      ],
    );
  }

  Widget _exerciseWidget(Exercises, index) {
    var cardioValueSec = 0;
    if (Exercises.isCardio) {
      Exercises.sets.forEach((set) {
        cardioValueSec = cardioValueSec + set.reps as int;
      });
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                child: Text(
                  Exercises.name,
                  textScaleFactor: 1.3,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                Exercises.sets.length.toString(),
                textScaleFactor: 1.3,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                Exercises.isCardio
                    ? cardioValueSec > 60
                        ? (cardioValueSec ~/ 60).toString() + "분"
                        : cardioValueSec.toString() + "초"
                    : Exercises.onerm.toStringAsFixed(1),
                textScaleFactor: 1.3,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLikeFreindBottomSheet(SDBdata) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return GestureDetector(onTap: () {
          FocusScope.of(context).unfocus();
        }, child: StatefulBuilder(
          builder: (BuildContext context,
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
                            child: ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder:
                                    (BuildContext _context, int index) {
                                  var userLikesEmail = _userProvider
                                      .userFriendsAll.userdatas
                                      .where((user) =>
                                          user.email == SDBdata.like[index])
                                      .toList()[0];
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                widget.openUserDetail
                                                    ? Navigator.push(
                                                        context,
                                                        Transition(
                                                            child: FriendProfile(
                                                                user:
                                                                    userLikesEmail),
                                                            transitionEffect:
                                                                TransitionEffect
                                                                    .RIGHT_TO_LEFT))
                                                    : null;
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  userLikesEmail.image == ""
                                                      ? const Icon(
                                                          Icons.account_circle,
                                                          color: Colors.grey,
                                                          size: 46.0,
                                                        )
                                                      : CachedNetworkImage(
                                                          imageUrl:
                                                              userLikesEmail
                                                                  .image,
                                                          imageBuilder: (context,
                                                                  imageProivder) =>
                                                              Container(
                                                            height: 46,
                                                            width: 46,
                                                            decoration:
                                                                BoxDecoration(
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            50)),
                                                                    image:
                                                                        DecorationImage(
                                                                      image:
                                                                          imageProivder,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )),
                                                          ),
                                                        ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: Text(
                                                      userLikesEmail.nickname,
                                                      textScaleFactor: 1.5,
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorLight),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ]));
                                },
                                separatorBuilder:
                                    (BuildContext _context, int index) {
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
                                itemCount: SDBdata.like.length))),
                  ],
                ));
          },
        ));
      },
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
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
