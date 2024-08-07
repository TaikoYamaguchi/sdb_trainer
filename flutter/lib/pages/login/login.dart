import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/notification.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/pages/login/userFind.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/src/utils/firebase_fcm.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_analytics/firebase_analytics.dart';

class LoginPage extends StatefulWidget {
  final bool isUpdateNeeded;
  const LoginPage({Key? key, required this.isUpdateNeeded}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  var _bodyStater;
  var _loginState;
  var _userProvider;
  bool isLoading = false;
  bool _isEmailLogin = false;
  bool _isiOS = false;
  TextEditingController _userEmailCtrl = TextEditingController(text: "");
  TextEditingController _userPasswordCtrl = TextEditingController(text: "");
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    _userEmailCtrl = TextEditingController(text: "");
    _userPasswordCtrl = TextEditingController(text: "");
    Future.delayed(Duration.zero, () async {
      await _storageLoginCheck(context);
    });
    super.initState();
  }

  Future<void> _testSetUserId(email) async {
    await analytics.setUserId(id: email);
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _isiOS = foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
          color: const Color(0xFF101012),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Expanded(flex: 3, child: SizedBox(height: 6)),
                  Text("SUPERO",
                      style: TextStyle(
                          color: Theme.of(context).highlightColor,
                          fontSize: 54,
                          fontWeight: FontWeight.w800)),
                  Text("우리의 운동 극복 스토리",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                  const Expanded(flex: 3, child: SizedBox(height: 6)),
                  _isEmailLogin ? _emailWidget() : Container(),
                  const SizedBox(height: 8),
                  _isEmailLogin ? _passwordWidget() : Container(),
                  const SizedBox(height: 14),
                  _isEmailLogin ? _signInUpButton("로그인", context) : Container(),
                  const SizedBox(height: 14),
                  //_isEmailLogin
                  //    ? _signInUpButton("회원가입", context)
                  //    : Container(),
                  _isEmailLogin
                      ? Container()
                      : _loginSocialButton("kakao", context),
                  _isEmailLogin
                      ? Container()
                      : _loginSocialButton("google", context),
                  _isEmailLogin
                      ? Container()
                      : _isiOS
                          ? _loginSocialButton("apple", context)
                          : Container(),
                  _emailLoginButton(context),
                  const SizedBox(height: 42),
                  _isEmailLogin ? _findUser(context) : Container()
                ]),
          ))),
    );
  }

  Widget _loginSocialButton(String content, context) {
    final Map<String, String> _loginList = <String, String>{
      "kakao": 'assets/svg/kakao.png',
      "google":
          _isiOS ? 'assets/svg/google_ios.png' : 'assets/svg/google_and.png',
      "apple": 'assets/svg/apple_ios.png',
    };

    return InkWell(
      child: IconButton(
        icon: Image.asset(
          _loginList[content]!,
        ),
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width, minHeight: 70),
        onPressed: () {
          switch (content) {
            case "kakao":
              _loginButtonPressed();
              break;
            case "google":
              _loginGooglePressed();
              break;
            case "apple":
              _loginApplePressed();
              break;
          }
        },
      ),
    );
  }

  Widget _findUser(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: const Color(0xFF101012),
              padding: const EdgeInsets.all(8.0),
            ),
            onPressed: () => isLoading
                ? null
                : Navigator.push(
                    context,
                    Transition(
                        child: UserFindPage(),
                        transitionEffect: TransitionEffect.RIGHT_TO_LEFT)),
            child: Text(isLoading ? 'loading in.....' : "계정을 잊어버리셨나요?",
                style: const TextStyle(fontSize: 14.0, color: Colors.grey))));
  }

  Widget _emailLoginButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              backgroundColor: const Color(0xFF101012),
              textStyle: const TextStyle(
                color: Colors.grey,
              ),
              disabledForegroundColor: const Color(0xFF101012),
              padding: const EdgeInsets.all(4.0),
            ),
            onPressed: () => isLoading
                ? null
                : setState(() {
                    _isEmailLogin = !_isEmailLogin;
                  }),
            child: Text(_isEmailLogin ? '홈으로 돌아가기' : "이메일로 로그인 하기",
                style: const TextStyle(fontSize: 14.0, color: Colors.grey))));
  }

  Widget _emailWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
          controller: _userEmailCtrl,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email, color: Colors.white),
              labelText: "이메일",
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: Colors.white),
          style: const TextStyle(color: Colors.white)),
    );
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
              prefixIcon:
                  const Icon(Icons.vpn_key_rounded, color: Colors.white),
              labelText: "비밀번호",
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: Colors.white),
          style: const TextStyle(color: Colors.white)),
    );
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
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();

          User user = await UserApi.instance.me();

          _userProvider.setUserKakaoEmail(user.kakaoAccount!.email!);
          _userProvider.setUserKakaoImageUrl(user.properties?["profile_image"]);
          _userProvider.setUserKakaoName(user.kakaoAccount?.name);
          _userProvider.setUserKakaoGender(user.kakaoAccount?.gender);
          _userEmailCtrl.text = user.kakaoAccount!.email!;
          _userPasswordCtrl.text = user.kakaoAccount!.email!;
          print('로그인 성공 ${token.accessToken}');
          _loginkakaoCheck();
        } catch (error) {
          print('로그인 실패 $error');
          print('카카오계정으로 로그인');
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
        }
      }
    } else {
      print('발급된 토큰 없음');
      print('카카오톡으로 로그인');
      try {
        print('카카오톡으로 로그인');
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();

        User user = await UserApi.instance.me();

        _userProvider.setUserKakaoEmail(user.kakaoAccount!.email!);
        _userProvider.setUserKakaoImageUrl(user.properties?["profile_image"]);
        _userProvider.setUserKakaoName(user.kakaoAccount?.name);
        _userProvider.setUserKakaoGender(user.kakaoAccount?.gender);
        _userEmailCtrl.text = user.kakaoAccount!.email!;
        _userPasswordCtrl.text = user.kakaoAccount!.email!;
        print('로그인 성공 ${token.accessToken}');
        _loginkakaoCheck();
      } catch (error) {
        print('로그인 실패 $error');
        print('카카오계정으로 로그인');
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
      }
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  Future<void> _loginGooglePressed() async {
    try {
      await _googleSignIn.signIn();
      GoogleSignInAccount? user = _googleSignIn.currentUser;
      print(user);
      if (user != null) {
        try {
          _userEmailCtrl.text = user.email;
          _userProvider.setUserKakaoEmail(user.email);
          _userProvider.setUserKakaoImageUrl(user.photoUrl);
          _userProvider.setUserKakaoName(user.displayName);
          _loginkakaoCheck();
        } catch (error) {
          showToast("구글 권한을 확인 해주세요");
          print('사용자 정보 요청 실패 $error');
        }
      } else {
        showToast("구글 권한을 확인 해주세요");
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _loginApplePressed() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    print(credential);
    print("identityToken");
    print(credential.identityToken);
    print("authorizationCode");
    print(credential.authorizationCode);

    final oauthCredential = firebase.OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );
    print("oauthCredential");
    print(oauthCredential);
    var user = await firebase.FirebaseAuth.instance
        .signInWithCredential(oauthCredential);
    print("user");
    print(user);
    print("usergogogog");
    print(user.user!.providerData[0].email);
    try {
      if (user.user!.providerData[0].email != null) {
        try {
          _userEmailCtrl.text = user.user!.providerData[0].email!;
          _userProvider.setUserKakaoEmail(user.user!.providerData[0].email);
          _userProvider.setUserKakaoName(credential.givenName);
          _loginkakaoCheck();
        } catch (error) {
          print('사용자 정보 요청 실패 $error');
        }
      } else {
        showToast("애플 권한을 확인 해주세요");
      }
    } catch (error) {
      print(error);
    }
  }

  Widget _signInUpButton(String content, context) {
    final Map<String, Color> _loginColor = <String, Color>{
      "로그인": Theme.of(context).cardColor,
      "회원가입": Theme.of(context).primaryColor,
    };

    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 53,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
          child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: _loginColor[content],
                backgroundColor: _loginColor[content],
                textStyle: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                ),
                disabledForegroundColor: _loginColor[content],
                padding: const EdgeInsets.all(8.0),
              ),
              onPressed: () => isLoading
                  ? null
                  : content == "로그인"
                      ? _loginCheck(context)
                      : [
                          _loginState.changeSignup(true),
                          _userProvider.setUserKakaoEmail("test")
                        ],
              child: Text(isLoading ? 'loggin in.....' : content,
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Theme.of(context).primaryColorLight,
                      fontWeight: FontWeight.w400))),
        ));
  }

  void _loginCheck(context) async {
    const storage = FlutterSecureStorage();
    try {
      String? storageEmail = await storage.read(key: "sdb_email");
      String? storageToken = await storage.read(key: "sdb_token");
      if (storageEmail != null &&
          storageToken != null &&
          storageEmail != "" &&
          storageEmail == _userEmailCtrl.text) {
        initialProviderGet(context, storageToken);
        _bodyStater.change(1);
        _loginState.change(true);
        _testSetUserId(storageEmail);
        fcmSetting();
      } else {
        UserLogin(
                userEmail: _userEmailCtrl.text,
                password: _userPasswordCtrl.text)
            .loginUser()
            .then((token) => token["access_token"] != null
                ? {
                    initialProviderGet(context, token["access_token"]),
                    _bodyStater.change(1),
                    _loginState.change(true),
                    _testSetUserId(_userEmailCtrl.text),
                    fcmSetting(),
                  }
                : showToast("아이디와 비밀번호를 확인해주세요"));
      }
    } catch (e) {
      UserLogin(
              userEmail: _userEmailCtrl.text, password: _userPasswordCtrl.text)
          .loginUser()
          .then((token) => token["access_token"] != null
              ? {
                  initialProviderGet(context, token["access_token"]),
                  _bodyStater.change(1),
                  _loginState.change(true),
                  _testSetUserId(_userEmailCtrl.text),
                  fcmSetting(),
                }
              : showToast("아이디와 비밀번호를 확인해주세요"));
    }
  }

  void _loginkakaoCheck() async {
    const storage = FlutterSecureStorage();
    try {
      String? storageEmail = await storage.read(key: "sdb_email");
      String? storageToken = await storage.read(key: "sdb_token");
      if (storageEmail != null &&
          storageEmail != "" &&
          storageEmail == _userEmailCtrl.text &&
          storageToken != null) {
        initialProviderGet(context, storageToken);
        _bodyStater.change(1);
        _loginState.change(true);
        _testSetUserId(_userEmailCtrl.text);
        fcmSetting();
      } else {
        try {
          await UserLoginKakao(
            userEmail: _userEmailCtrl.text,
          ).loginKakaoUser().then((token) => token["access_token"] != null
              ? {
                  initialProviderGet(context, token["access_token"]),
                  _bodyStater.change(1),
                  _loginState.change(true),
                  _testSetUserId(_userEmailCtrl.text),
                  fcmSetting(),
                }
              : _loginState.changeSignup(true));
        } catch (error) {
          _loginState.changeSignup(true);
          showToast("회원가입 페이지로 이동할게요");
        }
      }
    } catch (e) {
      try {
        await UserLoginKakao(
          userEmail: _userEmailCtrl.text,
        ).loginKakaoUser().then((token) => token["access_token"] != null
            ? {
                initialProviderGet(context, token["access_token"]),
                _bodyStater.change(1),
                _loginState.change(true),
                _testSetUserId(_userEmailCtrl.text),
                fcmSetting(),
              }
            : _loginState.changeSignup(true));
      } catch (error) {
        print(error);
        _loginState.changeSignup(true);
        showToast("회원가입 페이지로 이동할게요");
      }
    }
  }

  Future<void> _storageLoginCheck(context) async {
    const storage = FlutterSecureStorage();
    String? storageEmail = await storage.read(key: "sdb_email");
    String? storageToken = await storage.read(key: "sdb_token");
    if (storageEmail != null && storageEmail != "" && storageToken != null) {
      _loginState.change(true);
      initialProviderGet(context, storageToken);
      _userProvider.getdata(storageToken).then((value) async {
        if (value == false) {
          await storage.delete(key: "sdb_email");
          await storage.delete(key: "sdb_token");
          _loginState.change(false);
          showToast("로그인이 만료되었어요");
        } else {
          if (_userProvider.userdata.is_active == true) {
            _bodyStater.change(1);
            _testSetUserId(storageEmail);
            fcmSetting();
          } else {
            await storage.delete(key: "sdb_email");
            await storage.delete(key: "sdb_token");
            _loginState.change(false);
            showToast("로그인이 제한되었습니다");
          }
        }
      });
    }
  }

  void _storageInitialExerciseCheck(_initExercisesdataProvider) async {
    const storage = FlutterSecureStorage();
    print("storage check for initial exercise");
    try {
      String? storageExerciseList = await storage.read(key: "sdb_HomeExList");
      if (storageExerciseList == null || storageExerciseList == "") {
        List<String> listViewerBuilderString = [
          '바벨 스쿼트',
          '바벨 데드리프트',
          '바벨 벤치 프레스'
        ];
        await storage.write(
            key: 'sdb_HomeExList', value: jsonEncode(listViewerBuilderString));
        _initExercisesdataProvider.putHomeExList(listViewerBuilderString);
      } else {
        List homeexlist = jsonDecode(storageExerciseList);
        for (int n = 0; n < homeexlist.length; n++) {
          if (namechange[homeexlist[n]] != null) {
            homeexlist[n] = namechange[homeexlist[n]];
          }
        }
        ;

        await storage.write(
            key: 'sdb_HomeExList', value: jsonEncode(homeexlist));
        _initExercisesdataProvider.putHomeExList(homeexlist);

        //_initExercisesdataProvider.putHomeExList(jsonDecode(storageExerciseList));
      }
    } catch (e) {
      List<String> listViewerBuilderString = [
        '바벨 스쿼트',
        '바벨 데드리프트',
        '바벨 벤치 프레스'
      ];
      _initExercisesdataProvider.putHomeExList(listViewerBuilderString);
      await storage.write(
          key: 'sdb_HomeExList', value: jsonEncode(listViewerBuilderString));
    }
  }

  void initialProviderGet(context, access_token) async {
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

    final _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    final _notificationProvider =
        Provider.of<NotificationdataProvider>(context, listen: false);

    const storage = FlutterSecureStorage();
    String? storageEmail = await storage.read(key: "sdb_email");
    String? storageToken = await storage.read(key: "sdb_token");

    _storageInitialExerciseCheck(_initExercisesdataProvider);
    _routinetimeProvider.routineInitialCheck();

    var usertestList;
    await [
      print(access_token),
      _initUserdataProvider.getdata(access_token).then((value) async {
        if (value == false) {
          await storage.delete(key: "sdb_email");
          await storage.delete(key: "sdb_token");
          _loginState.change(false);
          showToast("로그인이 만료되었어요");
        } else {
          if (_userProvider.userdata.is_active == true) {
            _bodyStater.change(1);
            _testSetUserId(storageEmail);
            fcmSetting();
          } else {
            await storage.delete(key: "sdb_email");
            await storage.delete(key: "sdb_token");
            _loginState.change(false);
            showToast("로그인이 제한되었습니다");
          }
        }
      }),
      _initUserdataProvider.getUsersFriendsAll(),
      _initHistorydataProvider.getdata(),
      _workoutdataProvider.getdata(),
      _famousdataProvider.getdata(),
      _initExercisesdataProvider.getdata(),
      _PrefsProvider.getprefs(),
      _PrefsProvider.getAlarmPrefs(),
      _PrefsProvider.getSystemNotification(),
      _routinetimeProvider.getrest(),
      _notificationProvider.getdata(),
      UserAll().getUsers().then((userlist) {
        usertestList =
            userlist!.userdatas.where((user) => user.image != "").toList();
      }),
    ];
    _initHistorydataProvider.getHistorydataAll();
    _initHistorydataProvider.getCommentAll();
    _initHistorydataProvider.getFriendsHistorydata();
    _initUserdataProvider.getFriendsdata();

    _initUserdataProvider.userdata != null
        ? [
            _initUserdataProvider.getFriendsdata(),
            _initHistorydataProvider.getFriendsHistorydata()
          ]
        : null;
    final binding = WidgetsFlutterBinding.ensureInitialized();

    binding.addPostFrameCallback((_) async {
      BuildContext context = binding.renderViewElement!;
      await Future.delayed(Duration.zero);
      for (var user in usertestList) {
        await precacheImage(CachedNetworkImageProvider(user.image), context);
      }
    });
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
