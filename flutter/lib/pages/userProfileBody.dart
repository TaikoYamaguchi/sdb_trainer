import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:flutter/cupertino.dart';

class ProfileBody extends StatefulWidget {
  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool isLoading = false;
  var _userdataProvider;
  var _userWeightUnitCtrl = "lb";
  var _userHeightUnitCtrl = "cm";
  var _userHeightCtrl;
  var _userWeightCtrl;
  DateTime _toDay = DateTime.now();

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    TextEditingController(text: _userdataProvider.userdata.nickname);
    _userWeightUnitCtrl = _userdataProvider.userdata.weight_unit;
    _userHeightUnitCtrl = _userdataProvider.userdata.height_unit;

    _userHeightCtrl = TextEditingController(
        text: _userdataProvider.userdata.height.toString());
    _userWeightCtrl = TextEditingController(
        text: _userdataProvider.userdata.bodyStats.last.weight.toString());

    _userHeightCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _userHeightCtrl.text.length));

    _userWeightCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _userWeightCtrl.text.length));

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appbarWidget(),
        body: _signupSettingWidget());
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text(
        "",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Color(0xFF101012),
    );
  }

  Widget _signupSettingWidget() {
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
                    Text("키, 몸무게 수정",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w600)),
                    Text("체형을 입력 할 수 있어요",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        )),
                    SizedBox(
                      height: 24,
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
                    _editButton(context)
                  ]))),
    );
  }

  Widget _heightWidget() {
    return TextFormField(
      controller: _userHeightCtrl,
      autofocus: true,
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
        focusedBorder: OutlineInputBorder(
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
        focusedBorder: OutlineInputBorder(
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
        backgroundColor: Color(0xFF101012),
        thumbColor: Theme.of(context).primaryColor,
        onValueChanged: (i) {
          _userWeightUnitCtrl = i as String;
        });
  }

  Widget _heightUnitWidget() {
    return CupertinoSlidingSegmentedControl(
        groupValue: _userHeightUnitCtrl,
        children: _heightUnitList,
        backgroundColor: Color(0xFF101012),
        thumbColor: Theme.of(context).primaryColor,
        onValueChanged: (i) {
          _userHeightUnitCtrl = i as String;
        });
  }

  Widget _editButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor,
              textStyle: TextStyle(
                color: Colors.white,
              ),
              disabledForegroundColor: Color(0xFF101012),
              padding: EdgeInsets.all(8.0),
            ),
            onPressed: () {
              _userdataProvider.setUserWeightAdd(
                  _toDay.toString(),
                  double.parse(_userWeightCtrl.text),
                  _userdataProvider.userdata.bodyStats.last.weight);
            },
            child: Text(isLoading ? 'loggin in.....' : "프로필 수정",
                style: TextStyle(fontSize: 20.0, color: Colors.white))));
  }

  void _editCheck() async {
    if (_userHeightCtrl.text != "" && _userWeightCtrl.text != "") {
      UserEdit(
              userEmail: _userdataProvider.userdata.email,
              userName: _userdataProvider.userdata.username,
              userNickname: _userdataProvider.userdata.nickname,
              userHeight: _userHeightCtrl.text.toString(),
              userWeight: _userWeightCtrl.text.toString(),
              userHeightUnit: _userHeightUnitCtrl,
              userWeightUnit: _userWeightUnitCtrl,
              userImage: _userdataProvider.userdata.image,
              userFavorExercise: _userdataProvider.userdata.favor_exercise)
          .editUser()
          .then((data) => data["username"] != null
              ? {
                  showToast("수정 완료"),
                  _userdataProvider.getdata(),
                  Navigator.pop(context)
                }
              : showToast("수정할 수 없습니다"));
    } else {
      showToast("키와 몸무게를 입력해주세요");
    }
  }
}
