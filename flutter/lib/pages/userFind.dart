import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';

class UserFindPage extends StatefulWidget {
  @override
  _UserFindPageState createState() => _UserFindPageState();
}

class _UserFindPageState extends State<UserFindPage> {
  bool isLoading = false;
  var _userdataProvider;
  bool _isPhoneEmpty = false;
  bool _isVerification = false;
  var user;
  TextEditingController _userPhoneNumberCtrl = TextEditingController(text: "");
  TextEditingController _userVerificationCodeCtrl =
      TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appbarWidget(), body: _signupProfileWidget());
  }

  PreferredSizeWidget _appbarWidget() {
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          title: Text(
            "회원 찾기",
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          backgroundColor: Color(0xFF101012),
        ));
  }

  Widget _signupProfileWidget() {
    return Container(
      color: Color(0xFF101012),
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ),
                    Text("휴대폰으로 계정 찾기(현재 사용이 어렵습니다. 고객센터로 문의 부탁드립니다)",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800)),
                    SizedBox(
                      height: 8,
                    ),
                    _phoneNumberWidget(),
                    _isVerification ? _codeWidget() : Container(),
                    user != null ? _userWidget() : Container(),
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    _editButton(context),
                  ]))),
    );
  }

  Widget _userWidget() {
    return Row(
      children: [
        Text("아이디는 ${user.email} 입니다.", style: TextStyle(color: Colors.white)),
        TextFormField(
          enabled: _isVerification == false,
          controller: _userPhoneNumberCtrl,
          style: TextStyle(color: Colors.white),
          autofocus: true,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          decoration: InputDecoration(
            labelText: _isPhoneEmpty == false ? "휴대폰" : "휴대폰으로 가입한 정보가 없습니다",
            labelStyle: TextStyle(
                color: _isPhoneEmpty == false ? Colors.white : Colors.red),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: _isPhoneEmpty == false ? Colors.white : Colors.red,
                  width: 2.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: _isPhoneEmpty == false ? Colors.white : Colors.red,
                  width: 2.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _phoneNumberWidget() {
    return TextFormField(
      enabled: _isVerification == false,
      controller: _userPhoneNumberCtrl,
      style: TextStyle(color: Colors.white),
      autofocus: true,
      keyboardType:
          TextInputType.numberWithOptions(signed: true, decimal: true),
      decoration: InputDecoration(
        labelText: _isPhoneEmpty == false ? "휴대폰" : "휴대폰으로 가입한 정보가 없습니다",
        labelStyle: TextStyle(
            color: _isPhoneEmpty == false ? Colors.white : Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneEmpty == false ? Colors.white : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneEmpty == false ? Colors.white : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _codeWidget() {
    return TextFormField(
      enabled: _isVerification == true,
      controller: _userVerificationCodeCtrl,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.white),
        labelText: _isPhoneEmpty == false ? "인증번호 입력" : "휴대폰으로 가입한 정보가 없습니다",
        labelStyle: TextStyle(
            color: _isPhoneEmpty == false ? Colors.white : Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneEmpty == false ? Colors.white : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneEmpty == false ? Colors.white : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _editButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Color.fromRGBO(246, 58, 64, 20),
              backgroundColor: Color.fromRGBO(246, 58, 64, 20),
              textStyle: TextStyle(
                color: Colors.white,
              ),
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(8.0),
            ),
            onPressed: () => _isVerification == false
                ? _phoneNumberCheck()
                : _verficationCodeCheck(),
            child: Text(
                isLoading
                    ? 'loggin in.....'
                    : _isVerification == false
                        ? "휴대폰 입력"
                        : "인증번호 입력",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _phoneNumberCheck() async {
    if (_userPhoneNumberCtrl.text != "") {
      UserFind(phone_number: _userPhoneNumberCtrl.text)
          .findUserSmsImage()
          .then((data) => {
                showToast("휴대폰 문자를 확인해주세요"),
                setState(() {
                  _isVerification = true;
                })
              });
    }
  }

  void _verficationCodeCheck() async {
    if (_userPhoneNumberCtrl.text != "" &&
        _userVerificationCodeCtrl.text != "") {
      UserFindVerification(
              phone_number: _userPhoneNumberCtrl.text,
              verify_code: _userVerificationCodeCtrl.text)
          .findUserSmsImage()
          .then((data) => {
                setState(() {
                  user = data;
                })
              });
    }
  }
}
