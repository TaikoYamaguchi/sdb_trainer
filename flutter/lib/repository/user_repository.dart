import 'dart:async' show Future;
import 'dart:convert';
import '../src/model/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:sdb_trainer/localhost.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class UserService {
  final String token;

  UserService({required this.token});

  Future<String> _loadUserdataFromServer() async {
    final storage = FlutterSecureStorage();

    String? user_email = await storage.read(key: "sdb_email");

    final url =
        Uri.parse(LocalHost.getLocalHost() + "/api/user/" + user_email!);
    final response = await http.patch(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${token}',
      },
    );

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else if (response.statusCode == 401) {
      throw Exception('인증 실패');
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('데이터를 불러오는데 실패 했습니다');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<User> loadUserdata() async {
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
    var formData = Map<String, dynamic>();
    formData["username"] = userEmail;
    formData["passowrd"] = password;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/token");
    var response = await http
        .post(url, body: {'username': userEmail, 'password': password});
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

      const storage = FlutterSecureStorage();
      await storage.write(key: "sdb_email", value: userEmail);
      await storage.write(
          key: "sdb_token", value: jsonResponse["access_token"]);

      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('로그인에 실패했습니다');
    }
    //API통신
    //await Future.delayed(Duration(milliseconds: 1000));
  }

  Future<Map<String, dynamic>> loginUser() async {
    String jsonString = await _userLoginFromServer();
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
    var response =
        await http.post(url, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

      const storage = FlutterSecureStorage();
      await storage.write(key: "sdb_email", value: userEmail);
      await storage.write(
          key: "sdb_token", value: jsonResponse["access_token"]);

      return utf8.decode(response.bodyBytes);
    } else {
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
  final bool userGender;
  final String password;

  final List<BodyStat> bodyStats;
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
      required this.userGender,
      required this.password,
      required this.bodyStats});
  Future<String> _userSignUpFromServer() async {
    var formData = Map<String, dynamic>();
    formData["username"] = userName;
    formData["nickname"] = userNickname;
    formData["image"] = userImage;
    formData["height"] = userHeight;
    formData["weight"] = userWeight;
    formData["height_unit"] = userHeightUnit;
    formData["weight_unit"] = userWeightUnit;
    formData["selfIntroduce"] = "";
    formData["favor_exercise"] = [];
    formData["isMan"] = userGender;
    formData["body_stats"] = bodyStats;
    formData["password"] = password;
    formData["phone_number"] = userPhonenumber;
    formData["email"] = userEmail;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/usercreate");
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      String jsonString = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(jsonString);

      const storage = FlutterSecureStorage();
      await storage.write(key: "sdb_email", value: userEmail);
      await storage.write(
          key: "sdb_token", value: jsonResponse["access_token"]);

      return utf8.decode(response.bodyBytes);
    } else if (response.statusCode == 404) {
      showToast("중복된 닉네임 입니다.");
      throw Error();
    } else if (response.statusCode == 403) {
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
    const storage = FlutterSecureStorage();
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
  final String selfIntroduce;
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
      required this.selfIntroduce,
      required this.userFavorExercise});
  Future<String> _userEditFromServer() async {
    var formData = Map<String, dynamic>();
    formData["username"] = userName;
    formData["nickname"] = userNickname;
    formData["image"] = userImage;
    formData["height"] = userHeight;
    formData["weight"] = userWeight;
    formData["height_unit"] = userHeightUnit;
    formData["weight_unit"] = userWeightUnit;
    formData["selfIntroduce"] = selfIntroduce;
    formData["favor_exercise"] = userFavorExercise;

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/user/" + userEmail);
    var response = await http.put(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData));
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

  Future<User?> getUserByEmail() async {
    String jsonString = await _userByEmailFromServer();
    final jsonResponse = json.decode(jsonString);
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
    var formData = Map<String, dynamic>();
    formData["liked_email"] = liked_email;
    formData["email"] = user_email;
    formData["status"] = status;
    formData["disorlike"] = disorlike;

    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/user/likes/${liked_email}");
    var response = await http.patch(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.

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
  Future<String> _userLikeFriendsFromServer() async {
    const storage = FlutterSecureStorage();
    String? user_email = await storage.read(key: "sdb_email");
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/friends/${user_email}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.

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
    if (jsonResponse == null) {
      return null;
    } else {
      User user = User.fromJson(jsonResponse);
      return (user);
    }
  }
}

class UserImageEdit {
  final dynamic file;
  UserImageEdit({required this.file});
  Future<Map<String, dynamic>> _patchUserImageFromServer() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");
    var formData =
        FormData.fromMap({'file': await MultipartFile.fromFile(file)});
    var dio = Dio();
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;
      dio.options.headers["Authorization"] = "Bearer " + token!;

      var response = await dio.post(
        LocalHost.getLocalHost() + '/api/temp/images',
        data: formData,
      );
      return response.data;
    } catch (e) {
      print(e);
      throw Exception('Failed to load post');
    }
  }

  Future<User?> patchUserImage() async {
    var jsonString = await _patchUserImageFromServer();
    // ignore: unnecessary_null_comparison
    if (jsonString == null) {
      return null;
    } else {
      User user = User.fromJson(jsonString);
      return (user);
    }
  }
}

