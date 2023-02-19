import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sdb_trainer/pages/login.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/repository/workout_repository.dart';
import 'package:sdb_trainer/src/model/exerciseList.dart';
import 'package:sdb_trainer/src/model/userdata.dart';
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
import 'package:sdb_trainer/src/model/workoutdata.dart' as routine;
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var _bodyStater;
  var _loginState;
  var _userProvider;
  var _PrefProvider;
  var _themeProvider;
  var _isSignupIndex = 0;
  bool isLoading = false;
  bool _isEmailused = false;
  bool _isNickNameused = false;
  bool _isPhoneNumberused = false;
  var _heightUnitList;
  var _weightUnitList;
  var _genderList;

  TextEditingController _userEmailCtrl = TextEditingController(text: "");
  TextEditingController _userPasswordCtrl =
      TextEditingController(text: "unkown!@#");
  TextEditingController _userNameCtrl = TextEditingController(text: "unknown");
  TextEditingController _userNicknameCtrl = TextEditingController(text: "");
  TextEditingController _userImageCtrl = TextEditingController(text: "");
  TextEditingController _userHeightCtrl = TextEditingController(text: "");
  TextEditingController _userWeightCtrl = TextEditingController(text: "");
  var _userWeightUnitCtrl = "kg";
  var _userHeightUnitCtrl = "cm";
  var _userGenderCtrl = true;
  List<Exercises> exerciseList = extra_completely_new_Ex;
  List<routine.Routinedatas> routinedatas = [];

  List<TextEditingController> _onermController = [];
  List<TextEditingController> _goalController = [];

  TextEditingController _userPhoneNumberCtrl = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _userEmailCtrl = TextEditingController(text: "");
    _userPasswordCtrl = TextEditingController(text: "unkown!@#");
  }

  @override
  Widget build(BuildContext context) {
    _bodyStater = Provider.of<BodyStater>(context, listen: false);
    _loginState = Provider.of<LoginPageProvider>(context, listen: false);
    _PrefProvider = Provider.of<PrefsProvider>(context, listen: false);
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);

    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    _heightUnitList = <String, Widget>{
      "cm": Text("cm",
          textScaleFactor: 2.0,
          style: TextStyle(
              color: _userHeightUnitCtrl == "cm"
                  ? Theme.of(context).buttonColor
                  : Theme.of(context).primaryColorLight)),
      "inch": Text("inch",
          textScaleFactor: 2.0,
          style: TextStyle(
              color: _userHeightUnitCtrl == "inch"
                  ? Theme.of(context).buttonColor
                  : Theme.of(context).primaryColorLight)),
    };
    _weightUnitList = <String, Widget>{
      "kg": Text("kg",
          textScaleFactor: 2.0,
          style: TextStyle(
              color: _userWeightUnitCtrl == "kg"
                  ? Theme.of(context).buttonColor
                  : Theme.of(context).primaryColorLight)),
      "lb": Text("lb",
          textScaleFactor: 2.0,
          style: TextStyle(
              color: _userWeightUnitCtrl == "lb"
                  ? Theme.of(context).buttonColor
                  : Theme.of(context).primaryColorLight)),
    };

    _genderList = <bool, Widget>{
      true: Text("남성",
          textScaleFactor: 2.5,
          style: TextStyle(
              color: _userGenderCtrl == true
                  ? Theme.of(context).buttonColor
                  : Theme.of(context).primaryColorLight)),
      false: Text("여성",
          textScaleFactor: 2.5,
          style: TextStyle(
              color: _userGenderCtrl == false
                  ? Theme.of(context).buttonColor
                  : Theme.of(context).primaryColorLight)),
    };

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
      child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              SizedBox(height: 24),
              KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
                return Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 40,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        StepProgressIndicator(
                          totalSteps: 5,
                          size: 10,
                          onTap: (index) {
                            if (_isSignupIndex > index && _isSignupIndex <= 2) {
                              return () {
                                setState(() {
                                  _isSignupIndex = index;
                                });
                                print(index);
                              };
                            } else if (_isSignupIndex > 2) {
                              return () {
                                showToast("회원가입이 완료되어 추후 변경가능합니다!");
                                print(-1);
                              };
                            } else {
                              return () {
                                showToast("버튼을 눌러 넘어 갈 수 있어요!");
                                print(-1);
                              };
                            }
                          },
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
          )),
    ));
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
        return _signupImageWidget();
      case 4:
        return _signupExerciseWidget();
    }
    return Container();
  }

  Widget _signupProfileWidget() {
    return Container(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: SizedBox(),
              ),
              Text("회원가입을 진행할게요",
                  textScaleFactor: 2.5,
                  style: TextStyle(color: Theme.of(context).primaryColorLight)),
              Text("어떻게 불러드릴까요?",
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
              SizedBox(
                height: 12,
              ),
              _nicknameWidget(),
              SizedBox(
                height: 12,
              ),
              _phoneNumberWidget(),
              Expanded(
                flex: 3,
                child: SizedBox(),
              ),
              SizedBox(
                height: 12,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _signUpButton(context),
                  _loginButton(context),
                ],
              ),
            ]),
      )),
    );
  }

  Widget _signupGenderWidget() {
    return Container(
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
                        textScaleFactor: 2.5,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight)),
                    Text("성별에 따라 추천 무게가 달라져요",
                        textScaleFactor: 1.3,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    SizedBox(
                      height: 24,
                    ),
                    _genderWidget(),
                    SizedBox(
                      height: 20,
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
                        textScaleFactor: 2.5,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight)),
                    Text("신체에 따라 추천 프로그램이 달라져요",
                        textScaleFactor: 1.3,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(child: _heightWidget()),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(child: _heightUnitWidget())
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(child: _weightWidget()),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(child: _weightUnitWidget())
                      ],
                    ),
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    _signUpButton(context),
                    _loginButton(context),
                  ]))),
    );
  }

  Widget _signupImageWidget() {
    return Container(
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
                    Text("사진을 설정해주세요",
                        textScaleFactor: 2.5,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight)),
                    Text("사진을 클릭하면 변경 할 수 있어요",
                        textScaleFactor: 1.3,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    SizedBox(
                      height: 34,
                    ),
                    Consumer<UserdataProvider>(
                        builder: (builder, provider, child) {
                      return provider.userdata == null
                          ? CircularProgressIndicator()
                          : GestureDetector(
                              onTap: () {
                                displayPhotoDialog(context);
                              },
                              child: _userProvider.userdata.image == ""
                                  ? Icon(
                                      Icons.account_circle,
                                      color: Theme.of(context).primaryColorDark,
                                      size: 200.0,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: provider.userdata.image,
                                      imageBuilder: (context, imageProivder) =>
                                          Container(
                                        height: 200,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                            image: DecorationImage(
                                              image: imageProivder,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    ));
                    }),
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
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("추천 목표치를 설정했어요",
                        textScaleFactor: 2.0,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight)),
                    Text("1RM 입력은 추후 가능해요",
                        textScaleFactor: 1.5,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark)),
                    SizedBox(
                      height: 24,
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
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              )),
                          Container(
                              width: 70,
                              child: Text("1rm",
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  textAlign: TextAlign.center)),
                          Container(
                              width: 80,
                              child: Text("목표",
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  textAlign: TextAlign.center))
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: SingleChildScrollView(
                          child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ListView.separated(
                                  itemBuilder:
                                      (BuildContext _context, int index) {
                                    return Center(
                                        child: _exerciseWidget(
                                            exerciseList[index], index));
                                  },
                                  separatorBuilder:
                                      (BuildContext _context, int index) {
                                    return Container(
                                      alignment: Alignment.center,
                                      height: 0.5,
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        height: 0.5,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    );
                                  },
                                  shrinkWrap: true,
                                  itemCount: 3)),
                        ),
                      ),
                    ),
                    _weightSubmitButton(context),
                    SizedBox(height: 8)
                    //_loginButton(context),
                  ]))),
    );
  }

  Widget _emailWidget() {
    return TextFormField(
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
      enabled: false,
      controller: _userEmailCtrl,
      style: TextStyle(color: Theme.of(context).primaryColorDark),
      decoration: InputDecoration(
        labelText: _isEmailused == false ? "이메일" : "사용 불가 이메일",
        labelStyle: TextStyle(
            color: _isEmailused == false
                ? Theme.of(context).primaryColorDark
                : Colors.red),
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
              color: _isEmailused == false
                  ? Theme.of(context).primaryColorDark
                  : Colors.red,
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
                textScaleFactor: 1.5,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
            ),
            Container(
              width: 70,
              child: TextFormField(
                  controller: _onermController[index],
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).primaryColorLight),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      filled: true,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColorLight,
                            width: 0.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      hintText: Exercises.onerm.toStringAsFixed(1),
                      hintStyle: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColorLight)),
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
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).primaryColorLight),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      filled: true,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColorLight,
                            width: 0.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      hintText: Exercises.goal.toStringAsFixed(1),
                      hintStyle: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColorLight)),
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
      autofocus: true,
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
      style: TextStyle(
        color: Theme.of(context).primaryColorLight,
        fontSize: _themeProvider.userFontSize * 20 / 0.8,
      ),
      decoration: InputDecoration(
        filled: true,
        labelText: _isNickNameused == false ? "닉네임" : "사용 불가 닉네임",
        labelStyle: TextStyle(
            fontSize: _themeProvider.userFontSize * 16 / 0.8,
            color: _isNickNameused == false
                ? Theme.of(context).primaryColorDark
                : Colors.red),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false
                  ? Theme.of(context).primaryColor
                  : Colors.red,
              width: 3.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: _isNickNameused == false
                  ? Theme.of(context).primaryColorLight
                  : Colors.red,
              width: 3.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _heightWidget() {
    return TextFormField(
      autofocus: true,
      controller: _userHeightCtrl,
      keyboardType:
          TextInputType.numberWithOptions(signed: false, decimal: true),
      style: TextStyle(
        color: Theme.of(context).primaryColorLight,
        fontSize: _themeProvider.userFontSize * 20 / 0.8,
      ),
      decoration: InputDecoration(
        filled: true,
        labelText: "키",
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: _themeProvider.userFontSize * 16 / 0.8,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).primaryColorLight, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _weightWidget() {
    return TextFormField(
      controller: _userWeightCtrl,
      keyboardType:
          TextInputType.numberWithOptions(signed: false, decimal: true),
      style: TextStyle(
        color: Theme.of(context).primaryColorLight,
        fontSize: _themeProvider.userFontSize * 20 / 0.8,
      ),
      decoration: InputDecoration(
        filled: true,
        labelText: "몸무게",
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: _themeProvider.userFontSize * 16 / 0.8,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).primaryColorLight, width: 3.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _weightUnitWidget() {
    return CustomSlidingSegmentedControl(
        isStretch: true,
        height: 54.0,
        children: _weightUnitList,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        innerPadding: const EdgeInsets.all(4),
        thumbDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).primaryColor),
        onValueChanged: (i) {
          setState(() {
            _userWeightUnitCtrl = i as String;
          });
        });
  }

  Widget _heightUnitWidget() {
    return CustomSlidingSegmentedControl(
        isStretch: true,
        height: 54.0,
        children: _heightUnitList,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        innerPadding: const EdgeInsets.all(4),
        thumbDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).primaryColor),
        onValueChanged: (i) {
          setState(() {
            _userHeightUnitCtrl = i as String;
          });
        });
  }

  Widget _genderWidget() {
    return CustomSlidingSegmentedControl(
        padding: 40.0,
        height: 64.0,
        children: _genderList,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        innerPadding: const EdgeInsets.all(4),
        thumbDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).primaryColor),
        onValueChanged: (i) {
          _userProvider.setUserKakaoGender(i as bool);
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
      style: TextStyle(
        color: Theme.of(context).primaryColorLight,
        fontSize: _themeProvider.userFontSize * 20 / 0.8,
      ),
      decoration: InputDecoration(
        filled: true,
        labelText: _isPhoneNumberused == false ? "휴대폰(-없이)" : "중복된 전화번호",
        labelStyle: TextStyle(
            fontSize: _themeProvider.userFontSize * 16 / 0.8,
            color: _isPhoneNumberused == false
                ? Theme.of(context).primaryColorDark
                : Colors.red),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneNumberused == false
                  ? Theme.of(context).primaryColor
                  : Colors.red,
              width: 3.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneNumberused == false
                  ? Theme.of(context).primaryColorLight
                  : Colors.red,
              width: 3.0),
          borderRadius: BorderRadius.circular(8.0),
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
      style: TextStyle(color: Theme.of(context).primaryColorLight),
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      obscuringCharacter: "*",
      decoration: InputDecoration(
        labelText: "비밀번호",
        labelStyle: TextStyle(color: Theme.of(context).primaryColorLight),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).primaryColorLight, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).primaryColorLight, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _signUpButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 56,
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
              padding: EdgeInsets.all(8.0),
            ),
            onPressed: () => _isSignupIndex == 0
                ? setState(() {
                    _PrefProvider.getprefs();
                    _signUpProfileCheck().then((value) {
                      if (value) {
                        setState(() {
                          _isSignupIndex = 1;
                        });
                      }
                    });
                  })
                : _isSignupIndex == 3
                    ? setState(() {
                        _PrefProvider.getprefs();
                        setState(() {
                          _isSignupIndex = 4;
                        });
                      })
                    : {
                        setState(() {
                          _PrefProvider.getprefs();
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
            child: Text(
                isLoading
                    ? 'loggin in.....'
                    : _isSignupIndex == 0
                        ? "다음"
                        : _isSignupIndex == 3
                            ? "다음"
                            : "회원가입 완료",
                style: TextStyle(
                    fontSize: 20.0, color: Theme.of(context).buttonColor))));
  }

  Widget _weightSubmitButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 64,
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
              padding: EdgeInsets.all(8.0),
            ),
            onPressed: () => _postExerciseCheck(context),
            child: Column(
              children: [
                Text(isLoading ? 'loggin in.....' : "추천 운동 하러 가기",
                    style: TextStyle(
                        fontSize: 20.0, color: Theme.of(context).buttonColor)),
                Text("추천 운동이 운동 탭에 생길거에요",
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 14)),
              ],
            )));
  }

  Widget _signUpGenderButton(context) {
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
              padding: EdgeInsets.all(8.0),
            ),
            onPressed: () => setState(() {
                  _signUpGenderCheck() ? _isSignupIndex = 2 : null;
                }),
            child: Text(isLoading ? 'loggin in.....' : "다음",
                style: TextStyle(
                    fontSize: 20.0, color: Theme.of(context).buttonColor))));
  }

  void _signUpCheck() async {
    showToast("회원가입이 완료 중이니 기다려주세요");
    DateTime _toDay = DateTime.now();
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
            userGender: _userGenderCtrl,
            bodyStats: [
              BodyStat(
                  date: _toDay.toString(),
                  weight: double.parse(_userWeightCtrl.text),
                  weight_goal: double.parse(_userWeightCtrl.text),
                  height: double.parse(_userHeightCtrl.text),
                  height_goal: double.parse(_userHeightCtrl.text))
            ],
            password: _userPasswordCtrl.text)
        .signUpUser()
        .then((data) => data["username"] != null
            ? {
                _initialGoalCheck(),
                UserLogin(
                        userEmail: _userEmailCtrl.text,
                        password: _userPasswordCtrl.text)
                    .loginUser()
                    .then((token) {
                  token["access_token"] != null
                      ? {
                          _userProvider.getdata(),
                          _postWorkoutCheck(),
                          print(_userProvider.userdata),
                          setState(() {
                            _isSignupIndex = 3;
                          }),
                        }
                      : showToast("아이디와 비밀번호를 확인해주세요");
                }),
              }
            : showToast("회원가입을 할 수 없습니다"));
  }

  void _postExerciseCheck(context) async {
    ExercisePost(user_email: _userEmailCtrl.text, exercises: exerciseList)
        .postExercise()
        .then((data) => data["user_email"] != null
            ? {
                _bodyStater.change(1),
                _loginState.change(true),
                LoginPageState().initialProviderGet(context)
              }
            : showToast("입력을 확인해주세요"));
  }

  void _postWorkoutCheck() async {
    routinedatas = [
      routine.Routinedatas(
          name: "운동A",
          mode: 0,
          exercises: [
            routine.Exercises(
                name: "바벨 스쿼트",
                sets: [
                  routine.Sets(
                      index: 0,
                      weight: exerciseList[0].goal! * 0.5,
                      reps: 10,
                      ischecked: false),
                  routine.Sets(
                      index: 1,
                      weight: exerciseList[0].goal! * 0.5,
                      reps: 10,
                      ischecked: false),
                  routine.Sets(
                      index: 2,
                      weight: exerciseList[0].goal! * 0.5,
                      reps: 10,
                      ischecked: false)
                ],
                rest: 90,
                isCardio: false),
            routine.Exercises(
                name: "바벨 데드리프트",
                sets: [
                  routine.Sets(
                      index: 0,
                      weight: exerciseList[1].goal! * 0.5,
                      reps: 10,
                      ischecked: false),
                  routine.Sets(
                      index: 1,
                      weight: exerciseList[1].goal! * 0.5,
                      reps: 10,
                      ischecked: false),
                  routine.Sets(
                      index: 2,
                      weight: exerciseList[1].goal! * 0.5,
                      reps: 10,
                      ischecked: false)
                ],
                isCardio: false,
                rest: 90),
            routine.Exercises(
                name: "바벨 벤치 프레스",
                sets: [
                  routine.Sets(
                      index: 0,
                      weight: exerciseList[2].goal! * 0.5,
                      reps: 10,
                      ischecked: false),
                  routine.Sets(
                      index: 1,
                      weight: exerciseList[2].goal! * 0.5,
                      reps: 10,
                      ischecked: false),
                  routine.Sets(
                      index: 2,
                      weight: exerciseList[2].goal! * 0.5,
                      reps: 10,
                      ischecked: false)
                ],
                isCardio: false,
                rest: 90),
            routine.Exercises(
                name: "풀업",
                sets: [
                  routine.Sets(
                      index: double.parse(_userWeightCtrl.text),
                      weight: double.parse(_userWeightCtrl.text) * -0.3,
                      reps: 5,
                      ischecked: false),
                  routine.Sets(
                      index: double.parse(_userWeightCtrl.text),
                      weight: double.parse(_userWeightCtrl.text) * -0.3,
                      reps: 5,
                      ischecked: false),
                  routine.Sets(
                      index: double.parse(_userWeightCtrl.text),
                      weight: double.parse(_userWeightCtrl.text) * -0.3,
                      reps: 5,
                      ischecked: false),
                ],
                isCardio: false,
                rest: 90),
            routine.Exercises(
                name: "러닝",
                sets: [
                  routine.Sets(
                      index: double.parse(_userWeightCtrl.text),
                      weight: 0.0,
                      reps: 1000,
                      ischecked: false),
                ],
                isCardio: true,
                rest: 90),
          ],
          routine_time: 0.0)
    ];

    WorkoutPost(user_email: _userEmailCtrl.text, routinedatas: routinedatas)
        .postWorkout()
        .then((data) => data["user_email"] != null
            ? showToast("Workout 생성 완료")
            : showToast("입력을 확인해주세요"));
  }

  Future<bool> _signUpProfileCheck() async {
    if (_isSignupIndex == 0) {
      if (_userEmailCtrl.text != "" && _userNicknameCtrl.text != "") {
        if (_isEmailused == true || _isNickNameused == true) {
          showToast("이메일 및 닉네임 확인해주세요");
          return false;
        } else {
          showToast("회원정보 확인 후 이동해드릴게요");
          if (_userPhoneNumberCtrl.text != "") {
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
          } else {
            return true;
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
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              padding: EdgeInsets.all(8.0),
            ),
            onPressed: () => isLoading ? null : _loginState.changeSignup(false),
            child: Text(isLoading ? 'loggin in.....' : "이미 계정이 있으신가요?",
                style: TextStyle(
                    fontSize: 14.0,
                    color: Theme.of(context).primaryColorDark))));
  }
}
