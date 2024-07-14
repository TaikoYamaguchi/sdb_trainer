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
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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
  var loginState = Provider.of<LoginPageProvider>(context, listen: false);
  var userProvider = Provider.of<UserdataProvider>(context, listen: false);
  userProvider.setUserKakaoEmail(null);
  userProvider.setUserKakaoName(null);
  userProvider.setUserKakaoImageUrl(null);
  userProvider.setUserKakaoGender(null);
  loginState.changeSignup(false);
  userProvider.getUsersFriendsAll();
  loginState.change(false);
  UserLogOut.logOut();
}

Future _getUserImage(ImageSource imageSource, context) async {
  final ImagePicker picker = ImagePicker();
  var userProvider = Provider.of<UserdataProvider>(context, listen: false);
  final XFile? selectImage =
      await picker.pickImage(source: imageSource, imageQuality: 30);
  if (selectImage != null) {
    dynamic sendData = selectImage.path;
    UserImageEdit(file: sendData).patchUserImage().then((data) {
      userProvider.setUserdata(data);
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
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                    child: Text("사진을 어디서 가져올까요?",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 16.0)),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
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
                                    const Color.fromRGBO(246, 58, 64, 20),
                                padding: const EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                _getUserImage(ImageSource.camera, context);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 24,
                                      color: Theme.of(context).highlightColor),
                                  Text('촬영',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .highlightColor)),
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
                                    const Color.fromRGBO(246, 58, 64, 20),
                                padding: const EdgeInsets.all(12.0),
                              ),
                              onPressed: () {
                                _getUserImage(ImageSource.gallery, context);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.collections,
                                      size: 24,
                                      color: Theme.of(context).highlightColor),
                                  Text('갤러리',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .highlightColor)),
                                ],
                              ),
                            )),
                      ],
                    ),
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
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight, fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 14)),
            ],
          ),
          actions: <Widget>[
            _deleteConfirmButton(context),
          ],
        );
      });
}

Widget _deleteConfirmButton(context) {
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
              color: Theme.of(context).primaryColorLight,
            ),
            disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
            padding: const EdgeInsets.all(12.0),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text("확인",
              style: TextStyle(
                  fontSize: 20.0, color: Theme.of(context).highlightColor))));
}

void displayShareAlert(context, title, message) {
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
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight, fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 14)),
            ],
          ),
          actions: <Widget>[
            Builder(builder: (BuildContext context) {
              return _shareConfirmButton(context);
            })
          ],
        );
      });
}

Widget _shareConfirmButton(context) {
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
              color: Theme.of(context).primaryColorLight,
            ),
            disabledForegroundColor: const Color.fromRGBO(246, 58, 64, 20),
            padding: const EdgeInsets.all(12.0),
          ),
          onPressed: () async {
// _onShare method:
            final box = context.findRenderObject() as RenderBox?;

            const appStoreURL =
                "https://apps.apple.com/kr/app/supero/id6444859542";
            const playStoreURL =
                "https://play.google.com/store/apps/details?id=com.tk_lck.supero";
            await Share.share(
                "Supero에서 같이 운동해요💪\n\n운동과 기록도 하고 무게도 올리고 공유 할 수 있어요😁\n\n아래 눌러서 설치해요\n\n- PlayStore : $playStoreURL\n\n- AppStore : $appStoreURL",
                sharePositionOrigin:
                    box!.localToGlobal(Offset.zero) & box.size);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text("공유하기",
              style: TextStyle(
                  fontSize: 20.0, color: Theme.of(context).highlightColor))));
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

Future<bool> requestCameraPermission(BuildContext context) async {
  // 권한 요청
  PermissionStatus status = await Permission.notification.request();
  // 결과 확인
  if (!status.isGranted) {
    // 허용이 안된 경우
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // 권한없음을 다이얼로그로 알림
          return AlertDialog(
            content: const Text("권한 설정을 확인해주세요."),
            actions: [
              TextButton(
                  onPressed: () {
                    openAppSettings(); // 앱 설정으로 이동
                  },
                  child: const Text('설정하기')),
            ],
          );
        });
    return false;
  }
  return true;
}

class CustomIconButton extends StatelessWidget {
  final Icon icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  CustomIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: "");
    }

    final double value = double.parse(newValue.text);
    if (value == null) {
      // 입력이 올바르지 않은 경우 빈 값을 반환하여 입력을 거부합니다.
      return TextEditingValue.empty;
    }

    final String newText = value.toStringAsFixed(1);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class ExpandableCustomIcon extends StatefulWidget {
  final bool isExpanded;
  final Duration duration;
  final IconData icon;
  final Color color;

  const ExpandableCustomIcon({
    Key? key,
    required this.isExpanded,
    required this.icon,
    required this.color,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _ExpandableIconState createState() => _ExpandableIconState();
}

class _ExpandableIconState extends State<ExpandableCustomIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(_controller);

    if (widget.isExpanded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ExpandableCustomIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Icon(Icons.expand_more, color: widget.color),
    );
  }
}
