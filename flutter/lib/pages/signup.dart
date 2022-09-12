import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/pages/home.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:sdb_trainer/src/model/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class SignUpPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<SignUpPage> {
  var _bodyStater;
  var _loginState;
  var _userProvider;
  var _isSignupIndex = 0;
  bool isLoading = false;
  bool _isEmailused = false;
  bool _isNickNameused = false;
  bool _isPhoneNumberused = false;

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
  List<Exercises> exerciseList = [
    Exercises(name: "스쿼트", onerm: 0, goal: 0.0),
    Exercises(name: "데드리프트", onerm: 0, goal: 0.0),
    Exercises(name: "벤치프레스", onerm: 0, goal: 0.0)
  ];

  List extra_Ex = [
    '밀리터리프레스',
    '체스트프레스',
    '오버헤드프레스',
    '벤트오버바벨로우',
    '풀업',
    '바벨컬',
    '덤벨컬',
    '카프레이즈',
    '치닝',
    '딥스',
    '디클라인벤치프레스',
    '인클라인벤치프레스',
    '랫풀다운',
    '레그프레스',
    '파워레그프레스',
    '레그컬',
    '레그익스텐션',
    '행잉레그레이즈',
    '덤벨로우',
    '사이드래터럴레이즈',
    '프론트래터럴레이즈',
    '리어델토이드플라이',
    '체스트플라이',
    '뎀벨플라이',
    '프론트스쿼트',
    '숄더프레스',
    '케이블플라이',
    '케이블풀다운',
    '케이블바이셉스컬',
    '케이블푸시다운',
    '케이블로우',
    '백익스텐션',
    '머슬업',
    '티바로우',
    '펜들레이로우',
    '덤벨프레스',
    '인클라인덤벨프레스',
    '런지',
    '디클라인덤벨프레스',
    '인클라인체스트프레스',
    '디클라인체스트프레스',
    '덤벨킥백'
  ];

  List<TextEditingController> _onermController = [];
  List<TextEditingController> _goalController = [];

  TextEditingController _userPhoneNumberCtrl = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _userEmailCtrl = TextEditingController(text: "");
    _userPasswordCtrl = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    if (_userProvider.userKakaoEmail != null) {
      _userEmailCtrl.text = _userProvider.userKakaoEmail;
    }

    if (_userProvider.userKakaoName != null) {
      _userNameCtrl.text = _userProvider.userKakaoName;
    }

    if (_userProvider.userKakaoImage != null) {
      _userImageCtrl.text = _userProvider.userKakaoImage;
    }

    if (_userProvider.userKakaoGender != null) {
      _userGenderCtrl = _userProvider.userKakaoGender;
    }

    return Scaffold(
        body: Container(
      color: Colors.black,
      child: Column(
        children: [
          KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
            return Container(
              width: MediaQuery.of(context).size.width / 3,
              height: 40,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                StepProgressIndicator(
                  totalSteps: 4,
                  size: 10,
                  roundedEdges: Radius.circular(10),
                  currentStep: _isSignupIndex + 1,
                  selectedColor: Theme.of(context).primaryColor,
                  unselectedColor: Theme.of(context).cardColor,
                  customColor: (index) => index == _isSignupIndex
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                ),
              ]),
            );
          }),
          Expanded(child: _signupWidget()),
        ],
      ),
    ));
  }

  void add_extra_ex() {
    for (int i = 0; i < extra_Ex.length; i++) {
      exerciseList.add(Exercises(name: extra_Ex[i], onerm: 0, goal: 10));
    }
  }

  Widget _signupWidget() {
    switch (_isSignupIndex) {
      case 0:
        return _signupProfileWidget();
      case 1:
        return _signupGenderWidget();
      case 2:
        return _signupSettingWidget();
      case 3:
        return _signupExerciseWidget();
    }
    return Container();
  }

  Widget _signupProfileWidget() {
    return Container(
      color: Colors.black,
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("회원가입을 시작할게요",
                          style: TextStyle(color: Colors.white, fontSize: 32)),
                      Text("회원가입 후 운동을 시작 할 수 있어요",
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(
                        height: 16,
                      ),
                      _emailWidget(),
                      SizedBox(
                        height: 12,
                      ),
                      _nicknameWidget(),
                      SizedBox(
                        height: 12,
                      ),
                      _passwordWidget(),
                      SizedBox(
                        height: 12,
                      ),
                      _phoneNumberWidget(),
                      SizedBox(
                        height: 36,
                      ),
                      _signUpButton(context),
                      _loginButton(context),
                    ]),
              ))),
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
                    Text("성별을 선택해주세요",
                        style: TextStyle(color: Colors.white, fontSize: 32)),
                    Text("성별에 따라 추천 무게가 달라져요",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                    SizedBox(
                      height: 34,
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
                    Text("키, 몸무게를 입력해주세요",
                        style: TextStyle(color: Colors.white, fontSize: 32)),
                    Text("신체에 따라 추천 프로그램이 달라져요",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                    SizedBox(
                      height: 34,
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
                    Text("회원가입 완료!",
                        style: TextStyle(color: Colors.white, fontSize: 32)),
                    Text("1rm과 목표치를 설정해보세요",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 120,
                              child: Text(
                                "운동",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              )),
                          Container(
                              width: 70,
                              child: Text("1rm",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center)),
                          Container(
                              width: 80,
                              child: Text("목표",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center))
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: ListView.separated(
                          itemBuilder: (BuildContext _context, int index) {
                            return Center(
                                child: _exerciseWidget(
                                    exerciseList[index], index));
                          },
                          separatorBuilder: (BuildContext _context, int index) {
                            return Container(
                              alignment: Alignment.center,
                              height: 1,
                              color: Colors.black,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 1,
                                color: Color(0xFF717171),
                              ),
                            );
                          },
                          itemCount: exerciseList.length),
                    ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ),
                    _weightSubmitButton(context),
                    //_loginButton(context),
                  ]))),
    );
  }

  Widget _emailWidget() {
    return TextFormField(
      autofocus: true,
      onChanged: (text) {
        if (_userProvider.userFriendsAll.userdatas
                .where((user) {
                  if (user.email == text.toString()) {
                    return true;
                  } else {
                    return false;
                  }
                })
                .toList()
                .length ==
            0) {
          setState(() {
            _isEmailused = false;
          });
        } else
          setState(() {
            _isEmailused = true;
          });
      },
      controller: _userEmailCtrl,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: _isEmailused == false ? "이메일" : "사용 불가 이메일",
        labelStyle:
            TextStyle(color: _isEmailused == false ? Colors.white : Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isEmailused == false
                  ? Theme.of(context).primaryColor
                  : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isEmailused == false ? Colors.white : Colors.red,
              width: 2.0),
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

  Widget _exerciseWidget(Exercises, index) {
    _onermController.add(new TextEditingController(text: ""));
    _goalController.add(
        new TextEditingController(text: Exercises.goal.toStringAsFixed(1)));
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 120,
              child: Text(
                Exercises.name,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            Container(
              width: 70,
              child: TextFormField(
                  controller: _onermController[index],
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: Exercises.onerm.toStringAsFixed(1),
                      hintStyle: TextStyle(fontSize: 18, color: Colors.white)),
                  onChanged: (text) {
                    double changeweight;
                    if (text == "") {
                      changeweight = 0.0;
                    } else {
                      changeweight = double.parse(text);
                    }
                    setState(() {
                      exerciseList[index].onerm = changeweight;
                    });
                  }),
            ),
            Container(
              width: 80,
              child: TextFormField(
                  controller: _goalController[index],
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: Exercises.goal.toStringAsFixed(1),
                      hintStyle: TextStyle(fontSize: 18, color: Colors.white)),
                  onChanged: (text) {
                    double changeweight;
                    if (text == "") {
                      changeweight = 0.0;
                    } else {
                      changeweight = double.parse(text);
                    }
                    setState(() {
                      exerciseList[index].goal = changeweight;
                    });
                  }),
            ),
          ],
        ),
      ),
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
      decoration: InputDecoration(
        labelText: _isNickNameused == false ? "닉네임" : "사용 불가 닉네임",
        labelStyle: TextStyle(
            color: _isNickNameused == false ? Colors.white : Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false
                  ? Theme.of(context).primaryColor
                  : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false ? Colors.white : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _heightWidget() {
    return TextFormField(
      autofocus: true,
      controller: _userHeightCtrl,
      keyboardType:
          TextInputType.numberWithOptions(signed: true, decimal: true),
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "키",
        labelStyle: TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
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
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
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
        thumbColor: Theme.of(context).primaryColor,
        onValueChanged: (i) {
          setState(() {
            _userWeightUnitCtrl = i as String;
          });
        });
  }

  Widget _heightUnitWidget() {
    return CupertinoSlidingSegmentedControl(
        groupValue: _userHeightUnitCtrl,
        children: _heightUnitList,
        backgroundColor: Colors.black,
        thumbColor: Theme.of(context).primaryColor,
        onValueChanged: (i) {
          setState(() {
            _userHeightUnitCtrl = i as String;
          });
        });
  }

  Widget _genderWidget() {
    return CupertinoSlidingSegmentedControl(
        groupValue: _userGenderCtrl,
        children: _genderList,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.black,
        thumbColor: Theme.of(context).primaryColor,
        onValueChanged: (i) {
          setState(() {
            _userGenderCtrl = i as bool;
          });
        });
  }

  Widget _phoneNumberWidget() {
    return TextFormField(
      onChanged: (text) {
        setState(() {
          _isPhoneNumberused = false;
        });
      },
      controller: _userPhoneNumberCtrl,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: _isPhoneNumberused == false ? "휴대폰(-없이)" : "중복된 전화번호",
        labelStyle: TextStyle(
            color: _isPhoneNumberused == false ? Colors.white : Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneNumberused == false
                  ? Theme.of(context).primaryColor
                  : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneNumberused == false ? Colors.white : Colors.red,
              width: 2.0),
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
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      obscuringCharacter: "*",
      decoration: InputDecoration(
        labelText: "비밀번호",
        labelStyle: TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () => _isSignupIndex == 0
                ? setState(() {
                    _signUpProfileCheck().then((value) {
                      if (value) {
                        setState(() {
                          _isSignupIndex = 1;
                        });
                      }
                    });
                  })
                : _isSignupIndex == 1
                    ? setState(() {
                        _signUpProfileCheck().then((value) {
                          if (value) {
                            setState(() {
                              _isSignupIndex = 2;
                            });
                          }
                        });
                      })
                    : {
                        setState(() {
                          _signUpProfileCheck().then((value) {
                            if (value) {
                              setState(() {
                                _signUpCheck();
                                showToast("회원가입 중이니 기다려주세요.");
                              });
                            }
                          });
                        })
                      },
            child: Text(isLoading ? 'loggin in.....' : "회원가입",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  Widget _weightSubmitButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            disabledColor: Theme.of(context).primaryColor,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () => _postExerciseCheck(),
            child: Text(isLoading ? 'loggin in.....' : "운동 정보 제출",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  Widget _signUpGenderButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            disabledColor: Theme.of(context).primaryColor,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () => setState(() {
                  _signUpGenderCheck() ? _isSignupIndex = 2 : null;
                }),
            child: Text(isLoading ? 'loggin in.....' : "다음",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _signUpCheck() async {
    showToast("회원가입이 완료 중이니 기다려주세요");
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
            ? {
                _initialGoalCheck(),
                setState(() {
                  _isSignupIndex = 3;
                }),
                UserLogin(
                        userEmail: _userEmailCtrl.text,
                        password: _userPasswordCtrl.text)
                    .loginUser()
                    .then((token) {
                  token["access_token"] != null
                      ? {}
                      : showToast("아이디와 비밀번호를 확인해주세요");
                }),
                _postWorkoutCheck()
              }
            : showToast("회원가입을 할 수 없습니다"));
  }

  void _postExerciseCheck() async {
    add_extra_ex();
    ExercisePost(user_email: _userEmailCtrl.text, exercises: exerciseList)
        .postExercise()
        .then((data) => data["user_email"] != null
            ? {_bodyStater.change(0), _loginState.change(true)}
            : showToast("입력을 확인해주세요"));
  }

  void _postWorkoutCheck() async {
    WorkoutPost(user_email: _userEmailCtrl.text, routinedatas: [])
        .postWorkout()
        .then((data) => data["user_email"] != null
            ? showToast("Workout 생성 완료")
            : showToast("입력을 확인해주세요"));
  }

  Future<bool> _signUpProfileCheck() async {
    if (_isSignupIndex == 0) {
      if (_userEmailCtrl.text != "" &&
          _userNicknameCtrl.text != "" &&
          _userPasswordCtrl.text != "" &&
          _userPhoneNumberCtrl.text != "") {
        if (_isEmailused == true || _isNickNameused == true) {
          showToast("이메일 및 닉네임 확인해주세요");
          return false;
        } else {
          showToast("회원정보 확인 후 이동해드릴게요");
          var user =
              await UserPhoneCheck(userPhoneNumber: _userPhoneNumberCtrl.text)
                  .getUserByPhoneNumber();
          if (user == null) {
            return true;
          } else {
            setState(() {
              _isPhoneNumberused = true;
            });
            showToast("중복된 폰번호 입니다.");
            return false;
          }
        }
      } else {
        showToast("빈칸을 입력해주세요");
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

  void _initialGoalCheck() {
    if (_userGenderCtrl) {
      exerciseList[0].goal = double.parse(_userWeightCtrl.text) * 1.4;
      exerciseList[1].goal = double.parse(_userWeightCtrl.text) * 1.7;
      exerciseList[2].goal = double.parse(_userWeightCtrl.text) * 1.1;
    } else {
      exerciseList[0].goal = double.parse(_userWeightCtrl.text) * 0.9;
      exerciseList[1].goal = double.parse(_userWeightCtrl.text) * 1.2;
      exerciseList[2].goal = double.parse(_userWeightCtrl.text) * 0.7;
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
            splashColor: Theme.of(context).primaryColor,
            onPressed: () => isLoading ? null : _loginState.changeSignup(false),
            child: Text(isLoading ? 'loggin in.....' : "이미 계정이 있으신가요?",
                style: TextStyle(fontSize: 14.0, color: Colors.grey))));
  }
}
