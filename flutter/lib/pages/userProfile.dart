import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/src/utils/util.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileNickname.dart';
import 'package:sdb_trainer/pages/userProfileBody.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _userProvider;
  var _PopProvider;
  var _selectImage;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    return Consumer<PopProvider>(builder: (Builder, provider, child) {
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
      );
    });
  }

  Future<void> _pickImg() async {
    final XFile? selectImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (selectImage != null) {
      dynamic sendData = selectImage.path;
      UserImageEdit(file: sendData).patchUserImage().then((data) {
        _userProvider.setUserdata(data);
      });
    }
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

  Future _getImage(ImageSource imageSource) async {
    _selectImage =
        await _picker.pickImage(source: imageSource, imageQuality: 30);
    if (_selectImage != null) {
      dynamic sendData = _selectImage.path;
      UserImageEdit(file: sendData).patchUserImage().then((data) {
        _userProvider.setUserdata(data);
      });
    }

    setState(() {
      _image = File(_selectImage!.path); // 가져온 이미지를 _image에 저장
    });
  }

  void _displayPhotoDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                      child: Text("사진을 올릴 방법을 고를 수 있어요",
                          textScaleFactor: 1.3,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
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
                                disabledForegroundColor:
                                    Color.fromRGBO(246, 58, 64, 20),
                                padding: EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                _getImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 24,
                                      color:
                                          Theme.of(context).primaryColorLight),
                                  Text('촬영',
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)),
                                ],
                              ),
                            )),
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
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
                                disabledForegroundColor:
                                    Color.fromRGBO(246, 58, 64, 20),
                                padding: EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                _getImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.collections,
                                      size: 24,
                                      color:
                                          Theme.of(context).primaryColorLight),
                                  Text('갤러리',
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  void _displayUserDeleteAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            title: Text('정말 탈퇴 하시나요?',
                textScaleFactor: 2.0,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).primaryColorLight)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('더 많은 기능을 준비 중 이에요',
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                Text('데이터를 지우면 복구 할 수 없어요',
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            actions: <Widget>[
              _DeleteConfirmButton(),
            ],
          );
        });
  }

  void _displayUserLogoutAfterDeleteAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
              onWillPop: () => Future.value(false),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Theme.of(context).cardColor,
                title: Text('탈퇴가 완료되었어요',
                    textScaleFactor: 2.0,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('더 나은 모습으로 발전할게요',
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                actions: <Widget>[
                  _LogOutAfterDeleteButton(),
                ],
              ));
        });
  }

  Widget _DeleteConfirmButton() {
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
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              final storage = FlutterSecureStorage();

              UserDelete().deleteUser().then((data) {
                if (data!.email != "") {
                  Navigator.of(context, rootNavigator: true).pop();
                  _displayUserLogoutAfterDeleteAlert();
                }
              });
              storage.deleteAll();
              print('storage delete ok');
            },
            child: Text("탈퇴",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  Widget _LogOutAfterDeleteButton() {
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
              disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
              padding: EdgeInsets.all(12.0),
            ),
            onPressed: () {
              userLogOut(context);
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text("로그아웃",
                textScaleFactor: 1.7,
                style: TextStyle(color: Theme.of(context).primaryColorLight))));
  }

  Widget _userProfileWidget() {
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
        child: SingleChildScrollView(
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
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).cardColor)),
              child: Consumer<UserdataProvider>(
                  builder: (builder, rpovider, child) {
                return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_userProvider.userdata.nickname,
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight)),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).primaryColorDark),
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
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).cardColor)),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            _userProvider.userdata.height.toString() +
                                _userProvider.userdata.height_unit +
                                "/" +
                                _userProvider.userdata.bodyStats.last.weight
                                    .toString() +
                                _userProvider.userdata.weight_unit,
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorDark),
                      ])),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).cardColor)),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_userProvider.userdata.isMan ? "남성" : "여성",
                            textScaleFactor: 1.1,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight)),
                        Container(),
                      ])),
            ),
            ElevatedButton(
              onPressed: () {
                _displayUserDeleteAlert();
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).cardColor)),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("회원탈퇴",
                            textScaleFactor: 1.1,
                            style: TextStyle(color: Colors.grey)),
                        Icon(Icons.chevron_right,
                            color: Theme.of(context).primaryColorDark),
                      ])),
            ),
            const SizedBox(height: 30),
            GestureDetector(
                onTap: () {
                  _displayPhotoDialog();
                },
                child: _userProvider.userdata.image == ""
                    ? Icon(
                        Icons.account_circle,
                        color: Colors.grey,
                        size: 200.0,
                      )
                    : Consumer<UserdataProvider>(
                        builder: (builder, rpovider, child) {
                        return CachedNetworkImage(
                          imageUrl: _userProvider.userdata.image,
                          imageBuilder: (context, imageProivder) => Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                image: DecorationImage(
                                  image: imageProivder,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        );
                      })),
            TextButton(
                onPressed: () {
                  _displayPhotoDialog();
                },
                child: Text("사진 편집",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)))
          ]),
        ));
  }
}
