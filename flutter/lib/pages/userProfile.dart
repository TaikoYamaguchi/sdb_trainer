import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileNickname.dart';
import 'package:sdb_trainer/pages/userProfileBody.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _userdataProvider;
  var _PopProvider;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImg() async {
    final XFile? selectImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (selectImage != null) {
      dynamic sendData = selectImage.path;
      UserImageEdit(file: sendData).patchUserImage().then((data) {
        _userdataProvider.setUserdata(data);
      });
    }
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

  Widget _userProfileWidget() {
    return SingleChildScrollView(
      child: Column(children: [
        ElevatedButton(
          onPressed: () {
            _PopProvider.profilestackup();
            Navigator.push(
                context,
                Transition(
                    child: ProfileNickname(),
                    transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF212121))),
          child:
              Consumer<UserdataProvider>(builder: (builder, rpovider, child) {
            return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_userdataProvider.userdata.nickname,
                          style: TextStyle(color: Colors.white)),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ]));
          }),
        ),
        ElevatedButton(
          onPressed: () {
            _PopProvider.profilestackup();
            Navigator.push(
                context,
                Transition(
                    child: ProfileBody(),
                    transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF212121))),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        _userdataProvider.userdata.height.toString() +
                            _userdataProvider.userdata.height_unit +
                            "/" +
                            _userdataProvider.userdata.weight.toString() +
                            _userdataProvider.userdata.weight_unit,
                        style: TextStyle(color: Colors.white)),
                    Icon(Icons.chevron_right, color: Colors.white),
                  ])),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF212121))),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_userdataProvider.userdata.isMan ? "??????" : "??????",
                        style: TextStyle(color: Colors.white)),
                    Container(),
                  ])),
        ),
        SizedBox(height: 30),
        GestureDetector(
            onTap: () {
              _pickImg();
            },
            child: _userdataProvider.userdata.image == ""
                ? Icon(
                    Icons.account_circle,
                    color: Colors.grey,
                    size: 200.0,
                  )
                : Consumer<UserdataProvider>(
                    builder: (builder, rpovider, child) {
                    return CircleAvatar(
                        radius: 100.0,
                        backgroundImage:
                            NetworkImage(_userdataProvider.userdata.image),
                        backgroundColor: Colors.transparent);
                  })),
        FlatButton(
            onPressed: () {
              _pickImg();
            },
            child: Text("?????? ??????", style: TextStyle(color: Colors.white)))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    print("this is profileeeeeeeeee");
    return Consumer<PopProvider>(
        builder: (Builder, provider, child)
    {
      bool _popable = provider.isprostacking;
      _popable == false
          ? null
          : [
        provider.profilestackdown(),
        provider.propopoff(),
        Future.delayed(Duration.zero, () async {
          Navigator.of(context).pop();
        })
      ];
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _appbarWidget(),
          body: _userProfileWidget(),
          backgroundColor: Colors.black);
    });
  }
}
