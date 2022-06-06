import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class ProfileNickname extends StatefulWidget {
  @override
  _ProfileNicknameState createState() => _ProfileNicknameState();
}

class _ProfileNicknameState extends State<ProfileNickname> {
  bool isLoading = false;
  var _userdataProvider;
  var _userNicknameCtrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context);
    _userNicknameCtrl =
        TextEditingController(text: _userdataProvider.userdata.nickname);
    _userNicknameCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _userNicknameCtrl.text.length));
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
      controller: _userNicknameCtrl,
      style: TextStyle(color: Colors.white),
      autofocus: true,
      decoration: InputDecoration(
        labelText: "닉네임",
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
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
    print(_userNicknameCtrl.text);
    if (_userNicknameCtrl.text != "") {
      UserEdit(
              userEmail: _userdataProvider.userdata.email,
              userName: _userdataProvider.userdata.username,
              userNickname: _userNicknameCtrl.text,
              userHeight: _userdataProvider.userdata.height.toString(),
              userWeight: _userdataProvider.userdata.weight.toString(),
              userHeightUnit: _userdataProvider.userdata.height_unit,
              userWeightUnit: _userdataProvider.userdata.weight_unit,
              userImage: "",
              password: "",
              userFavorExercise: []
      )
          .editUser()
          .then((data) => data["username"] != null
              ? {
                  showToast("수정 완료"),
                  _userdataProvider.getdata(),
                  Navigator.pop(context)
                }
              : showToast("수정할 수 없습니다"));
    } else {
      showToast("닉네임을 입력해주세요");
    }
  }
}
