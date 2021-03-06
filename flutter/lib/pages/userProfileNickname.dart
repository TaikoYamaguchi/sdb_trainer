import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class ProfileNickname extends StatefulWidget {
  @override
  _ProfileNicknameState createState() => _ProfileNicknameState();
}

class _ProfileNicknameState extends State<ProfileNickname> {
  bool isLoading = false;
  var _userdataProvider;
  var _historydataProvider;
  bool _isNickNameused = false;
  TextEditingController _userNicknameCtrl = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _historydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    return Scaffold(appBar: _appbarWidget(), body: _signupProfileWidget());
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text(
        "",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _signupProfileWidget() {
    return Container(
      color: Colors.black,
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ),
                    Text("닉네임 변경",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                    SizedBox(
                      height: 8,
                    ),
                    _nicknameWidget(),
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    _editButton(context),
                  ]))),
    );
  }

  Widget _nicknameWidget() {
    return TextFormField(
      onChanged: (text) {
        if (_userdataProvider.userFriendsAll.userdatas
                .where((user) {
                  if (user.nickname == text.toString()) {
                    return true;
                  } else {
                    return false;
                  }
                })
                .toList()
                .length ==
            0) {
          setState(() {
            _isNickNameused = false;
          });
        } else
          setState(() {
            _isNickNameused = true;
          });
      },
      controller: _userNicknameCtrl,
      style: TextStyle(color: Colors.white),
      autofocus: true,
      decoration: InputDecoration(
        hintText: _userdataProvider.userdata.nickname,
        hintStyle: TextStyle(color: Colors.white),
        labelText: _isNickNameused == false ? "닉네임" : "사용 불가 닉네임",
        labelStyle: TextStyle(
            color: _isNickNameused == false ? Colors.white : Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false ? Colors.white : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false ? Colors.white : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _editButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => _editCheck(),
            child: Text(isLoading ? 'loggin in.....' : "닉네임 수정",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _editCheck() async {
    if (_userNicknameCtrl.text != "" && _isNickNameused == false) {
      UserEdit(
              userEmail: _userdataProvider.userdata.email,
              userName: _userdataProvider.userdata.username,
              userNickname: _userNicknameCtrl.text,
              userHeight: _userdataProvider.userdata.height.toString(),
              userWeight: _userdataProvider.userdata.weight.toString(),
              userHeightUnit: _userdataProvider.userdata.height_unit,
              userWeightUnit: _userdataProvider.userdata.weight_unit,
              userImage: _userdataProvider.userdata.image,
              userFavorExercise: _userdataProvider.userdata.favor_exercise)
          .editUser()
          .then((data) => data["username"] != null
              ? {
                  showToast("수정 완료"),
                  _userdataProvider.getdata(),
                  _historydataProvider.getdata(),
                  _historydataProvider.getHistorydataAll(),
                  _historydataProvider.getCommentAll(),
                  Navigator.pop(context)
                }
              : showToast("수정할 수 없습니다"));
    } else {
      showToast("닉네임을 입력 및 수정해주세요");
    }
  }
}
