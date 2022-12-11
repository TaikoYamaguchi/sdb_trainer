import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

const USER_NICK_NAME = "USER_NICK_NAME";
const STATUS_LOGIN = 'STATUS_LOGIN';
const STATUS_LOGOUT = "STATUS_LOGOUT";

void showToast(String message) {
  Fluttertoast.showToast(
      fontSize: 13,
      msg: ' $message',
      backgroundColor: const Color(0xff7a28cb),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM);
}

void userLogOut(context) {
  print("loggggggout");
  var _loginState = Provider.of<LoginPageProvider>(context, listen: false);
  var _userProvider = Provider.of<UserdataProvider>(context, listen: false);
  _userProvider.setUserKakaoEmail(null);
  _userProvider.setUserKakaoName(null);
  _userProvider.setUserKakaoImageUrl(null);
  _userProvider.setUserKakaoGender(null);
  UserLogOut.logOut();
  _loginState.change(false);
  _loginState.changeSignup(false);
}

Future _getUserImage(ImageSource imageSource, context) async {
  final ImagePicker _picker = ImagePicker();
  var _userProvider = Provider.of<UserdataProvider>(context, listen: false);
  final XFile? _selectImage =
      await _picker.pickImage(source: imageSource, imageQuality: 30);
  if (_selectImage != null) {
    dynamic sendData = _selectImage.path;
    UserImageEdit(file: sendData).patchUserImage().then((data) {
      _userProvider.setUserdata(data);
    });
  }
}

void displayPhotoDialog(context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: Text("사진을 어디서 가져올까요?",
                        style: TextStyle(color: Colors.white, fontSize: 16.0)),
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
                              _getUserImage(ImageSource.camera, context);
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
                              _getUserImage(ImageSource.gallery, context);
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

void displayErrorAlert(context, title, message) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Theme.of(context).cardColor,
          title: Text(title,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.white, fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          actions: <Widget>[
            _DeleteConfirmButton(context),
          ],
        );
      });
}

Widget _DeleteConfirmButton(context) {
  return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).primaryColor,
            textStyle: TextStyle(
              color: Colors.white,
            ),
            disabledForegroundColor: Color.fromRGBO(246, 58, 64, 20),
            padding: EdgeInsets.all(12.0),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text("확인",
              style: TextStyle(fontSize: 20.0, color: Colors.white))));
}

Future<Map<String, dynamic>> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceData = <String, dynamic>{};

  try {
    if (Platform.isAndroid) {
      deviceData = _readAndroidDeviceInfo(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  } catch (error) {
    deviceData = {"Error": "Failed to get platform version."};
  }

  return deviceData;
}

Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo info) {
  var release = info.version.release;
  var sdkInt = info.version.sdkInt;
  var manufacturer = info.manufacturer;
  var model = info.model;

  return {
    "OS 버전": "Android $release (SDK $sdkInt)",
    "기기": "$manufacturer $model"
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo info) {
  var systemName = info.systemName;
  var version = info.systemVersion;
  var machine = info.utsname.machine;

  return {"OS 버전": "$systemName $version", "기기": "$machine"};
}

Future<Map<String, dynamic>> getAppInfo() async {
  PackageInfo info = await PackageInfo.fromPlatform();
  return {"Supero 버전": info.version};
}
