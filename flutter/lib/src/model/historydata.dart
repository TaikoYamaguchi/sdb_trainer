import 'dart:convert';

import 'package:sdb_trainer/src/model/workoutdata.dart';

class SDBdata {
  final int id;
  final String user_email;
  final List<Exercises> exercises;
  final String? date;
  final int new_record;
  final int workout_time;
  final List<dynamic> like;
  String? comment;
  final String? nickname;
  final int comment_length;
  SDBdata(
      {required this.id,
      required this.user_email,
      required this.exercises,
      required this.date,
      required this.new_record,
      required this.workout_time,
      required this.like,
      required this.comment,
      required this.nickname,
      required this.comment_length});

  factory SDBdata.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['exercises'].runtimeType == String
        ? json.decode(parsedJson['exercises']) as List
        : parsedJson['exercises'] as List;

    List<Exercises> exerciseList =
        list.map((i) => Exercises.fromJson(i)).toList();
    return SDBdata(
        id: parsedJson['id'],
        user_email: parsedJson['user_email'],
        exercises: exerciseList,
        date: parsedJson["date"],
        new_record: parsedJson["new_record"],
        workout_time: parsedJson["workout_time"],
        like: parsedJson["like"],
        comment: parsedJson["comment"],
        nickname: parsedJson["nickname"],
        comment_length: parsedJson["comment_length"]);
  }
}

class Comment {
  final int? id;
  final int history_id;
  final int reply_id;
  final String writer_email;
  final String writer_nickname;
  final String content;
  final List<dynamic>? likes;
  final String? comment_created_at;
  final String? comment_modified_at;
  Comment(
      {this.id,
      required this.history_id,
      required this.reply_id,
      required this.writer_email,
      required this.writer_nickname,
      required this.content,
      this.likes,
      this.comment_created_at,
      this.comment_modified_at});

  factory Comment.fromJson(Map<String, dynamic> parsedJson) {
    return Comment(
      id: parsedJson['id'],
      history_id: parsedJson['history_id'],
      reply_id: parsedJson['reply_id'],
      writer_email: parsedJson['writer_email'],
      writer_nickname: parsedJson['writer_nickname'],
      content: parsedJson['content'],
      likes: parsedJson["likes"],
      comment_created_at: parsedJson["comment_created_at"],
      comment_modified_at: parsedJson["comment_modified_at"],
    );
  }
}

class Exercises {
  final String name;
  final List<Sets> sets;
  final double? onerm;
  final double? goal;
  final String? date;
  Exercises(
      {required this.name,
      required this.sets,
      required this.onerm,
      required this.goal,
      required this.date});
  Map toJson() =>
      {"name": name, "sets": sets, "onerm": onerm, "goal": goal, "date": date};
  factory Exercises.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["sets"] as List;
    List<Sets> setList = list.map((i) => Sets.fromJson(i)).toList();
    return Exercises(
        name: parsedJson["name"],
        sets: setList,
        onerm: parsedJson["onerm"],
        goal: parsedJson["goal"],
        date: parsedJson["date"]);
  }
}

class CommentList {
  final List<Comment> comments;

  CommentList({
    required this.comments,
  });

  factory CommentList.fromJson(List<dynamic> parsedJson) {
    List<Comment> comments = <Comment>[];
    comments = parsedJson.map((i) => Comment.fromJson(i)).toList();

    return new CommentList(comments: comments);
  }
}

class SDBdataList {
  final List<SDBdata> sdbdatas;

  SDBdataList({
    required this.sdbdatas,
  });

  factory SDBdataList.fromJson(List<dynamic> parsedJson) {
    List<SDBdata> sdbdatas = <SDBdata>[];
    sdbdatas = parsedJson.map((i) => SDBdata.fromJson(i)).toList();

    return new SDBdataList(sdbdatas: sdbdatas);
  }
}

List<Sets> setslist_his = [
  Sets(index: 0, weight: 0.0, reps: 1, ischecked: true),
  Sets(index: 1, weight: 0.0, reps: 1, ischecked: true),
  Sets(index: 2, weight: 0.0, reps: 1, ischecked: true)
];
