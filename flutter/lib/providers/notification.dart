import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/notification_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class NotificationdataProvider extends ChangeNotifier {
  var _notificationdata;
  get notificationdata => _notificationdata;


  getdata() async {
    await NotificationRepository.loadNotificationdataAll().then((value) {
      _notificationdata = value;
      notifyListeners();
    });
  }

  postdata(noti, files) async {
    if (files.length != 0){
      NotificationPost(title: noti.title, content: noti.content, images: noti.images, ispopup: noti.ispopup).postNotification().then((value) {
        value["id"] != null
            ? NotificationImageEdit(notification_id: value["id"], file: files).patchHistoryImage()
            : showToast("입력을 확인해주세요");
      } );

    } else {
      NotificationPost(title: noti.title, content: noti.content, images: noti.images, ispopup: noti.ispopup).postNotification().then((value) {
        value["id"] != null
            ? showToast("수정완료")
            : showToast("입력을 확인해주세요");
      } );
  }}

  editdata(noti) async {
    NotificationEdit(notification: noti).editNotification();
  }

}