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
  late String content;
  List<dynamic>? images;
  late bool ispopup;
  late String? date;

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
    var cont = parsedJson['content'].runtimeType == String
        ? json.decode(parsedJson['exercises'])
        : parsedJson['exercises'];
    return Notification(
      id: parsedJson['id'],
      title: parsedJson['title'],
      content: parsedJson['content'],
      images: parsedJson["images"],
      ispopup: parsedJson["ispopup"],
      date: parsedJson["date"],
    );
  }
}


/*
class Content {
  late String name;
  late double? onerm;
  late double? goal;
  late bool? custom;
  late List? target;
  late String? category;
  late String? image;
  late String? note;

  Content({
    required this.name,
    required this.onerm,
    required this.goal,
    required this.custom,
    required this.target,
    required this.category,
    required this.image,
    required this.note,
  });
  Map toJson() => {
    "goal": goal,
    "name": name,
    "onerm": onerm,
    "custom": custom,
    "target": target,
    "category": category,
    "image": image,
    "note": note
  };

  factory Content.fromJson(Map<String, dynamic> parsedJson) {
    return Content(
      name: parsedJson["name"],
      onerm: parsedJson["onerm"].toDouble(),
      goal: parsedJson["goal"].toDouble(),
      custom: parsedJson["custom"],
      target: parsedJson["target"],
      category: parsedJson["category"],
      image: parsedJson["image"],
      note: parsedJson["note"],
    );
  }
}

 */
