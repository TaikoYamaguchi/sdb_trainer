import 'dart:convert';
import 'package:sdb_trainer/src/model/notification.dart';
import 'package:http/http.dart' as http;
import 'package:sdb_trainer/localhost.dart';

class NotificationRepository {
  static Future<String> _loadNotificationdataAllFromServer() async {
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/notification/");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<NotificationList> loadNotificationdataAll() async {
    String jsonString = await _loadNotificationdataAllFromServer();
    final jsonResponse = json.decode(jsonString);
    NotificationList notificationdatalist =
    NotificationList.fromJson(jsonResponse);
    return (notificationdatalist);
  }
}

class NotificationPost {
  final Notification notification;
  NotificationPost({
    required this.notification,
  });
  Future<String> _notificationPostFromServer() async {
    var formData = Map<String, dynamic>();
    formData["notification"] = jsonEncode(notification);

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/notificationcreate");
    var response = await http.post(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> postExercise() async {
    String jsonString = await _notificationPostFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class NotificationEdit {
  final Notification notification;
  NotificationEdit({
    required this.notification,
  });
  Future<String> _notificationEditFromServer() async {
    var formData = Map<String, dynamic>();
    formData["notification"] = jsonEncode(notification);

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/notification");
    var response = await http.put(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> editExercise() async {
    String jsonString = await _notificationEditFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class NotificationDelete {
  final int id;
  NotificationDelete({
    required this.id,
  });
  Future<String> _notificationDeleteFromServer() async {
    var url =
    Uri.parse(LocalHost.getLocalHost() + "/api/workout/" + id.toString());
    var response = await http.delete(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to delete');
    }
  }

  Future deleteWorkout() async {
    String jsonString = await _notificationDeleteFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}