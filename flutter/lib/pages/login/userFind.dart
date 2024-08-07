import 'package:flutter/material.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class UserFindPage extends StatefulWidget {
  const UserFindPage({Key? key}) : super(key: key);

  @override
  _UserFindPageState createState() => _UserFindPageState();
}

class _UserFindPageState extends State<UserFindPage> {
  bool isLoading = false;
  final bool _isPhoneEmpty = false;
  bool _isVerification = false;
  var user;
  final TextEditingController _userPhoneNumberCtrl =
      TextEditingController(text: "");
  final TextEditingController _userVerificationCodeCtrl =
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
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          title: Text(
            "회원 찾기",
            textScaleFactor: 2.5,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _signupProfileWidget() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                  Text("휴대폰으로 계정 찾기(현재 사용이 어렵습니다. 고객센터로 문의 부탁드립니다)",
                      textScaleFactor: 2.1,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(
                    height: 8,
                  ),
                  _phoneNumberWidget(),
                  _isVerification ? _codeWidget() : Container(),
                  user != null ? _userWidget() : Container(),
                  const Expanded(
                    flex: 3,
                    child: SizedBox(),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _editButton(context),
                ])));
  }

  Widget _userWidget() {
    return Row(
      children: [
        Text("아이디는 ${user.email} 입니다.",
            style: TextStyle(color: Theme.of(context).primaryColorLight)),
        TextFormField(
          enabled: _isVerification == false,
          controller: _userPhoneNumberCtrl,
          style: TextStyle(color: Theme.of(context).primaryColorLight),
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(
              signed: true, decimal: true),
          decoration: InputDecoration(
            labelText: _isPhoneEmpty == false ? "휴대폰" : "휴대폰으로 가입한 정보가 없습니다",
            labelStyle: TextStyle(
                color: _isPhoneEmpty == false
                    ? Theme.of(context).primaryColorLight
                    : Colors.red),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: _isPhoneEmpty == false
                      ? Theme.of(context).primaryColorLight
                      : Colors.red,
                  width: 1.5),
              borderRadius: BorderRadius.circular(5.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: _isPhoneEmpty == false
                      ? Theme.of(context).primaryColorLight
                      : Colors.red,
                  width: 1.0),
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
      style: TextStyle(color: Theme.of(context).primaryColorLight),
      autofocus: true,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      decoration: InputDecoration(
        labelText: _isPhoneEmpty == false ? "휴대폰" : "휴대폰으로 가입한 정보가 없습니다",
        labelStyle: TextStyle(
            color: _isPhoneEmpty == false
                ? Theme.of(context).primaryColorLight
                : Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneEmpty == false
                  ? Theme.of(context).primaryColorLight
                  : Colors.red,
              width: 1.5),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneEmpty == false
                  ? Theme.of(context).primaryColorLight
                  : Colors.red,
              width: 1.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _codeWidget() {
    return TextFormField(
      enabled: _isVerification == true,
      controller: _userVerificationCodeCtrl,
      style: TextStyle(color: Theme.of(context).primaryColorLight),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Theme.of(context).primaryColorLight),
        labelText: _isPhoneEmpty == false ? "인증번호 입력" : "휴대폰으로 가입한 정보가 없습니다",
        labelStyle: TextStyle(
            color: _isPhoneEmpty == false
                ? Theme.of(context).primaryColorLight
                : Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneEmpty == false
                  ? Theme.of(context).primaryColorLight
                  : Colors.red,
              width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: _isPhoneEmpty == false
                  ? Theme.of(context).primaryColorLight
                  : Colors.red,
              width: 1.0),
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
              foregroundColor: const Color.fromRGBO(246, 58, 64, 20),
              backgroundColor: const Color.fromRGBO(246, 58, 64, 20),
              textStyle: TextStyle(
                color: Theme.of(context).primaryColorLight,
              ),
              disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
              padding: const EdgeInsets.all(8.0),
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
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
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
