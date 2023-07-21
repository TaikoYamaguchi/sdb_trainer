import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';
import 'package:sdb_trainer/src/model/workoutdata.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

// ignore: must_be_immutable
class ProgramUpload extends StatefulWidget {
  Routinedatas program;
  ProgramUpload({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  _ProgramUploadState createState() => _ProgramUploadState();
}

class _ProgramUploadState extends State<ProgramUpload> {
  var _userProvider;
  var _famousdataProvider;
  var _btnDisabled;
  final TextEditingController _famousimageCtrl =
      TextEditingController(text: "");
  final TextEditingController _programtitleCtrl =
      TextEditingController(text: "");
  final TextEditingController _programcommentCtrl =
      TextEditingController(text: "");
  File? _image;
  final ImagePicker _picker = ImagePicker();
  var _selectImage;
  String name = "";
  List<String> items = ['뉴비', '초급', '중급', '상급', '엘리트'];
  var selectedItem = '뉴비';
  Map item_map = {"뉴비": 0, "초급": 1, '중급': 2, '상급': 3, '엘리트': 4};

  List<String> items2 = ['기타', '근비대', '근력', '근지구력', '바디빌딩', '파워리프팅', '역도'];
  List<String> selectedItem2 = [];
  Map item_map2 = {
    "기타": 0,
    "근비대": 1,
    '근력': 2,
    '근지구력': 3,
    '바디빌딩': 4,
    '파워리프팅': 5,
    '역도': 6
  };

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

  PreferredSizeWidget _appbarWidget() {
    _btnDisabled = false;
    return PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).primaryColorLight,
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
            textScaleFactor: 1.5,
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          backgroundColor: Theme.of(context).canvasColor,
        ));
  }

  Widget _exerciseDoneWidget() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.centerLeft,
                child: Text("Program 이름:",
                    textScaleFactor: 2.1,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontWeight: FontWeight.bold)),
              ),
              _titleWidget(),
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Program 난이도:",
                        textScaleFactor: 2.1,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 2 / 5,
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorLight,
                                  width: 3),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 3),
                            ),
                          ),
                          hint: Align(
                              alignment: Alignment.center,
                              child: Text(
                                '난이도',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight),
                              )),
                          items: items
                              .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                      ))))
                              .toList(),
                          onChanged: (item) =>
                              setState(() => selectedItem = item as String),
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Program 목적:",
                        textScaleFactor: 2.1,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontWeight: FontWeight.bold)),
                    /*
                SizedBox(
                    width: MediaQuery.of(context).size.width * 2 / 5,
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColorLight, width: 3),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 3),
                        ),
                      ),
                      hint: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '목적',
                            style: TextStyle(color: Theme.of(context).primaryColorLight),
                          )),
                      items: items2
                          .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    item,
                                    style: TextStyle(color: Theme.of(context).primaryColorLight),
                                  ))))
                          .toList(),
                      onChanged: (item) =>
                          setState(() => selectedItem2 = item as String),
                    )
                ),

                 */
                  ],
                ),
              ),
              pulposechip(),
              Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.centerLeft,
                child: Text("Program 설명:",
                    textScaleFactor: 1.7,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontWeight: FontWeight.bold)),
              ),
              _commentWidget(),
              Container(
                height: 10,
              ),
              SizedBox(
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 8.0),
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
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        size: 40)),
                              ),
                              SizedBox(
                                  width: 120,
                                  child: Center(
                                      child: Icon(Icons.celebration,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          size: 40))),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width: 120,
                                  child: Center(
                                    child: Text("Program 기간",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight)),
                                  )),
                              SizedBox(
                                  width: 120,
                                  child: Center(
                                    child: Text("신기록",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight)),
                                  ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Center(
                                  child: Text(
                                      '${widget.program.exercises[0].plans.length.toString()}days',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorLight)),
                                ),
                              ),
                              SizedBox(
                                  width: 120,
                                  child: Center(
                                      child: Text("0",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight)))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
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
                                  color: Theme.of(context).primaryColorLight,
                                  size: 120)
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
                                padding: const EdgeInsets.all(8.0),
                              ),
                              onPressed: () {
                                _getImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 24,
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  Text('촬영',
                                      textScaleFactor: 1.3,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      )),
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
                                padding: const EdgeInsets.all(8.0),
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

  Widget pulposechip() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Consumer<FamousdataProvider>(builder: (context, provider, child) {
        return ChipsChoice<String>.multiple(
          value: provider.tags,
          onChanged: (val) {
            provider.settags(val);
          },
          choiceItems: C2Choice.listFrom<String, String>(
            source: items2,
            value: (i, v) => v,
            label: (i, v) => v,
            tooltip: (i, v) => v,
          ),
          wrapped: true,
          choiceStyle: C2ChipStyle.filled(
            selectedStyle: C2ChipStyle(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            color: Color(0xff40434e),
          ),
        );
      }),
    );
  }

  Widget _exercise_Done_Button() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
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
                padding: const EdgeInsets.all(8.0),
              ),
              onPressed: () {
                ProgramPost(
                  image: _famousimageCtrl.text,
                  routinedata: Routinedatas(
                    name: _programtitleCtrl.text,
                    mode: widget.program.mode,
                    exercises: [
                      Program(
                          progress: 0, plans: widget.program.exercises[0].plans)
                    ],
                    routine_time: _programcommentCtrl.text,
                  ),
                  type: 0,
                  user_email: _userProvider.userdata.email,
                  level: item_map[selectedItem],
                  category: _famousdataProvider.tags,
                ).postProgram().then((data) => {
                      if (_selectImage != null)
                        {
                          FamousImageEdit(
                                  famous_id: data["id"],
                                  file: _selectImage.path)
                              .patchFamousImage()
                              .then((data) => {
                                    _famousdataProvider.getdata(),
                                  })
                        }
                      else
                        {
                          _famousdataProvider.getdata(),
                        },
                    });
                _famousdataProvider.emptytags();

                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("운동 등록",
                  textScaleFactor: 1.7,
                  style:
                      TextStyle(color: Theme.of(context).primaryColorLight)))),
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
              prefixIcon:
                  Icon(Icons.edit, color: Theme.of(context).primaryColorLight),
              labelText: 'Program 이름을 바꿀 수 있어요',
              labelStyle: TextStyle(color: Theme.of(context).primaryColorLight),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColorLight, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColorLight, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: Theme.of(context).primaryColorLight),
          style: TextStyle(color: Theme.of(context).primaryColorLight)),
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
              prefixIcon:
                  Icon(Icons.edit, color: Theme.of(context).primaryColorLight),
              labelText: 'Program을 설명해주세요',
              labelStyle: TextStyle(color: Theme.of(context).primaryColorLight),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColorLight, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColorLight, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: Theme.of(context).primaryColorLight),
          style: TextStyle(color: Theme.of(context).primaryColorLight)),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appbarWidget(),
      body: _exerciseDoneWidget(),
    );
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
