import 'dart:async' show Future;
import 'dart:convert';
import '../src/model/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:sdb_trainer/localhost.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  static Future<String> _loadUserdataFromServer() async {
    final storage = new FlutterSecureStorage();
    String? user_email = await storage.read(key: "sdb_email");
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/getuser/" + user_email!);
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
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
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
  UserEdit(
      {required this.userEmail,
      required this.userName,
      required this.userNickname,
      required this.userHeight,
      required this.userWeight,
      required this.userHeightUnit,
      required this.userWeightUnit,
      required this.userImage,
      required this.password});
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

    var url = Uri.parse(LocalHost.getLocalHost() + "/api/users/" + userEmail);
    var response = await http.put(url, body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Map<String, dynamic>> editUser() async {
    String jsonString = await _userEditFromServer();
    final jsonResponse = json.decode(jsonString);
    return (jsonResponse);
  }
}
