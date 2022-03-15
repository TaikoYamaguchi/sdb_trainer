import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  TextEditingController _userEmailCtrl = TextEditingController(text: "");
  TextEditingController _userPasswordCtrl = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _userEmailCtrl = TextEditingController(text: "");
    _userPasswordCtrl = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
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
                      _passwordWidget(),
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

  Widget _loginButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Colors.purple,
            textColor: Colors.white,
            disabledColor: Colors.purple,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => isLoading ? null : _loginCheck(),
            child: Text(isLoading ? 'loggin in.....' : "login",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _loginCheck() async {
    final storage = FlutterSecureStorage();
    String? storagePass = await storage.read(key: _userEmailCtrl.text);
    if (storagePass != null &&
        storagePass != "" &&
        storagePass == _userPasswordCtrl.text) {
      String? userNickName =
          await storage.read(key: '${_userEmailCtrl.text}_$storagePass');
      storage.write(key: userNickName!, value: STATUS_LOGIN);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => Home()));
    } else {
      showToast('아이디 혹 비밀번호를 확인 바랍니다');
    }
  }
}
