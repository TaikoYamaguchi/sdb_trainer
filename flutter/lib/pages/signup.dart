import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class SignUpPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<SignUpPage> {
  var _bodyStater;
  var _loginState;
  var _isSignupIndex = 0;
  bool isLoading = false;

  final Map<String, Widget> _heightUnitList = const <String, Widget>{
    "cm": Padding(
      child: Text("cm", style: TextStyle(color: Colors.white, fontSize: 24)),
      padding: const EdgeInsets.all(14.0),
    ),
    "inch": Padding(
      child: Text("inch", style: TextStyle(color: Colors.white, fontSize: 24)),
      padding: const EdgeInsets.all(14.0),
    )
  };
  final Map<String, Widget> _weightUnitList = const <String, Widget>{
    "kg": Padding(
        child: Text("kg", style: TextStyle(color: Colors.white, fontSize: 24)),
        padding: const EdgeInsets.all(14.0)),
    "lb": Padding(
        child: Text("lb", style: TextStyle(color: Colors.white, fontSize: 24)),
        padding: const EdgeInsets.all(14.0))
  };

  final Map<bool, Widget> _genderList = const <bool, Widget>{
    true: Padding(
      child: Text("남성", style: TextStyle(color: Colors.white, fontSize: 32)),
      padding: const EdgeInsets.all(20.0),
    ),
    false: Padding(
        child: Text("여성", style: TextStyle(color: Colors.white, fontSize: 32)),
        padding: const EdgeInsets.all(20.0))
  };

  TextEditingController _userEmailCtrl = TextEditingController(text: "");
  TextEditingController _userPasswordCtrl = TextEditingController(text: "");
  TextEditingController _userNameCtrl = TextEditingController(text: "unknown");
  TextEditingController _userNicknameCtrl = TextEditingController(text: "");
  TextEditingController _userImageCtrl = TextEditingController(text: "");
  TextEditingController _userHeightCtrl = TextEditingController(text: "");
  TextEditingController _userWeightCtrl = TextEditingController(text: "");
  var _userWeightUnitCtrl = "kg";
  var _userHeightUnitCtrl = "cm";
  var _userGenderCtrl = true;
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

    return Scaffold(body: _signupWidget());
  }

  Widget _signupWidget() {
    switch (_isSignupIndex) {
      case 0:
        return _signupProfileWidget();
      case 1:
        return _signupGenderWidget();
      case 2:
        return _signupSettingWidget();
    }
    return Container();
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
                      flex: 3,
                      child: SizedBox(),
                    ),
                    Text("회원가입",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                    SizedBox(
                      height: 8,
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
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    _signUpButton(context),
                    _loginButton(context),
                  ]))),
    );
  }

  Widget _signupGenderWidget() {
    return Container(
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
                    Text("성별 입력",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                    SizedBox(
                      height: 8,
                    ),
                    _genderWidget(),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    _signUpGenderButton(context),
                    _loginButton(context),
                  ]))),
    );
  }

  Widget _signupSettingWidget() {
    return Container(
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
                    Text("키, 몸무게 입력",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                    SizedBox(
                      height: 12,
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
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    _signUpButton(context),
                    _loginButton(context),
                  ]))),
    );
  }

  Widget _signupExerciseWidget() {
    return Container(
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
                    Text("키, 몸무게 입력",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                    SizedBox(
                      height: 12,
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
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    _signUpButton(context),
                    _loginButton(context),
                  ]))),
    );
  }

  Widget _emailWidget() {
    return TextFormField(
      controller: _userEmailCtrl,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
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
      style: TextStyle(color: Colors.white),
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

  Widget _heightWidget() {
    return TextFormField(
      controller: _userHeightCtrl,
      keyboardType:
          TextInputType.numberWithOptions(signed: true, decimal: true),
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "키",
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

  Widget _weightWidget() {
    return TextFormField(
      controller: _userWeightCtrl,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "몸무게",
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

  Widget _weightUnitWidget() {
    return CupertinoSlidingSegmentedControl(
        groupValue: _userWeightUnitCtrl,
        children: _weightUnitList,
        backgroundColor: Colors.black,
        thumbColor: Color.fromRGBO(25, 106, 223, 20),
        onValueChanged: (i) {
          setState(() {
            _userWeightUnitCtrl = i as String;
            print(_userWeightUnitCtrl);
          });
        });
  }

  Widget _heightUnitWidget() {
    return CupertinoSlidingSegmentedControl(
        groupValue: _userHeightUnitCtrl,
        children: _heightUnitList,
        backgroundColor: Colors.black,
        thumbColor: Color.fromRGBO(25, 106, 223, 20),
        onValueChanged: (i) {
          setState(() {
            _userHeightUnitCtrl = i as String;
            print(_userHeightUnitCtrl);
          });
        });
  }

  Widget _genderWidget() {
    return CupertinoSlidingSegmentedControl(
        groupValue: _userGenderCtrl,
        children: _genderList,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.black,
        thumbColor: Color.fromRGBO(25, 106, 223, 20),
        onValueChanged: (i) {
          setState(() {
            _userGenderCtrl = i as bool;
            print(_userGenderCtrl);
          });
        });
  }

  Widget _phoneNumberWidget() {
    return TextFormField(
      controller: _userPhoneNumberCtrl,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "휴대폰(-없이)",
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
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
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
      ),
    );
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
            onPressed: () => _isSignupIndex == 0
                ? setState(() {
                    _signUpProfileCheck() ? _isSignupIndex = 1 : null;
                  })
                : _signUpProfileCheck()
                    ? _signUpCheck()
                    : null,
            child: Text(isLoading ? 'loggin in.....' : "회원가입",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  Widget _signUpGenderButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => setState(() {
                  _signUpGenderCheck() ? _isSignupIndex = 2 : null;
                }),
            child: Text(isLoading ? 'loggin in.....' : "다음",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _signUpCheck() async {
    UserSignUp(
            userEmail: _userEmailCtrl.text,
            userName: _userNameCtrl.text,
            userNickname: _userNicknameCtrl.text,
            userHeight: _userHeightCtrl.text,
            userWeight: _userWeightCtrl.text,
            userHeightUnit: _userHeightUnitCtrl,
            userWeightUnit: _userWeightUnitCtrl,
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

  bool _signUpProfileCheck() {
    if (_isSignupIndex == 0) {
      if (_userEmailCtrl.text != "" &&
          _userNicknameCtrl.text != "" &&
          _userPasswordCtrl.text != "" &&
          _userPhoneNumberCtrl.text != "") {
        return true;
      } else {
        showToast("빈칸을 채워주세요");
        return false;
      }
    } else if (_isSignupIndex == 1) {
      if (_userGenderCtrl != "") {
        return true;
      } else {
        showToast("성별을 확인해주세요");
        return false;
      }
    } else if (_isSignupIndex == 2) {
      if (_userHeightCtrl.text != "" && _userWeightCtrl.text != "") {
        return true;
      } else {
        showToast("키와 몸무게를 확인해주세요");
        return false;
      }
    } else {
      return false;
    }
  }

  bool _signUpGenderCheck() {
    if (_userGenderCtrl != "") {
      return true;
    } else {
      showToast("성별을 확인해주세요");
      return false;
    }
  }

  Widget _loginButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Colors.black,
            textColor: Colors.white,
            disabledColor: Colors.black,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => isLoading ? null : _loginState.changeSignup(false),
            child: Text(isLoading ? 'loggin in.....' : "이미 계정이 있으신가요?",
                style: TextStyle(fontSize: 14.0, color: Colors.white))));
  }
}
