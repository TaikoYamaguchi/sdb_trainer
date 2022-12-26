import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class ProfileBody extends StatefulWidget {
  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool isLoading = false;
  var _userProvider;
  var _userWeightUnitCtrl = "lb";
  var _userHeightUnitCtrl = "cm";
  var _userHeightCtrl;
  var _userWeightCtrl;
  DateTime _toDay = DateTime.now();
  var _heightUnitList;
  var _weightUnitList;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    TextEditingController(text: _userProvider.userdata.nickname);
    _userWeightUnitCtrl = _userProvider.userdata.weight_unit;
    _userHeightUnitCtrl = _userProvider.userdata.height_unit;

    _userHeightCtrl =
        TextEditingController(text: _userProvider.userdata.height.toString());
    _userWeightCtrl = TextEditingController(
        text: _userProvider.userdata.bodyStats.last.weight.toString());

    _userHeightCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _userHeightCtrl.text.length));

    _userWeightCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _userWeightCtrl.text.length));
    _heightUnitList = <String, Widget>{
      "cm": Text("cm",
          textScaleFactor: 2.0,
          style: TextStyle(color: Theme.of(context).primaryColorLight)),
      "inch": Text("inch",
          textScaleFactor: 2.0,
          style: TextStyle(color: Theme.of(context).primaryColorLight)),
    };
    _weightUnitList = <String, Widget>{
      "kg": Text("kg",
          textScaleFactor: 2.0,
          style: TextStyle(color: Theme.of(context).primaryColorLight)),
      "lb": Text("lb",
          textScaleFactor: 2.0,
          style: TextStyle(color: Theme.of(context).primaryColorLight)),
    };

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appbarWidget(),
        body: _signupSettingWidget());
  }

  PreferredSizeWidget _appbarWidget() {
    var _btnDisabled = false;
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              _btnDisabled == true
                  ? null
                  : [
                      Navigator.of(context).pop(),
                      _btnDisabled = true,
                    ];
            },
          ),
          title: Text(
            "",
            textScaleFactor: 2.5,
            style: TextStyle(color: Theme.of(context).primaryColorLight),
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _signupSettingWidget() {
    bool btnDisabled = false;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onPanUpdate: (details) {
          if (details.delta.dx > 0 && btnDisabled == false) {
            btnDisabled = true;
            Navigator.of(context).pop();
            print("Dragging in +X direction");
          }
        },
        child: Container(
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
                        Text("키, 몸무게 수정",
                            textScaleFactor: 2.7,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.w600)),
                        Text("체형을 입력 할 수 있어요",
                            textScaleFactor: 1.3,
                            style: TextStyle(
                              color: Colors.grey,
                            )),
                        SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
        ));
  }

  Widget _heightWidget() {
    return TextFormField(
      autofocus: true,
      controller: _userHeightCtrl,
      keyboardType:
          TextInputType.numberWithOptions(signed: false, decimal: true),
      style: TextStyle(color: Theme.of(context).primaryColorLight),
      decoration: InputDecoration(
        filled: true,
        labelText: "키",
        labelStyle: TextStyle(color: Colors.grey),
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
      style: TextStyle(color: Theme.of(context).primaryColorLight),
      decoration: InputDecoration(
        filled: true,
        labelText: "몸무게",
        labelStyle: TextStyle(color: Colors.grey),
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
        height: 48.0,
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
        height: 48.0,
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

  Widget _editButton(context) {
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
            onPressed: () {
              _userProvider.setUserWeightAdd(
                  _toDay.toString(),
                  double.parse(_userWeightCtrl.text),
                  _userProvider.userdata.bodyStats.last.weight);
            },
            child: Text(isLoading ? 'loggin in.....' : "프로필 수정",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  void _editCheck() async {
    if (_userHeightCtrl.text != "" && _userWeightCtrl.text != "") {
      UserEdit(
              userEmail: _userProvider.userdata.email,
              userName: _userProvider.userdata.username,
              userNickname: _userProvider.userdata.nickname,
              userHeight: _userHeightCtrl.text.toString(),
              userWeight: _userWeightCtrl.text.toString(),
              userHeightUnit: _userHeightUnitCtrl,
              userWeightUnit: _userWeightUnitCtrl,
              userImage: _userProvider.userdata.image,
              userFavorExercise: _userProvider.userdata.favor_exercise)
          .editUser()
          .then((data) => data["username"] != null
              ? {
                  showToast("수정 완료"),
                  _userProvider.getdata(),
                  Navigator.pop(context)
                }
              : showToast("수정할 수 없습니다"));
    } else {
      showToast("키와 몸무게를 입력해주세요");
    }
  }
}
