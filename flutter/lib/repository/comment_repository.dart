import 'dart:async' show Future;
import 'dart:convert';
import 'package:sdb_trainer/localhost.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/model/historydata.dart';

class CommentCreate {
  final int history_id;
  final int reply_id;
  final String writer_email;
  final String writer_nickname;
  final String content;
  CommentCreate(
      {required this.history_id,
      required this.reply_id,
      required this.writer_email,
      required this.writer_nickname,
      required this.content});
  Future<String> _postCommentServer() async {
    var formData = Map<String, dynamic>();
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/comments");
    formData["history_id"] = history_id;
    formData["reply_id"] = reply_id;
    formData["writer_email"] = writer_email;
    formData["writer_nickname"] = writer_nickname;
    formData["content"] = content;
    var response = await http.post(url, body: json.encode(formData));
    print(json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Comment> postComment() async {
    String jsonString = await _postCommentServer();
    final jsonResponse = json.decode(jsonString);
    Comment comment = Comment.fromJson(jsonResponse);
    return (comment);
  }
}

class CommentsAll {
  static Future<String> _getCommentsAllServer() async {
    var url = Uri.parse(LocalHost.getLocalHost() + "/api/comments");
    var response = await http.get(
      url,
    );
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  static Future<CommentList> getCommentsAll() async {
    String jsonString = await _getCommentsAllServer();
    final jsonResponse = json.decode(jsonString);
    CommentList comment = CommentList.fromJson(jsonResponse);
    return (comment);
  }
}

class CommentDelete {
  final int comment_id;
  CommentDelete({required this.comment_id});
  Future<String> _deleteCommentServer() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "sdb_token");
    var formData = Map<String, dynamic>();
    formData["id"] = comment_id;
    var url = Uri.parse(
        LocalHost.getLocalHost() + "/api/comment/" + comment_id.toString());
    var response = await http.delete(url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token}',
        },
        body: json.encode(formData));
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return utf8.decode(response.bodyBytes);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<Comment> deleteComment() async {
    String jsonString = await _deleteCommentServer();
    final jsonResponse = json.decode(jsonString);
    Comment comment = Comment.fromJson(jsonResponse);
    return (comment);
  }
}
