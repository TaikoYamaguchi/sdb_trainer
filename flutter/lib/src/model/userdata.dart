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
  final String created_at;
  final List like;
  final List dislike;
  final List favor_exercise;

  User(
      {required this.id,
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
      required this.created_at,
      required this.like,
      required this.dislike,
      required this.favor_exercise,
      });

  factory User.fromJson(Map<String, dynamic> parsedJson) {
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
        created_at: parsedJson["created_at"],
        like: parsedJson["like"],
        dislike: parsedJson["dislike"],
        favor_exercise: parsedJson["favor_exercise"]
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
