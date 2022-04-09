import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _bodyStater;
  var _loginState;
  var _signUpState;
  bool isLoading = false;
  TextEditingController _userEmailCtrl = TextEditingController(text: "");
  TextEditingController _userPasswordCtrl = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _userEmailCtrl = TextEditingController(text: "");
    _userPasswordCtrl = TextEditingController(text: "");
    _storageLoginCheck();
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context);
    _loginState = Provider.of<LoginPageProvider>(context);

    return Scaffold(
        body: Container(
      color: Colors.black,
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    Text("SDB 훈련소",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 54,
                            fontWeight: FontWeight.w800)),
                    _emailWidget(),
                    SizedBox(
                      height: 8,
                    ),
                    _passwordWidget(),
                    SizedBox(
                      height: 4,
                    ),
                    _loginButton(context),
                    SizedBox(
                      height: 4,
                    ),
                    _signUpButton(context),
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                  ]))),
    ));
  }

  Widget _emailWidget() {
    return TextFormField(
        controller: _userEmailCtrl,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.email, color: Colors.white),
            labelText: "이메일",
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
            fillColor: Colors.white),
        style: TextStyle(color: Colors.white));
  }

  Widget _passwordWidget() {
    return TextFormField(
        controller: _userPasswordCtrl,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.vpn_key_rounded, color: Colors.white),
            labelText: "비밀번호",
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
            fillColor: Colors.white),
        style: TextStyle(color: Colors.white));
  }

  Widget _loginButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(25, 106, 223, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(25, 106, 223, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => isLoading ? null : _loginCheck(),
            child: Text(isLoading ? 'loggin in.....' : "로그인",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  Widget _signUpButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => isLoading ? null : _loginState.changeSignup(true),
            child: Text(isLoading ? 'loggin in.....' : "회원가입",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _loginCheck() async {
    final storage = FlutterSecureStorage();
    String? storageEmail = await storage.read(key: "sdb_email");
    if (storageEmail != null &&
        storageEmail != "" &&
        storageEmail == _userEmailCtrl.text) {
      _bodyStater.change(0);
      _loginState.change(true);
    } else {
      UserLogin(
              userEmail: _userEmailCtrl.text, password: _userPasswordCtrl.text)
          .loginUser()
          .then((token) => token["access_token"] != null
              ? {_bodyStater.change(0), _loginState.change(true)}
              : showToast("아이디와 비밀번호를 확인해주세요"));
    }
  }

  void _storageLoginCheck() async {
    final storage = FlutterSecureStorage();
    String? storageEmail = await storage.read(key: "sdb_email");
    print(storageEmail);
    if (storageEmail != null && storageEmail != "") {
      _bodyStater.change(0);
      _loginState.change(true);
    }
  }
}
