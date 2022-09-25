import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/download_program.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:transition/transition.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RoutineBank extends StatefulWidget {
  const RoutineBank({Key? key}) : super(key: key);

  @override
  State<RoutineBank> createState() => _RoutineBankState();
}

class _RoutineBankState extends State<RoutineBank> {
  var _famousdataProvider;
  var _workoutdataProvider;
  var _historydataProvider;
  var _routinetimeProvider;
  var _PopProvider;
  var _userdataProvider;
  var _exercisesdataProvider;

  Widget famous_pg() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                '유명 운동 Programs',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Consumer<FamousdataProvider>(builder: (builder, provider, child) {
          var user_famous = provider.famousdata.famouss.where((famouss) {
            return (famouss.type == 1);
          }).toList();
          return Container(
            height: MediaQuery.of(context).size.width / 2 + 80,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: user_famous.length,
                itemBuilder: (BuildContext _context, int index) {
                  var program = user_famous[index];
                  return GestureDetector(
                    onTap: () {
                      _famousdataProvider.downloadset(user_famous[index]);
                      Navigator.push(
                          context,
                          Transition(
                              child: ProgramDownload(
                                program: user_famous[index],
                              ),
                              transitionEffect:
                                  TransitionEffect.RIGHT_TO_LEFT));
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Card(
                        color: Theme.of(context).cardColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: user_famous[index].image != ""
                                  ? CachedNetworkImage(
                                      imageUrl: user_famous[index].image,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      imageBuilder: (context, imageProivder) =>
                                          Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                            image: DecorationImage(
                                              image: imageProivder,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    )
                                  : Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 70,
                                      )),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user_famous[index].routinedata.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4 -
                                              20,
                                          child: Row(
                                            children: [
                                              _famousLikeButton(program),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4 -
                                              20,
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .supervised_user_circle_sharp,
                                                  color: Colors.white,
                                                  size: 18),
                                              Text(
                                                ' ${user_famous[index].subscribe.toString()}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        }),
      ],
    );
  }

  Widget user_pg() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                '유저가 만든 Programs',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Consumer<FamousdataProvider>(builder: (builder, provider, child) {
          var user_famous = provider.famousdata.famouss.where((famouss) {
            return (famouss.type == 0);
          }).toList();
          return Container(
            height: MediaQuery.of(context).size.width / 2 + 80,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: user_famous.length,
                itemBuilder: (BuildContext _context, int index) {
                  var program = user_famous[index];
                  return GestureDetector(
                    onTap: () {
                      _famousdataProvider.downloadset(user_famous[index]);
                      Navigator.push(
                          context,
                          Transition(
                              child: ProgramDownload(
                                program: user_famous[index],
                              ),
                              transitionEffect:
                                  TransitionEffect.RIGHT_TO_LEFT));
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Card(
                        color: Theme.of(context).cardColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: user_famous[index].image != ""
                                  ? CachedNetworkImage(
                                      imageUrl: user_famous[index].image,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      imageBuilder: (context, imageProivder) =>
                                          Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                            image: DecorationImage(
                                              image: imageProivder,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    )
                                  : Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 70,
                                      )),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user_famous[index].routinedata.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4 -
                                              20,
                                          child: Row(
                                            children: [
                                              _famousLikeButton(program),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4 -
                                              20,
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .supervised_user_circle_sharp,
                                                  color: Colors.white,
                                                  size: 18),
                                              Text(
                                                ' ${user_famous[index].subscribe.toString()}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        }),
      ],
    );
  }

  Widget famous_body() {
    return ListView(
      children: [famous_pg(), user_pg()],
    );
  }

  Widget _famousLikeButton(program) {
    var buttonSize = 18.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: LikeButton(
        size: buttonSize,
        isLiked: onIsLikedCheck(program),
        circleColor:
            CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
        bubblesColor: BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              Icons.thumb_up_off_alt_rounded,
              color: isLiked ? Theme.of(context).primaryColor : Colors.white,
              size: buttonSize,
            ),
          );
        },
        onTap: (bool isLiked) async {
          return onLikeButtonTapped(isLiked, program);
        },
        likeCount: program.like.length,
        countBuilder: (int? count, bool isLiked, String text) {
          var color = isLiked ? Theme.of(context).primaryColor : Colors.white;
          Widget result;
          if (count == 0) {
            result = Text(
              text,
              style: TextStyle(color: color, fontSize: 14.0),
            );
          } else
            result = Text(
              text,
              style: TextStyle(
                  color: color, fontSize: 14.0, fontWeight: FontWeight.bold),
            );
          return result;
        },
      ),
    );
  }

  bool onIsLikedCheck(program) {
    if (program.like.contains(_userdataProvider.userdata.email)) {
      return true;
    } else {
      return false;
    }
  }

  bool onLikeButtonTapped(bool isLiked, program) {
    if (isLiked == true) {
      FamousLike(
              famous_id: program.id,
              user_email: _userdataProvider.userdata.email,
              status: "remove",
              disorlike: "like")
          .patchFamousLike();
      _famousdataProvider.patchFamousLikedata(
          program, _userdataProvider.userdata.email, "remove");
      return false;
    } else {
      FamousLike(
              famous_id: program.id,
              user_email: _userdataProvider.userdata.email,
              status: "append",
              disorlike: "like")
          .patchFamousLike();
      _famousdataProvider.patchFamousLikedata(
          program, _userdataProvider.userdata.email, "append");
      return !isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    return famous_body();
  }
}
