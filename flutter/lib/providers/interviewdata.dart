import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/interview_repository.dart';
import 'package:sdb_trainer/repository/comment_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InterviewdataProvider extends ChangeNotifier {
  var _interviewdataAll;
  List<String> _selectedTags = [];
  get interviewdataAll => _interviewdataAll;
  get selectedTags => _selectedTags;

  getInterviewdataFirst() {
    InterviewdataFirst.loadInterviewDataFirst().then((value) {
      _interviewdataAll = value;
      print("provider");
      print(value);

      notifyListeners();
    });
  }

  addInterviewdataPage(InterviewDataList) {
    _interviewdataAll.interviewDatas.addAll(InterviewDataList.interviewDatas);
    notifyListeners();
  }

  patchInterviewLikedata(interviewData, email, status) {
    if (status == "remove") {
      _interviewdataAll.interviewDatas.indexWhere((interviewData) {
        if (interviewData.id == interviewData.id) {
          interviewData.like.remove(email);
          return true;
        } else {
          return false;
        }
      });

      notifyListeners();
    } else if (status == "append") {
      _interviewdataAll.interviewDatas.indexWhere((interviewData) {
        if (interviewData.id == interviewData.id) {
          interviewData.like.add(email);
          return true;
        } else {
          return false;
        }
      });
      notifyListeners();
    }
  }

  patchInterviewStatusdata(interviewData, email, status) {
    _interviewdataAll.interviewDatas.indexWhere((interview) {
      if (interview.id == interviewData.id) {
        interview.progress = status;
        return true;
      } else {
        return false;
      }
    });

    notifyListeners();
  }

  deleteInterviewdata(interview_id) {
    _interviewdataAll.interviewDatas
        .removeAt(_interviewdataAll.interviewDatas.indexWhere((interviewData) {
      if (interviewData.id == interview_id) {
        return true;
      } else {
        return false;
      }
    }));

    notifyListeners();
  }

  addTag(String tag) {
    _selectedTags.add(tag);

    notifyListeners();
  }

  removeTag(String tag) {
    _selectedTags.removeWhere((element) => element == tag);

    notifyListeners();
  }

  initTags() {
    _selectedTags = [];

    notifyListeners();
  }
}
