import 'dart:async' show Future;
import 'dart:convert';
import '../src/model/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:sdb_trainer/localhost.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  static Future<String> _loadUserdataFromServer() async {
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/getuser/cksdnr1@gmail.com");
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
