import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileNickname extends StatefulWidget {
  const ProfileNickname({Key? key}) : super(key: key);

  @override
  _ProfileNicknameState createState() => _ProfileNicknameState();
}

class _ProfileNicknameState extends State<ProfileNickname> {
  bool isLoading = false;
  var _userProvider;
  var _hisProvider;
  bool _isNickNameused = false;
  final TextEditingController _userNicknameCtrl =
      TextEditingController(text: "");

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
    var _btnDisabled = false;
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              _btnDisabled == true
                  ? null
                  : [
                      Navigator.of(context).pop(),
                      _btnDisabled = true,
                    ];
            },
          ),
          title: Text(
            "",
            textScaleFactor: 2.5,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _signupProfileWidget() {
    bool btnDisabled = false;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onPanUpdate: (details) {
          if (details.delta.dx > 20 && btnDisabled == false) {
            btnDisabled = true;
            Navigator.of(context).pop();
            print("Dragging in +X direction");
          }
        },
        child: Container(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Text("닉네임 변경",
                            textScaleFactor: 2.7,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.w600)),
                        const Text("닉네임을 수정 할 수 있어요",
                            textScaleFactor: 1.3,
                            style: TextStyle(
                              color: Colors.grey,
                            )),
                        const SizedBox(
                          height: 24,
                        ),
                        _nicknameWidget(),
                        const Expanded(
                          flex: 3,
                          child: SizedBox(),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        _editButton(context),
                      ]))),
        ));
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
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[ ]')), // 공백 필터링
      ],
      controller: _userNicknameCtrl,
      style: TextStyle(color: Theme.of(context).primaryColorLight),
      autofocus: true,
      decoration: InputDecoration(
        filled: true,
        hintText: _userProvider.userdata.nickname,
        hintStyle: TextStyle(color: Theme.of(context).primaryColorLight),
        labelText: _isNickNameused == false ? "닉네임" : "사용 불가 닉네임",
        labelStyle: TextStyle(
            color: _isNickNameused == false
                ? Theme.of(context).primaryColorLight
                : Colors.red),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false
                  ? Theme.of(context).primaryColor
                  : Colors.red,
              width: 3.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false
                  ? Theme.of(context).primaryColor
                  : Colors.red,
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
                color: Theme.of(context).primaryColorLight,
              ),
              padding: const EdgeInsets.all(8.0),
            ),
            onPressed: () => _editCheck(),
            child: Text(isLoading ? 'loggin in.....' : "닉네임 수정",
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).highlightColor))));
  }

  void _editCheck() async {
    const storage = FlutterSecureStorage();
    String? storageToken = await storage.read(key: "sdb_token");
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
                  _userProvider.getdata(storageToken),
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

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }
}
