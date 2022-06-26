import 'dart:async' show Future;
import 'dart:convert';
import '../src/model/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:sdb_trainer/localhost.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class UserService {
  static Future<String> _loadUserdataFromServer() async {
    final storage = new FlutterSecureStorage();
    String? user_email = await storage.read(key: "sdb_email");
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/user/" + user_email!);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  static Future<User> loadUserdata() async {
    String jsonString = await _loadUserdataFromServer();
    final jsonResponse = json.decode(jsonString);
    User user = User.fromJson(jsonResponse);
    return (user);
  }
}

class UserLogin {
  final String userEmail;
  final String password;
  UserLogin({required this.userEmail, required this.password});
  Future<String> _userLoginFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["username"] = userEmail;
    formData["passowrd"] = password;
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/token");
    var response = await http
        .post(url, body: {'username': userEmail, 'password': password});
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

      final storage = new FlutterSecureStorage();
      await storage.write(key: "sdb_email", value: userEmail);
      await storage.write(
          key: "sdb_token", value: jsonResponse["access_token"]);
      String? user_email = await storage.read(key: "sdb_email");
      String? user_token = await storage.read(key: "sdb_token");

      return utf8.decode(response.bodyBytes);
    } else {
      print(1);
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<Map<String, dynamic>> loginUser() async {
    String jsonString = await _userLoginFromServer();
    print(3);
    print(jsonString);
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class UserLoginKakao {
  final String userEmail;
  UserLoginKakao({required this.userEmail});
  Future<String> _userLoginFromServer() async {
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/tokenkakao/" + userEmail);
    var response = await http.post(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

      final storage = new FlutterSecureStorage();
      await storage.write(key: "sdb_email", value: userEmail);
      await storage.write(
          key: "sdb_token", value: jsonResponse["access_token"]);
      String? user_email = await storage.read(key: "sdb_email");
      String? user_token = await storage.read(key: "sdb_token");

      return utf8.decode(response.bodyBytes);
    } else {
      print(1);
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<Map<String, dynamic>> loginKakaoUser() async {
    String jsonString = await _userLoginFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class UserSignUp {
  final String userEmail;
  final String userName;
  final String userNickname;
  final String userHeight;
  final String userWeight;
  final String userHeightUnit;
  final String userWeightUnit;
  final String userPhonenumber;
  final String userImage;
  final String password;
  UserSignUp(
      {required this.userEmail,
      required this.userName,
      required this.userNickname,
      required this.userHeight,
      required this.userWeight,
      required this.userHeightUnit,
      required this.userWeightUnit,
      required this.userPhonenumber,
      required this.userImage,
      required this.password});
  Future<String> _userSignUpFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["username"] = userName;

    formData["nickname"] = userNickname;
    formData["image"] = userImage;
    formData["height"] = userHeight;
    formData["weight"] = userWeight;
    formData["height_unit"] = userHeightUnit;
    formData["weight_unit"] = userWeightUnit;
    formData["password"] = password;
    formData["phone_number"] = userPhonenumber;
    formData["email"] = userEmail;
    formData["like"] = [];
    formData["dislike"] = [];
    formData["favor_exercise"] = [];

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/usercreate");
    var response = await http.post(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

      final storage = new FlutterSecureStorage();
      await storage.write(key: "sdb_email", value: userEmail);
      await storage.write(
          key: "sdb_token", value: jsonResponse["access_token"]);
      String? user_email = await storage.read(key: "sdb_email");
      String? user_token = await storage.read(key: "sdb_token");

      return utf8.decode(response.bodyBytes);
    } else if (response.statusCode == 404) {
      print("404");
      showToast("중복된 닉네임 입니다.");
      throw Error();
    } else if (response.statusCode == 403) {
      print("403");
      showToast("중복된 이메일 입니다.");
      throw Error();
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<Map<String, dynamic>> signUpUser() async {
    String jsonString = await _userSignUpFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class UserLogOut {
  static logOut() async {
    final storage = new FlutterSecureStorage();
    await storage.delete(key: "sdb_email");
    await storage.delete(key: "sdb_token");
  }
}

class UserEdit {
  final String userEmail;
  final String userName;
  final String userNickname;
  final String userHeight;
  final String userWeight;
  final String userHeightUnit;
  final String userWeightUnit;
  final String userImage;
  final String password;
  final List userFavorExercise;
  UserEdit(
      {required this.userEmail,
      required this.userName,
      required this.userNickname,
      required this.userHeight,
      required this.userWeight,
      required this.userHeightUnit,
      required this.userWeightUnit,
      required this.userImage,
      required this.password,
      required this.userFavorExercise});
  Future<String> _userEditFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["username"] = userName;
    formData["nickname"] = userNickname;
    formData["image"] = userImage;
    formData["height"] = userHeight;
    formData["weight"] = userWeight;
    formData["height_unit"] = userHeightUnit;
    formData["weight_unit"] = userWeightUnit;
    formData["password"] = password;
    formData["favor_exercise"] = userFavorExercise;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/user/" + userEmail);
    var response = await http.put(url, body: json.encode(formData));
    print(response.statusCode);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else if (response.statusCode == 404) {
      showToast("중복된 닉네임 입니다.");
      throw Error();
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Error();
    }
  }

  Future<Map<String, dynamic>> editUser() async {
    String jsonString = await _userEditFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class UserInfo {
  final String userEmail;
  UserInfo({required this.userEmail});
  Future<String> _userByEmailFromServer() async {
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/user/" + userEmail);
    print("useremail");
    print(userEmail);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<User?> getUserByEmail() async {
    String jsonString = await _userByEmailFromServer();
    final jsonResponse = json.decode(jsonString);
    print("3333");
    print(jsonResponse);
    if (jsonResponse == null) {
      return null;
    } else {
      User user = User.fromJson(jsonResponse);
      return (user);
    }
  }
}

class UserNickname {
  final String userNickname;
  UserNickname({required this.userNickname});
  Future<String> _userByNicknameFromServer() async {
    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/userNickname/" + userNickname);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<User?> getUserByNickname() async {
    String jsonString = await _userByNicknameFromServer();
    final jsonResponse = json.decode(jsonString);
    print("3333");
    print(jsonResponse);
    if (jsonResponse == null) {
      return null;
    } else {
      User user = User.fromJson(jsonResponse);
      return (user);
    }
  }
}

class UserNicknameAll {
  final String userNickname;
  UserNicknameAll({required this.userNickname});
  Future<String> _usersByNicknameFromServer() async {
    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/usersNickname/" + userNickname);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<UserList?> getUsersByNickname() async {
    String jsonString = await _usersByNicknameFromServer();
    final jsonResponse = json.decode(jsonString);
    print("3333");
    print(jsonResponse);
    if (jsonResponse == null) {
      return null;
    } else {
      UserList user = UserList.fromJson(jsonResponse);
      return (user);
    }
  }
}

class UserAll {
  Future<String> _usersAllFromServer() async {
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/users");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<UserList?> getUsers() async {
    String jsonString = await _usersAllFromServer();
    final jsonResponse = json.decode(jsonString);
    if (jsonResponse == null) {
      return null;
    } else {
      UserList user = UserList.fromJson(jsonResponse);
      return (user);
    }
  }
}

class UserLike {
  final String liked_email;
  final String user_email;
  final String status;
  final String disorlike;
  UserLike(
      {required this.liked_email,
      required this.user_email,
      required this.status,
      required this.disorlike});
  Future<String> _userLikeFromServer() async {
    var formData = new Map<String, dynamic>();
    formData["liked_email"] = liked_email;
    formData["email"] = user_email;
    formData["status"] = status;
    formData["disorlike"] = disorlike;

    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/user/likes/${liked_email}");
    var response = await http.patch(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> patchUserLike() async {
    String jsonString = await _userLikeFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}

class UserLikeFriends {
  final String user_email;
  UserLikeFriends({
    required this.user_email,
  });
  Future<String> _userLikeFriendsFromServer() async {
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/friends/${user_email}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<UserList?> getUserLikeFriends() async {
    String jsonString = await _userLikeFriendsFromServer();
    final jsonResponse = json.decode(jsonString);
    if (jsonResponse == null) {
      return null;
    } else {
      UserList user = UserList.fromJson(jsonResponse);
      return (user);
    }
  }
}

class UserPhoneCheck {
  final String userPhoneNumber;
  UserPhoneCheck({required this.userPhoneNumber});
  Future<String> _userByPhoneNumberFromServer() async {
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/create/" + userPhoneNumber);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<User?> getUserByPhoneNumber() async {
    String jsonString = await _userByPhoneNumberFromServer();
    final jsonResponse = json.decode(jsonString);
    print("3333");
    print(jsonResponse);
    if (jsonResponse == null) {
      return null;
    } else {
      User user = User.fromJson(jsonResponse);
      return (user);
    }
  }
}
