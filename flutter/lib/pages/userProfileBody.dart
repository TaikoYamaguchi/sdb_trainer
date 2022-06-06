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
    _userdataProvider = Provider.of<UserdataProvider>(context);
    TextEditingController(text: _userdataProvider.userdata.nickname);
    _userWeightUnitCtrl = _userdataProvider.userdata.weight_unit;
    _userHeightUnitCtrl = _userdataProvider.userdata.height_unit;

    _userHeightCtrl = TextEditingController(
        text: _userdataProvider.userdata.height.toString());
    _userWeightCtrl = TextEditingController(
        text: _userdataProvider.userdata.weight.toString());

    _userHeightCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _userHeightCtrl.text.length));

    _userWeightCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _userWeightCtrl.text.length));

    return Scaffold(appBar: _appbarWidget(), body: _signupSettingWidget());
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text(
        "",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      backgroundColor: Colors.black,
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
                      flex: 2,
                      child: SizedBox(),
                    ),
                    Text("키, 몸무게 수정",
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
          _userWeightUnitCtrl = i as String;
        });
  }

  Widget _heightUnitWidget() {
    return CupertinoSlidingSegmentedControl(
        groupValue: _userHeightUnitCtrl,
        children: _heightUnitList,
        backgroundColor: Colors.black,
        thumbColor: Color.fromRGBO(25, 106, 223, 20),
        onValueChanged: (i) {
          _userHeightUnitCtrl = i as String;
        });
  }

  Widget _editButton(context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
            color: Color.fromRGBO(246, 58, 64, 20),
            textColor: Colors.white,
            disabledColor: Color.fromRGBO(246, 58, 64, 20),
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.blueAccent,
            onPressed: () => _editCheck(),
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
              userImage: "",
              password: "",
              userFavorExercise: [""])
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
