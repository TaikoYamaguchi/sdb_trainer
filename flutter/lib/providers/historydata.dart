import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/comment_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistorydataProvider extends ChangeNotifier {
  var _historydata;
  var _historydataAll;
  var _historydataAllforChange;
  var _historydataFriends;
  var _historydataUserEmail;
  var _commentAll;
  int _isUploaded = 0;
  get isUploaded => _isUploaded;
  get historydata => _historydata;
  get historydataAll => _historydataAll;
  get historydataAllforChange => _historydataAllforChange;

  get historydataFriends => _historydataFriends;
  get historydataUserEmail => _historydataUserEmail;
  get commentAll => _commentAll;

  setUploadStatus(int status) {
    _isUploaded = status;
    notifyListeners();
  }

  getdata() async {
    await ExerciseService.loadSDBdata().then((value) {
      _historydata = value;

      notifyListeners();
      return _historydata;
    });
  }

  getHistorydataAll() {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    HistorydataAll.loadSDBdataAll().then((value) {
      _historydataAll = value;
      binding.addPostFrameCallback((_) async {
        BuildContext context = binding.rootElement!;
        for (var history in value.sdbdatas) {
          if (history.image!.isEmpty != true) {
            for (var image in history.image!) {
              precacheImage(CachedNetworkImageProvider(image), context);
            }
          }
        }
      });
      notifyListeners();
    });
  }

  getHistorydataAllforChange() async {
    await HistorydataAllGetforChange.loadSDBdataAllchange().then((value) {
      _historydataAllforChange = value;

      notifyListeners();
      return _historydataAllforChange;
    });
  }

  addHistorydataPage(SDBdataList) {
    _historydataAll.sdbdatas.addAll(SDBdataList.sdbdatas);
    notifyListeners();
  }

  getCommentAll() {
    CommentsAll.getCommentsAll().then((value) {
      _commentAll = value;
      notifyListeners();
    });
  }

  addCommentAll(Comment) {
    _commentAll.comments.add(Comment);
    notifyListeners();
  }

  deleteCommentAll(Comment) {
    _commentAll.comments.removeAt(_commentAll.comments.indexWhere((comment) {
      if (comment.id == Comment.id) {
        return true;
      } else {
        return false;
      }
    }));
    notifyListeners();
  }

  getFriendsHistorydata() {
    HistorydataFriends().loadSDBdataFriends().then((value) {
      _historydataFriends = value;
      notifyListeners();
    });
  }

  getUserEmailHistorydata(user_email) {
    _historydataUserEmail = [];
    HistorydataUserEmail(user_email: user_email)
        .loadSDBdataUserEmail()
        .then((value) {
      _historydataUserEmail = value;
      notifyListeners();
    });
  }

  patchHistoryLikedata(SDBdata, email, status) {
    if (status == "remove") {
      _historydata.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.remove(email);
          return true;
        } else {
          return false;
        }
      });
      _historydataFriends.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.remove(email);
          return true;
        } else {
          return false;
        }
      });
      _historydataAll.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.remove(email);
          return true;
        } else {
          return false;
        }
      });
      try {
        _historydataUserEmail.sdbdatas.indexWhere((sdbdata) {
          if (sdbdata.id == SDBdata.id) {
            sdbdata.like.remove(email);
            return true;
          } else {
            return false;
          }
        });
      } catch (e) {}

      notifyListeners();
    } else if (status == "append") {
      _historydata.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.add(email);
          return true;
        } else {
          return false;
        }
      });
      _historydataFriends.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.add(email);
          return true;
        } else {
          return false;
        }
      });
      _historydataAll.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.like.add(email);
          return true;
        } else {
          return false;
        }
      });
      try {
        _historydataUserEmail.sdbdatas.indexWhere((sdbdata) {
          if (sdbdata.id == SDBdata.id) {
            sdbdata.like.add(email);
            return true;
          } else {
            return false;
          }
        });
      } catch (e) {}
      notifyListeners();
    }
  }

  patchHistoryCommentdata(SDBdata, comment) {
    _historydata.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == SDBdata.id) {
        sdbdata.comment = comment;
        return true;
      } else {
        return false;
      }
    });
    _historydataFriends.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == SDBdata.id) {
        sdbdata.comment = comment;
        return true;
      } else {
        return false;
      }
    });
    _historydataAll.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == SDBdata.id) {
        sdbdata.comment = comment;
        return true;
      } else {
        return false;
      }
    });
    try {
      _historydataUserEmail.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.comment = comment;
          return true;
        } else {
          return false;
        }
      });
    } catch (e) {}

    notifyListeners();
  }

  patchHistoryExdata(history_id, exercises) {
    _historydata.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == history_id) {
        sdbdata.exercises = exercises;
        return true;
      } else {
        return false;
      }
    });

    _historydataAll.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == history_id) {
        sdbdata.exercises = exercises;
        return true;
      } else {
        return false;
      }
    });

    notifyListeners();
  }

  patchHistoryVisible(SDBdata, bool status) {
    _historydataFriends.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == SDBdata.id) {
        sdbdata.isVisible = status;
        return true;
      } else {
        return false;
      }
    });
    _historydataAll.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == SDBdata.id) {
        sdbdata.isVisible = status;
        return true;
      } else {
        return false;
      }
    });

    _historydata.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == SDBdata.id) {
        sdbdata.isVisible = status;
        return true;
      } else {
        return false;
      }
    });
    try {
      _historydataUserEmail.sdbdatas.indexWhere((sdbdata) {
        if (sdbdata.id == SDBdata.id) {
          sdbdata.isVisible = status;
          return true;
        } else {
          return false;
        }
      });
    } catch (e) {}

    notifyListeners();
  }

  deleteHistorydata(history_id) {
    _historydataAll.sdbdatas
        .removeAt(_historydataAll.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == history_id) {
        return true;
      } else {
        return false;
      }
    }));

    _historydata.sdbdatas.removeAt(_historydata.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == history_id) {
        return true;
      } else {
        return false;
      }
    }));
    notifyListeners();
  }

  deleteExercisedata(history_id, exercise_index) {
    _historydataAll
        .sdbdatas[_historydataAll.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == history_id) {
        return true;
      } else {
        return false;
      }
    })]
        .exercises
        .removeAt(exercise_index);

    _historydata
        .sdbdatas[_historydata.sdbdatas.indexWhere((sdbdata) {
      if (sdbdata.id == history_id) {
        return true;
      } else {
        return false;
      }
    })]
        .exercises
        .removeAt(exercise_index);
    notifyListeners();
  }
}
