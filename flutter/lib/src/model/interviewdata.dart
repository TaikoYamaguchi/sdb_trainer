class InterviewData {
  final int id;
  final String user_email;
  final String user_nickname;
  final String progress;
  final String title;
  final String content;
  final List<dynamic> like;
  final String? date;
  final List<dynamic>? tags;
  final int? reply_id;
  InterviewData(
      {required this.id,
      required this.user_email,
      required this.user_nickname,
      required this.progress,
      required this.title,
      required this.content,
      required this.like,
      required this.date,
      required this.tags,
      required this.reply_id});

  Map toJson() => {
        "id": id,
        "user_email": user_email,
        "user_nickname": user_nickname,
        "progress": progress,
        "title": title,
        "content": content,
        "like": like,
        "date": date,
        "tags": tags,
        "reply_id": reply_id,
      };

  factory InterviewData.fromJson(Map<String, dynamic> parsedJson) {
    return InterviewData(
      id: parsedJson['id'],
      user_email: parsedJson['user_email'],
      user_nickname: parsedJson['user_nickname'],
      progress: parsedJson['progress'],
      title: parsedJson['title'],
      content: parsedJson['content'],
      like: parsedJson["like"],
      date: parsedJson["date"],
      tags: parsedJson["tags"],
      reply_id: parsedJson["reply_id"],
    );
  }
}

class InterviewDataList {
  final List<InterviewData> interviewDatas;

  InterviewDataList({
    required this.interviewDatas,
  });

  factory InterviewDataList.fromJson(List<dynamic> parsedJson) {
    List<InterviewData> interviewDatas = <InterviewData>[];
    interviewDatas = parsedJson.map((i) => InterviewData.fromJson(i)).toList();

    return new InterviewDataList(interviewDatas: interviewDatas);
  }
}
