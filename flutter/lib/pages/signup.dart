import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<SignUpPage> {
  var _bodyStater;
  var _loginState;
  bool isLoading = false;
  TextEditingController _userEmailCtrl = TextEditingController(text: "");
  TextEditingController _userPasswordCtrl = TextEditingController(text: "");
  TextEditingController _userNameCtrl = TextEditingController(text: "unknown");
  TextEditingController _userNicknameCtrl = TextEditingController(text: "");
  TextEditingController _userImageCtrl = TextEditingController(text: "");
  TextEditingController _userHeightCtrl = TextEditingController(text: "");
  TextEditingController _userWeightCtrl = TextEditingController(text: "");
  TextEditingController _userHeightUnitCtrl = TextEditingController(text: "cm");
  TextEditingController _userWeightUnitCtrl = TextEditingController(text: "kg");
  TextEditingController _userPhoneNumberCtrl = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _userEmailCtrl = TextEditingController(text: "");
    _userPasswordCtrl = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context);
    _loginState = Provider.of<LoginPageProvider>(context);

    return Scaffold(
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: SizedBox(),
                      ),
                      _emailWidget(),
                      SizedBox(
                        height: 8,
                      ),
                      _nicknameWidget(),
                      SizedBox(
                        height: 8,
                      ),
                      _passwordWidget(),
                      SizedBox(
                        height: 8,
                      ),
                      _phoneNumberWidget(),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(child: _heightWidget()),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(child: _heightUnitWidget())
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(child: _weightWidget()),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(child: _weightUnitWidget())
                        ],
                      ),
                      _signUpButton(context),
                      _loginButton(context),
                      Expanded(
                        flex: 3,
                        child: SizedBox(),
                      ),
                    ]))));
  }

  Widget _emailWidget() {
    return TextFormField(
      controller: _userEmailCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "Email",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _nameWidget() {
    return TextFormField(
      controller: _userNameCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "이름",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _nicknameWidget() {
    return TextFormField(
      controller: _userNicknameCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "닉네임",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _heightWidget() {
    return TextFormField(
      controller: _userHeightCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "키",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _weightWidget() {
    return TextFormField(
      controller: _userWeightCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "몸무게",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _weightUnitWidget() {
    return TextFormField(
      controller: _userWeightUnitCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "kg",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _heightUnitWidget() {
    return TextFormField(
      controller: _userHeightUnitCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "cm",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _phoneNumberWidget() {
    return TextFormField(
      controller: _userPhoneNumberCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "전화번호",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _imageWidget() {
    return TextFormField(
      controller: _userImageCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: "이미지",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _passwordWidget() {
    return TextFormField(
      controller: _userPasswordCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key_rounded),
        labelText: "Password",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _signUpButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Colors.purple,
            textColor: Colors.white,
            disabledColor: Colors.purple,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => _signUpCheck(),
            child: Text(isLoading ? 'loggin in.....' : "회원가입",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _signUpCheck() async {
    UserSignUp(
            userEmail: _userEmailCtrl.text,
            userName: _userNameCtrl.text,
            userNickname: _userNicknameCtrl.text,
            userHeight: _userHeightCtrl.text,
            userWeight: _userWeightCtrl.text,
            userHeightUnit: _userHeightUnitCtrl.text,
            userWeightUnit: _userWeightUnitCtrl.text,
            userPhonenumber: _userPhoneNumberCtrl.text,
            userImage: _userImageCtrl.text,
            password: _userPasswordCtrl.text)
        .signUpUser()
        .then((data) => data["username"] != null
            ? UserLogin(
                    userEmail: _userEmailCtrl.text,
                    password: _userPasswordCtrl.text)
                .loginUser()
                .then((token) => token["access_token"] != null
                    ? {_bodyStater.change(0), _loginState.change(true)}
                    : showToast("아이디와 비밀번호를 확인해주세요"))
            : showToast("회원가입을 할 수 없습니다"));
  }

  Widget _loginButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Colors.blueAccent,
            textColor: Colors.white,
            disabledColor: Colors.blueAccent,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => isLoading ? null : _loginState.changeSignup(false),
            child: Text(isLoading ? 'loggin in.....' : "로그인하기",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }
}
