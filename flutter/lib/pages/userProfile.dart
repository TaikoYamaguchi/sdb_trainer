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
import 'package:cached_network_image/cached_network_image.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _userdataProvider;
  var _PopProvider;
  var _selectImage;
  File? _image;
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
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          title: Text(
            "",
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          backgroundColor: Color(0xFF101012),
        ));
  }

  Future _getImage(ImageSource imageSource) async {
    _selectImage =
        await _picker.pickImage(source: imageSource, imageQuality: 30);

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
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.0)),
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
                                  color: Colors.white,
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
                                      size: 24, color: Colors.white),
                                  Text('촬영',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
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
                                  color: Colors.white,
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
                                      size: 24, color: Colors.white),
                                  Text('갤러리',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
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
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).cardColor)),
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
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).cardColor)),
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
                            _userdataProvider.userdata.bodyStats.last.weight
                                .toString() +
                            _userdataProvider.userdata.weight_unit,
                        style: TextStyle(color: Colors.white)),
                    Icon(Icons.chevron_right, color: Colors.white),
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
                    Text(_userdataProvider.userdata.isMan ? "남성" : "여성",
                        style: TextStyle(color: Colors.white)),
                    Container(),
                  ])),
        ),
        SizedBox(height: 30),
        GestureDetector(
            onTap: () {
              _displayPhotoDialog();
            },
            child: _userdataProvider.userdata.image == ""
                ? Icon(
                    Icons.account_circle,
                    color: Colors.grey,
                    size: 200.0,
                  )
                : Consumer<UserdataProvider>(
                    builder: (builder, rpovider, child) {
                    return CachedNetworkImage(
                      imageUrl: _userdataProvider.userdata.image,
                      imageBuilder: (context, imageProivder) => Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
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
            child: Text("사진 편집", style: TextStyle(color: Colors.white)))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
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
          backgroundColor: Color(0xFF101012));
    });
  }
}
