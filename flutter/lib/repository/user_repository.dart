import 'dart:async' show Future;
import 'dart:convert';
import '../src/model/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:sdb_trainer/localhost.dart';

class UserService {
  static Future<String> _loadUserdataFromServer() async {
    var url =
        Uri.parse(LocalHost.getLocalHost() + "/api/getuser/cksdnr1@gmail.com");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      print(response.body);
      print(utf8.decode(response.bodyBytes));
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
    print(user);
    return (user);
  }
}
