import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/repository/exercises_repository.dart';
import 'package:sdb_trainer/src/utils/my_flexible_space_bar.dart';
import 'package:sdb_trainer/src/utils/util.dart';

class ExerciseGuide extends StatefulWidget {
  int eindex;
  ExerciseGuide({Key? key, required this.eindex}) : super(key: key);

  @override
  State<ExerciseGuide> createState() => _ExerciseGuideState();
}

class _ExerciseGuideState extends State<ExerciseGuide> {
  var btnDisabled;
  var _userdataProvider;
  var _exercisesdataProvider;
  TextEditingController _exercisenoteCtrl = TextEditingController(text: '');
  bool editing = false;
  var _exercises;

  PreferredSizeWidget _appbarWidget() {
    btnDisabled = false;
    return AppBar(
      titleSpacing: 0,
      leading:Center(
        child: GestureDetector(
          child: Icon(Icons.arrow_back_ios_outlined),
          onTap: () {
            btnDisabled == true
                ? null
                : [btnDisabled = true, Navigator.of(context).pop()];
          },
        ),
      ),
      title: Container(
      ),
      actions: null,
      backgroundColor: Colors.black,
    );
  }

  Widget Status() {
    return Container(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8.0),
            child: Consumer<ExercisesdataProvider>(
                builder: (context, provier, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 5,
                            child: Center(
                              child: Text("1rm",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            )),
                        SizedBox(
                          width: 100,
                          child: Center(
                            child: Text(
                                '${provier.exercisesdata.exercises[widget.eindex].onerm.toStringAsFixed(0)}${_userdataProvider.userdata.weight_unit}',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 5,
                            child: Center(
                              child: Text("Goal",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            )),
                        SizedBox(
                          width: 100,
                          child: Center(
                            child: Text(
                                '${provier.exercisesdata.exercises[widget.eindex].goal.toStringAsFixed(0)}${_userdataProvider.userdata.weight_unit}',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),

                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget exercisenote() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.centerLeft,
                child: Text("나만의 운동 Note",
                    style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
              editing
                  ? Container(
                    child: IconButton(
                      onPressed: (){
                        _exercisesdataProvider.exercisesdata.exercises[widget.eindex].note = _exercisenoteCtrl.text;
                        _postExerciseCheck();
                        setState(() {
                          editing = !editing;


                        });
                      },
                      icon: Icon(Icons.check, size: 30, color: Theme.of(context).primaryColor,),
                    ),
                  )

                  : Container(
                    child: IconButton(
                      onPressed: (){
                        setState(() {
                          editing = !editing;
                        });
                      },
                      icon: Icon(Icons.edit, size: 25, color: Colors.white,),
                    ),
                  )
            ],
          ),
          editing
              ? _commentWidget()
              : Container(
                padding: const EdgeInsets.all(12.0),
                alignment: Alignment.centerLeft,
                child: Consumer<ExercisesdataProvider>(
                  builder: (context, provier, child) {
                    return Text(provier.exercisesdata.exercises[widget.eindex].note ?? '나만의 운동노트를 적어주세요',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold));
                  }
                ),
              ),
        ],
      ),
    );
  }

  void _postExerciseCheck() async {
    ExerciseEdit(
        user_email: _userdataProvider.userdata.email, exercises: _exercisesdataProvider.exercisesdata.exercises)
        .editExercise()
        .then((data) => data["user_email"] != null
        ? {showToast("수정 완료"), _exercisesdataProvider.getdata()}
        : showToast("입력을 확인해주세요"));
  }

  Widget _commentWidget() {
    _exercisenoteCtrl.text= _exercisesdataProvider.exercisesdata.exercises[widget.eindex].note ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
          controller: _exercisenoteCtrl,
          keyboardType: TextInputType.multiline,
          //expands: true,
          maxLines: null,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit, color: Colors.white),
              labelText: '운동에 대한 노트를 적어주세요',
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
    _exercisesdataProvider = Provider.of<ExercisesdataProvider>(context, listen: false);
    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
              snap: true,
              floating: true,
              pinned: true,
              actions: [
              ],
              leading: Center(
                child: GestureDetector(
                  child: Icon(Icons.arrow_back_ios_outlined),
                  onTap: () {
                    btnDisabled == true
                        ? null
                        : [btnDisabled = true, Navigator.of(context).pop()];
                  },
                ),
              ),
              expandedHeight: _appbarWidget().preferredSize.height*2,
              collapsedHeight: _appbarWidget().preferredSize.height,
              backgroundColor: Colors.black,

              flexibleSpace: myFlexibleSpaceBar(
                expandedTitleScale: 1.2,
                titlePaddingTween: EdgeInsetsTween(begin: EdgeInsets.only(left: 12.0, bottom: 8), end: EdgeInsets.only(left: 60.0, bottom: 8)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        _exercisesdataProvider.exercisesdata.exercises[widget.eindex].name,
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      )
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, _index) {
                return Container(
                  child: Column(
                    children: [
                      Status(),
                      exercisenote()
                    ],
                  ),
                );
              },
                childCount: 1,
              ),
            )
          ]
      ),
      backgroundColor: Colors.black,
    );
  }
}
