import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/pages/userFind.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/src/utils/firebase_fcm.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _bodyStater;
  var _loginState;
  var _signUpState;
  var _userProvider;
  var _exercisesdataProvider;
  bool isLoading = false;
  bool _isEmailLogin = false;
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
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);

    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);

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
                    child: SizedBox(
                      height: 6,
                    ),
                  ),
                  Text("SUPERO",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.w800)),
                  _isEmailLogin ? _emailWidget() : Container(),
                  SizedBox(
                    height: 8,
                  ),
                  _isEmailLogin ? _passwordWidget() : Container(),
                  SizedBox(
                    height: 14,
                  ),
                  _isEmailLogin ? _loginButton(context) : Container(),
                  SizedBox(
                    height: 14,
                  ),
                  _isEmailLogin ? _signUpButton(context) : Container(),
                  _isEmailLogin
                      ? SizedBox(
                          height: 6,
                        )
                      : Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 6,
                          ),
                        ),
                  _loginWithKakao(context),
                  _loginWithGoogle(context),
                  _emailLoginButton(context),
                  _isEmailLogin ? _findUser(context) : Container(),
                ]),
          ))),
    );
  }

  Widget _findUser(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Colors.black,
            textColor: Colors.white,
            disabledColor: Colors.black,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => isLoading
                ? null
                : Navigator.push(
                    context,
                    Transition(
                        child: UserFindPage(),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT)),
            child: Text(isLoading ? 'loading in.....' : "계정을 잊어버리셨나요?",
                style: TextStyle(fontSize: 14.0, color: Colors.grey))));
  }

  Widget _emailLoginButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Colors.black,
            textColor: Colors.grey,
            disabledColor: Colors.black,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(4.0),
            splashColor: Colors.blueAccent,
            onPressed: () => isLoading
                ? null
                : setState(() {
                    _isEmailLogin = !_isEmailLogin;
                  }),
            child: Text(_isEmailLogin ? '홈으로 돌아가기' : "이메일로 로그인 하기",
                style: TextStyle(fontSize: 14.0, color: Colors.grey))));
  }

  Widget _emailWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
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
          style: TextStyle(color: Colors.white)),
    );
  }

  Future<void> _loginButtonPressed() async {
    if (await AuthApi.instance.hasToken()) {
      print("yeeeeeeeeeeeeeeeeeeeeeeeeees");
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
      print("yeeeeeeeeeeeeeeeeeeeeeeeeees");
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

  Widget _loginWithGoogle(context) {
    return InkWell(
      child: IconButton(
        icon: Image.asset(
          'assets/svg/google_login_large_wide.png',
        ),
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width, minHeight: 70),
        onPressed: () {
          _loginGooglePressed();
        },
      ),
    );
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  Future<void> _loginGooglePressed() async {
    try {
      await _googleSignIn.signIn();
      GoogleSignInAccount? user = _googleSignIn.currentUser;
      if (user != null) {
        try {
          _userEmailCtrl.text = user.email;
          _userProvider.setUserKakaoEmail(user.email);
          _userProvider.setUserKakaoImageUrl(user.photoUrl);
          _userProvider.setUserKakaoName(user.displayName);

          _loginkakaoCheck();
        } catch (error) {
          print('사용자 정보 요청 실패 $error');
        }
      } else {
        _loginkakaoCheck();
      }
    } catch (error) {
      print(error);
    }
  }

  Widget _passwordWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
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
          style: TextStyle(color: Colors.white)),
    );
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
    try {
      String? storageEmail = await storage.read(key: "sdb_email");
      if (storageEmail != null &&
          storageEmail != "" &&
          storageEmail == _userEmailCtrl.text) {
        _bodyStater.change(0);
        _loginState.change(true);
        fcmSetting();
        initialProviderGet();
      } else {
        UserLogin(
                userEmail: _userEmailCtrl.text,
                password: _userPasswordCtrl.text)
            .loginUser()
            .then((token) => token["access_token"] != null
                ? {
                    _bodyStater.change(0),
                    _loginState.change(true),
                    fcmSetting(),
                    initialProviderGet()
                  }
                : showToast("아이디와 비밀번호를 확인해주세요"));
      }
    } catch (e) {
      UserLogin(
              userEmail: _userEmailCtrl.text, password: _userPasswordCtrl.text)
          .loginUser()
          .then((token) => token["access_token"] != null
              ? {
                  _bodyStater.change(0),
                  _loginState.change(true),
                  fcmSetting(),
                  initialProviderGet()
                }
              : showToast("아이디와 비밀번호를 확인해주세요"));
    }
  }

  void _loginkakaoCheck() async {
    final storage = FlutterSecureStorage();
    try {
      String? storageEmail = await storage.read(key: "sdb_email");
      print(storageEmail);
      if (storageEmail != null &&
          storageEmail != "" &&
          storageEmail == _userEmailCtrl.text) {
        print(storageEmail);
        _bodyStater.change(0);
        _loginState.change(true);

        fcmSetting();
        initialProviderGet();
      } else {
        try {
          var order = await UserLoginKakao(
            userEmail: _userEmailCtrl.text,
          ).loginKakaoUser().then((token) => token["access_token"] != null
              ? {
                  print(_userEmailCtrl.text),
                  _bodyStater.change(0),
                  _loginState.change(true),
                  fcmSetting(),
                  initialProviderGet()
                }
              : _loginState.changeSignup(true));
        } catch (error) {
          print(error);
          _loginState.changeSignup(true);
          showToast("회원가입 페이지로 이동할게요");
        }
      }
    } catch (e) {
      try {
        var order = await UserLoginKakao(
          userEmail: _userEmailCtrl.text,
        ).loginKakaoUser().then((token) => token["access_token"] != null
            ? {
                print(_userEmailCtrl.text),
                _bodyStater.change(0),
                _loginState.change(true),
                fcmSetting(),
                initialProviderGet()
              }
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
    if (storageEmail != null && storageEmail != "") {
      _bodyStater.change(0);
      _loginState.change(true);

      fcmSetting();
      initialProviderGet();
    }
  }

  void _storageInitialExerciseCheck() async {
    final storage = FlutterSecureStorage();
    try {
      String? storageExerciseList = await storage.read(key: "sdb_HomeExList");
      if (storageExerciseList != null && storageExerciseList != "") {
        _exercisesdataProvider.putHomeExList(jsonDecode(storageExerciseList));
        print(_exercisesdataProvider.homeExList);
      } else {
        print("스쿼트트트");
        List<String> listViewerBuilderString = ['스쿼트', '데드리프트', '벤치프레스'];
        await storage.write(
            key: 'sdb_HomeExList', value: jsonEncode(listViewerBuilderString));
        _exercisesdataProvider.putHomeExList(listViewerBuilderString);
      }
    } catch (e) {
      print("스쿼트트트");
      List<String> listViewerBuilderString = ['스쿼트', '데드리프트', '벤치프레스'];
      _exercisesdataProvider.putHomeExList(listViewerBuilderString);
      await storage.write(
          key: 'sdb_HomeExList', value: jsonEncode(listViewerBuilderString));
    }
  }

  void initialProviderGet() async {
    _storageInitialExerciseCheck();
    final _initUserdataProvider =
        Provider.of<UserdataProvider>(context, listen: false);
    final _initHistorydataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);

    final _initExercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    final _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    final _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    final _PrefsProvider = Provider.of<PrefsProvider>(context, listen: false);
    await [
      _initUserdataProvider.getdata(),
      _initUserdataProvider.getUsersFriendsAll(),
      _initHistorydataProvider.getdata(),
      _workoutdataProvider.getdata(),
      _famousdataProvider.getdata(),
      _initExercisesdataProvider.getdata(),
      _PrefsProvider.getprefs(),
    ];
    _initHistorydataProvider.getHistorydataAll();
    _initHistorydataProvider.getCommentAll();
    _initHistorydataProvider.getFriendsHistorydata();
    _initUserdataProvider.getFriendsdata();

    _initUserdataProvider.userFriendsAll.userdatas
        .where((user) => user.image != "")
        .toList()
        .map((user) {
      print(user.image);
      precacheImage(Image.network(user.image).image, context);
    });

    _initUserdataProvider.userdata != null
        ? [
            _initUserdataProvider.getFriendsdata(),
            _initHistorydataProvider.getFriendsHistorydata()
          ]
        : null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
