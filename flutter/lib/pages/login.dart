import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _bodyStater;
  var _loginState;
  var _signUpState;
  var _userProvider;
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
    _userProvider = Provider.of<UserdataProvider>(context);

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
                      height: 10,
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
                    _loginWithKakao(context),
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

  Future<void> _loginButtonPressed() async {
    if (await AuthApi.instance.hasToken()) {
      try {
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        print('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
        try {
          User user = await UserApi.instance.me();
          print('사용자 정보 요청 성공'
              '\n회원번호: ${user.id}'
              '\n이름: ${user.kakaoAccount?.name}'
              '\n닉네임: ${user.kakaoAccount?.name}'
              '\n이미지: ${user.properties?["profile_image"]}'
              '\n프로필: ${user.kakaoAccount?.profile}'
              '\n성별: ${user.kakaoAccount?.gender}'
              '\n이메일: ${user.kakaoAccount?.email}');
          _userEmailCtrl.text = user.kakaoAccount!.email!;
          _userProvider.setUserKakaoEmail(user.kakaoAccount!.email!);
          _userProvider.setUserKakaoImageUrl(user.properties?["profile_image"]);
          _userProvider.setUserKakaoName(user.kakaoAccount?.name);
          _userProvider.setUserKakaoGender(user.kakaoAccount?.gender);
          _userPasswordCtrl.text = user.kakaoAccount!.email!;
          _loginkakaoCheck();
        } catch (error) {
          print('사용자 정보 요청 실패 $error');
        }
      } catch (error) {
        if (error is KakaoException && error.isInvalidTokenError()) {
          print('토큰 만료 $error');
        } else {
          print('토큰 정보 조회 실패 $error');
        }

        try {
          // 카카오 계정으로 로그인
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('로그인 성공 ${token.accessToken}');
          _loginkakaoCheck();
        } catch (error) {
          print('로그인 실패 $error');
        }
      }
    } else {
      print('발급된 토큰 없음');
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();

        User user = await UserApi.instance.me();

        _userEmailCtrl.text = user.kakaoAccount!.email!;
        _userProvider.setUserKakaoEmail(user.kakaoAccount!.email!);
        _userProvider.setUserKakaoImageUrl(user.properties?["profile_image"]);
        _userProvider.setUserKakaoName(user.kakaoAccount?.name);
        _userProvider.setUserKakaoGender(user.kakaoAccount?.gender);
        _userPasswordCtrl.text = user.kakaoAccount!.email!;
        print('로그인 성공 ${token.accessToken}');
        _loginkakaoCheck();
      } catch (error) {
        print('로그인 실패 $error');
      }
    }
    print("yesss");
  }

  Widget _loginWithKakao(context) {
    return InkWell(
      child: IconButton(
        icon: Image.asset(
          'assets/svg/kakao_login_large_wide.png',
        ),
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width, minHeight: 70),
        onPressed: () {
          _loginButtonPressed();
        },
      ),
    );
  }

  Widget _passwordWidget() {
    return TextFormField(
        controller: _userPasswordCtrl,
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        obscuringCharacter: "*",
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
        height: 53,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
          child: FlatButton(
              color: Color.fromRGBO(25, 106, 223, 20),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              disabledColor: Color.fromRGBO(25, 106, 223, 20),
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              onPressed: () => isLoading ? null : _loginCheck(),
              child: Text(isLoading ? 'loggin in.....' : "로그인",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w400))),
        ));
  }

  Widget _signUpButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 53,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
          child: FlatButton(
              color: Color.fromRGBO(246, 58, 64, 20),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              disabledColor: Color.fromRGBO(246, 58, 64, 20),
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              onPressed: () =>
                  isLoading ? null : _loginState.changeSignup(true),
              child: Text(isLoading ? 'loggin in.....' : "회원가입",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w400))),
        ));
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

  void _loginkakaoCheck() async {
    final storage = FlutterSecureStorage();
    String? storageEmail = await storage.read(key: "sdb_email");
    if (storageEmail != null &&
        storageEmail != "" &&
        storageEmail == _userEmailCtrl.text) {
      _bodyStater.change(0);
      _loginState.change(true);
    } else {
      try {
        print(_userEmailCtrl.text);
        print(_userPasswordCtrl.text);
        var order = await UserLogin(
                userEmail: _userEmailCtrl.text,
                password: _userPasswordCtrl.text)
            .loginUser()
            .then((token) => token["access_token"] != null
                ? {_bodyStater.change(0), _loginState.change(true)}
                : _loginState.changeSignup(true));
      } catch (error) {
        print(error);
        _loginState.changeSignup(true);
        showToast("회원가입 페이지로 이동할게요");
      }
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
