import 'package:flutter/material.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/src/utils/firebase_fcm.dart';
import 'dart:async';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:permission_handler/permission_handler.dart';

class UserNotification extends StatefulWidget {
  UserNotification({Key? key}) : super(key: key);

  @override
  _UserNotificationState createState() => _UserNotificationState();
}

class _UserNotificationState extends State<UserNotification> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        body: _userNotificationWidget(),
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
            "",
            textScaleFactor: 2.5,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _userNotificationWidget() {
    bool btnDisabled = false;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onPanUpdate: (details) {
          if (details.delta.dx > 20 && btnDisabled == false) {
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
