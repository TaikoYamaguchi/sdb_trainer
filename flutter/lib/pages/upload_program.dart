import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';
import 'package:sdb_trainer/repository/history_repository.dart';
import 'package:sdb_trainer/repository/user_repository.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:transition/transition.dart';
import 'package:sdb_trainer/pages/userProfileNickname.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/pages/userProfileBody.dart';
import 'package:sdb_trainer/pages/userProfileGoal.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sdb_trainer/src/model/historydata.dart' as hisdata;
import 'dart:io';
import 'dart:async';

class ProgramUpload extends StatefulWidget {
  Routinedatas program;
  ProgramUpload(
      {Key? key,
        required this.program,})
      : super(key: key);

  @override
  _ProgramUploadState createState() => _ProgramUploadState();
}

class _ProgramUploadState extends State<ProgramUpload> {
  var _userdataProvider;
  var _famousdataProvider;
  var _workoutdataProvider;
  var _routinetimeProvider;
  var _btnDisabled;
  TextEditingController _famousimageCtrl = TextEditingController(text: "");
  TextEditingController _programtitleCtrl = TextEditingController(text: "");
  TextEditingController _programcommentCtrl = TextEditingController(text: "");
  File? _image;
  final ImagePicker _picker = ImagePicker();
  var _selectImage;
  String name = "";

  @override
  void initState() {
    super.initState();
  }

  Future _getImage(ImageSource imageSource) async {
    _selectImage =
    await _picker.pickImage(source: imageSource, imageQuality: 30);

    setState(() {
      _image = File(_selectImage!.path); // 가져온 이미지를 _image에 저장
    });
  }

  Future<void> _pickImg() async {
    final XFile? selectImage =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (selectImage != null) {
      _image = File(selectImage.path);
      // dynamic sendData = selectImage.path;
      // UserImageEdit(file: sendData).patchUserImage().then((data) {
      //    _userdataProvider.setUserdata(data);
      // });
    }
  }

  PreferredSizeWidget _appbarWidget() {
    _btnDisabled = false;
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined),
        onPressed: () {
          _btnDisabled == true
              ? null
              : [
            _btnDisabled = true,
            Navigator.of(context).pop(),
          ];
        },
      ),
      title: Text(
        "나의 Program 공유",
        style: TextStyle(color: Colors.white, fontSize: 30, ),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _exerciseDoneWidget() {
    return Column(
      children: [
        Container(
            child: Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    alignment: Alignment.centerLeft,
                    child: Text("Program 이름",
                        style: TextStyle(fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  _titleWidget(),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    alignment: Alignment.centerLeft,
                    child: Text("Program 설명",
                        style: TextStyle(fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  _commentWidget(),
                  Container(
                    height: 10,
                  ),
                  Container(
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Center(
                                        child: Icon(Icons.fitness_center,
                                            color: Colors.white, size: 40)),
                                  ),

                                  SizedBox(
                                      width: 120,
                                      child: Center(
                                          child: Icon(Icons.celebration,
                                              color: Colors.white, size: 40))),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      width: 120,
                                      child: Center(
                                        child: Text("Program 기간",
                                            style: TextStyle(color: Colors.white)),
                                      )),

                                  SizedBox(
                                      width: 120,
                                      child: Center(
                                        child: Text("신기록",
                                            style: TextStyle(color: Colors.white)),
                                      ))
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Center(
                                      child: Text('${widget.program.exercises[0].plans.length.toString()}days',
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ),

                                  SizedBox(
                                      width: 120,
                                      child: Center(
                                          child: Text("0",
                                              style: TextStyle(color: Colors.white)))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Theme.of(context).cardColor,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 8.0),
                            child: GestureDetector(
                              child: _image == null
                                  ? Icon(Icons.add_photo_alternate,
                                  color: Colors.white, size: 120)
                                  : Image.file(File(_image!.path)),
                              onTap: () {
                                _displayPhotoAlert();
                              },
                            )),
                      ),
                    ),
                  ),


                ]),
              ),
            )
        ),
        _exercise_Done_Button()
      ],
    );
  }

  void _displayPhotoAlert() {
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
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              disabledColor: Color.fromRGBO(246, 58, 64, 20),
                              disabledTextColor: Colors.black,
                              padding: EdgeInsets.all(8.0),
                              splashColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                _getImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.camera_alt, size: 24),
                                  Text('촬영', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            )),
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              disabledColor: Color.fromRGBO(246, 58, 64, 20),
                              disabledTextColor: Colors.black,
                              padding: EdgeInsets.all(8.0),
                              splashColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                _getImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.collections, size: 24),
                                  Text('갤러리', style: TextStyle(fontSize: 16)),
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

  Widget _exercise_Done_Button() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              disabledColor: Color.fromRGBO(246, 58, 64, 20),
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Theme.of(context).primaryColor,
              onPressed: () {



                ProgramPost(
                  image: _famousimageCtrl.text,
                  routinedata: new Routinedatas(name: _programtitleCtrl.text, mode: widget.program.mode, exercises: widget.program.exercises, routine_time: _programcommentCtrl.text),
                  type: 0,
                  user_email: _userdataProvider.userdata.email,)
                      .postProgram().then((data) => {
                    if (_selectImage != null) {
                        FamousImageEdit(
                        famous_id: data["id"],
                        file: _selectImage.path).patchFamousImage().then((data) => {
                        _famousdataProvider.getdata(),
                        })
                    } else{_famousdataProvider.getdata(),} ,

                });



                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("운동 등록",
                  style: TextStyle(fontSize: 20.0, color: Colors.white)))),
    );
  }

  Widget _titleWidget() {
    _programtitleCtrl.text == ""
    ? _programtitleCtrl.text = widget.program.name
    : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
          controller: _programtitleCtrl,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit, color: Colors.white),
              labelText: 'Program 이름을 바꿀 수 있어요',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: Colors.white),

          style: TextStyle(color: Colors.white)),
    );
  }

  Widget _commentWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
          controller: _programcommentCtrl,
          keyboardType: TextInputType.multiline,
          //expands: true,
          maxLines: null,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit, color: Colors.white),
              labelText: 'Program을 설명해주세요',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: Colors.white),

          style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _routinetimeProvider =
        Provider.of<RoutineTimeProvider>(context, listen: false);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appbarWidget(),
        body: _exerciseDoneWidget(),
        backgroundColor: Colors.black);
  }
}
