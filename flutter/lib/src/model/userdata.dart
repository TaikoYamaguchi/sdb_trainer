import 'dart:convert';

class User {
  final int id;
  final String email;
  final String username;
  final String nickname;
  final double height;
  final double weight;
  final String height_unit;
  final String weight_unit;
  final bool is_active;
  final bool isMan;
  final bool is_superuser;
  final int level;
  final int point;
  final int history_cnt;
  final String created_at;
  final String image;
  final List like;
  final List dislike;
  final List liked;
  final List disliked;
  final List favor_exercise;
  final List<BodyStat> bodyStats;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.nickname,
    required this.height,
    required this.weight,
    required this.height_unit,
    required this.weight_unit,
    required this.is_active,
    required this.is_superuser,
    required this.isMan,
    required this.level,
    required this.point,
    required this.history_cnt,
    required this.created_at,
    required this.like,
    required this.liked,
    required this.image,
    required this.dislike,
    required this.disliked,
    required this.favor_exercise,
    required this.bodyStats,
  });

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['body_stats'].runtimeType == String
        ? json.decode(parsedJson['body_stats']) as List
        : parsedJson['body_stats'] as List;

    List<BodyStat> bodyStats = list
        .map((i) => i.runtimeType == String
            ? BodyStat.fromJson(json.decode(i))
            : BodyStat.fromJson(i))
        .toList();
    return User(
      id: parsedJson['id'],
      email: parsedJson['email'],
      username: parsedJson['username'],
      nickname: parsedJson['nickname'],
      height: parsedJson['height'],
      weight: parsedJson['weight'],
      height_unit: parsedJson['height_unit'],
      weight_unit: parsedJson['weight_unit'],
      is_active: parsedJson['is_active'],
      is_superuser: parsedJson['is_superuser'],
      isMan: parsedJson['isMan'],
      level: parsedJson['level'],
      point: parsedJson['point'],
      history_cnt: parsedJson['history_cnt'],
      created_at: parsedJson["created_at"],
      like: parsedJson["like"],
      liked: parsedJson["liked"],
      image: parsedJson["image"],
      dislike: parsedJson["dislike"],
      disliked: parsedJson["disliked"],
      favor_exercise: parsedJson["favor_exercise"],
      bodyStats: bodyStats,
    );
  }
}

class UserList {
  final List<User> userdatas;

  UserList({
    required this.userdatas,
  });

  factory UserList.fromJson(List<dynamic> parsedJson) {
    List<User> userdatas = <User>[];
    userdatas = parsedJson.map((i) => User.fromJson(i)).toList();

    return new UserList(userdatas: userdatas);
  }
}

class BodyStat {
  final String? date;
  final double? weight;
  final double? weight_goal;
  final double? height;
  final double? height_goal;
  BodyStat({
    required this.date,
    required this.weight,
    required this.weight_goal,
    required this.height,
    required this.height_goal,
  });

  factory BodyStat.fromJson(Map<String, dynamic> parsedJson) {
    return BodyStat(
      date: parsedJson["date"],
      weight: parsedJson["weight"].toDouble(),
      weight_goal: parsedJson["weight_goal"].toDouble(),
      height: parsedJson["height"].toDouble(),
      height_goal: parsedJson["height_goal"].toDouble(),
    );
  }
  Map toJson() {
    return {
      'date': date,
      'weight': weight,
      'weight_goal': weight_goal,
      'height': height,
      'height_goal': height_goal,
    };
  }
}
