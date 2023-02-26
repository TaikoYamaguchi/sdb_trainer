import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/feed_friend_edit.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/feed_friend.dart';
import 'package:sdb_trainer/src/utils/feedCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/src/utils/feedCard.dart';
import 'package:sdb_trainer/providers/tempimagestorage.dart';

class FeedEdit extends StatefulWidget {
  final hisdata.SDBdata sdbdata;
  FeedEdit({Key? key, required this.sdbdata}) : super(key: key);

  @override
  State<FeedEdit> createState() => _FeedEditState();
}

class _FeedEditState extends State<FeedEdit> {
  var _feedListCtrl = 1;

  var _tempImgStrage;
  var _hisProvider;
  var _historydata;
  var _userProvider;
  final _pageController = ScrollController();
  var _final_history_id;
  var _hasMore = true;
  var btnDisabled;

  final _isPageController = PageController(initialPage: 4242, keepPage: true);

  final binding = WidgetsFlutterBinding.ensureInitialized();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _tempImgStrage = Provider.of<TempImgStorage>(context, listen: false);

    return Scaffold(
        extendBody: true,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(40.0), // here the desired height
            child: AppBar(
              leading: Center(
                child: GestureDetector(
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  onTap: () {
                    _tempImgStrage.resetimg();
                    btnDisabled == true
                        ? null
                        : [btnDisabled = true, Navigator.of(context).pop()];
                  },
                ),
              ),
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("피드 수정",
                      textScaleFactor: 1.7,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                ],
              ),
              backgroundColor: Theme.of(context).canvasColor,
            )),
        body: Center(
            child: Container(
          child: SingleChildScrollView(
            child: FeedCard(
                sdbdata: widget.sdbdata,
                index: 0,
                feedListCtrl: 0,
                openUserDetail: true,
                isExEdit: true),
          ),
        )));
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
