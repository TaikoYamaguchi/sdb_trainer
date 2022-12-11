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
  var _userProvider;
  var _hisProvider;
  bool _isNickNameused = false;
  TextEditingController _userNicknameCtrl = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _hisProvider = Provider.of<HistorydataProvider>(context, listen: false);
    return Scaffold(appBar: _appbarWidget(), body: _signupProfileWidget());
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          title: Text(
            "",
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          backgroundColor: Color(0xFF101012),
        ));
  }

  Widget _signupProfileWidget() {
    return Container(
      color: Color(0xFF101012),
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
                            fontWeight: FontWeight.w600)),
                    Text("닉네임을 수정 할 수 있어요",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        )),
                    SizedBox(
                      height: 24,
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
        if (_userProvider.userFriendsAll.userdatas
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
        filled: true,
        hintText: _userProvider.userdata.nickname,
        hintStyle: TextStyle(color: Colors.white),
        labelText: _isNickNameused == false ? "닉네임" : "사용 불가 닉네임",
        labelStyle: TextStyle(
            color: _isNickNameused == false ? Colors.white : Colors.red),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false ? Colors.white : Colors.red,
              width: 3.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false ? Colors.white : Colors.red,
              width: 3.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _editButton(context) {
    return SizedBox(
        height: 56,
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Colors.white,
              ),
              disabledForegroundColor: Color(0xFF101012),
              padding: EdgeInsets.all(8.0),
            ),
            onPressed: () => _editCheck(),
            child: Text(isLoading ? 'loggin in.....' : "닉네임 수정",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _editCheck() async {
    if (_userNicknameCtrl.text != "" && _isNickNameused == false) {
      UserEdit(
              userEmail: _userProvider.userdata.email,
              userName: _userProvider.userdata.username,
              userNickname: _userNicknameCtrl.text,
              userHeight: _userProvider.userdata.height.toString(),
              userWeight: _userProvider.userdata.weight.toString(),
              userHeightUnit: _userProvider.userdata.height_unit,
              userWeightUnit: _userProvider.userdata.weight_unit,
              userImage: _userProvider.userdata.image,
              userFavorExercise: _userProvider.userdata.favor_exercise)
          .editUser()
          .then((data) => data["username"] != null
              ? {
                  showToast("수정 완료"),
                  _userProvider.getdata(),
                  _hisProvider.getdata(),
                  _hisProvider.getHistorydataAll(),
                  _hisProvider.getCommentAll(),
                  Navigator.pop(context)
                }
              : showToast("수정할 수 없습니다"));
    } else {
      showToast("닉네임을 입력 및 수정해주세요");
    }
  }
}
