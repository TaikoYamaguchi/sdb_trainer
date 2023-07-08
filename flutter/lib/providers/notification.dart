import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/notification_repository.dart';

class NotificationdataProvider extends ChangeNotifier {
  var _notificationdata;
  get notificationdata => _notificationdata;


  getdata() async {
    await NotificationRepository.loadNotificationdataAll().then((value) {
      _notificationdata = value;
      notifyListeners();
    });
  }
}