import 'dart:convert';

class NotificationList {
  final List<Notification> notifications;

  NotificationList({
    required this.notifications,
  });
  Map toJson() => {'notifications': notifications};

  factory NotificationList.fromJson(List<dynamic> parsedJson) {
    List<Notification> notifications = <Notification>[];
    notifications = parsedJson.map((i) => Notification.fromJson(i)).toList();

    return NotificationList(notifications: notifications);
  }
}

class Notification {
  late int? id;
  late String title;
  late Content content;
  List<dynamic>? images;
  late bool ispopup;
  final String? date;

  Notification({
    this.id,
    required this.title,
    required this.content,
    required this.images,
    required this.ispopup,
    this.date,

  });
  Map toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "images": images,
    "ispopup": ispopup,
    "date": date,

  };

  factory Notification.fromJson(Map<String, dynamic> parsedJson) {
    var hcont = parsedJson['content'].runtimeType == String
        ? json.decode(parsedJson['content'])
        : parsedJson['content'];
    Content htmlcontent = Content.fromJson(hcont);
    return Notification(
      id: parsedJson['id'],
      title: parsedJson['title'],
      content: htmlcontent,
      images: parsedJson["images"],
      ispopup: parsedJson["ispopup"],
      date: parsedJson["date"],
    );
  }
}



class Content {
  late String html;

  Content({
    required this.html,

  });
  Map toJson() => {
    "html": html,

  };

  factory Content.fromJson(Map<String, dynamic> parsedJson) {
    return Content(
      html: parsedJson["html"],

    );
  }
}

