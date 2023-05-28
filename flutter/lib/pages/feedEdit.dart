import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/src/utils/feedCard.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'package:sdb_trainer/providers/tempimagestorage.dart';

GlobalKey<FeedCardState> globalKey = GlobalKey();

class FeedEdit extends StatefulWidget {
  final hisdata.SDBdata sdbdata;
  FeedEdit({Key? key, required this.sdbdata}) : super(key: key);

  @override
  State<FeedEdit> createState() => _FeedEditState();
}

class _FeedEditState extends State<FeedEdit> {
  var _tempImgStrage;
  final _pageController = ScrollController();
  var btnDisabled;
  final binding = WidgetsFlutterBinding.ensureInitialized();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _tempImgStrage = Provider.of<TempImgStorage>(context, listen: false);
    return Scaffold(
        extendBody: true,
        appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(40.0), // here the desired height
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
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).highlightColor,
          onPressed: () {
            globalKey.currentState!.submitExChange();
            // Respond to button press
          },
          label: const Text("운동 제출 하기", textScaleFactor: 1.5),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        body: Center(
            child: SingleChildScrollView(
          child: FeedCard(
              sdbdata: widget.sdbdata,
              index: 0,
              feedListCtrl: 0,
              openUserDetail: true,
              isExEdit: true,
              ad: false,
              key: globalKey),
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