class UserFCMTokenEdit {
  final String fcmToken;
  UserFCMTokenEdit({required this.fcmToken});
  Future<String> _patchUserFCMTokenFromServer() async {
    var formData = Map<String, dynamic>();
    formData["fcm_token"] = fcmToken;
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/v1/user/fcm_token");
    var response = await http.patch(
      url,
      body: json.encode(formData),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${token}',
      },
    );
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.

      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<User?> patchUserFCMToken() async {
    var jsonString = await _patchUserFCMTokenFromServer();

    final jsonResponse = json.decode(jsonString);
    if (jsonResponse == null) {
      return null;
    } else {
      User user = User.fromJson(jsonResponse);
      return (user);
    }
  }
}

class UserDelete {
  Future<String> _deleteUserFromServer() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/userDelete");
    var response = await http.delete(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${token}',
      },
    );
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.

      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<User?> deleteUser() async {
    String jsonString = await _deleteUserFromServer();

    final jsonResponse = json.decode(jsonString);
    if (jsonResponse == null) {
      return null;
    } else {
      User user = User.fromJson(jsonResponse);
      return (user);
    }
  }
}

class UserFind {
  final String phone_number;
  UserFind({required this.phone_number});
  Future<String> _smsByPhoneFromServer() async {
    var formData = Map<String, dynamic>();
    formData["phone_number"] = phone_number;
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/userFind");
    var response = await http.patch(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else if (response.statusCode == 401) {
      showToast("존재 하지 않는 번호입니다.");
      throw Error();
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<User?> findUserSmsImage() async {
    String jsonString = await _smsByPhoneFromServer();
    final jsonResponse = json.decode(jsonString);
    if (jsonResponse == null) {
      return null;
    }
    return null;
  }
}

class UserFindVerification {
  final String phone_number;
  final String verify_code;
  UserFindVerification({required this.phone_number, required this.verify_code});
  Future<String> _smsVerificationFromServer() async {
    var formData = Map<String, dynamic>();
    formData["phone_number"] = phone_number;
    formData["verifyCode"] = verify_code;
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/userFindVerify");
    var response = await http.patch(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else if (response.statusCode == 401) {
      showToast("인증 번호를 확인해주세요.");
      throw Error();
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      showToast("인증 번호를 확인해주세요.");
      throw Exception('Failed to load post');
    }
  }

  Future<User?> findUserSmsImage() async {
    String jsonString = await _smsVerificationFromServer();
    final jsonResponse = json.decode(jsonString);
    if (jsonResponse == null) {
      return null;
    } else {
      User user = User.fromJson(jsonResponse);
      return (user);
    }
  }
}

class UserBodyStatEdit {
  final List<BodyStat> bodyStat;
  UserBodyStatEdit({required this.bodyStat});
  Future<String> _patchUserBodyStatFromServer() async {
    var formData = Map<String, dynamic>();
    formData["body_stats"] = bodyStat;
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/v1/user/bodystat");
    var response = await http.patch(
      url,
      body: json.encode(formData),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${token}',
      },
    );
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.

      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<User?> patchUserBodyStat() async {
    String jsonString = await _patchUserBodyStatFromServer();

    final jsonResponse = json.decode(jsonString);
    if (jsonResponse == null) {
      return null;
    } else {
      User user = User.fromJson(jsonResponse);
      return user;
    }
  }
}
