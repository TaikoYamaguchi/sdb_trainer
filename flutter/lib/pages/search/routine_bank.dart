import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/search/download_program.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/repository/famous_repository.dart';
import 'package:transition/transition.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RoutineBank extends StatefulWidget {
  const RoutineBank({Key? key}) : super(key: key);

  @override
  State<RoutineBank> createState() => _RoutineBankState();
}

class _RoutineBankState extends State<RoutineBank> {
  var _famousdataProvider;
  var _PopProvider;
  var _userProvider;
  Future<void> _onRefresh() {
    _famousdataProvider.getdata();
    return Future<void>.value();
  }

  Widget famous_pg() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                '유명 운동 Programs',
                textScaleFactor: 1.9,
                style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Consumer<FamousdataProvider>(builder: (builder, provider, child) {
          var userFamous = provider.famousdata.famouss.where((famouss) {
            return (famouss.type == 1);
          }).toList();
          return SizedBox(
            height: MediaQuery.of(context).size.width / 2 + 80,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: userFamous.length,
                itemBuilder: (BuildContext _context, int index) {
                  var program = userFamous[index];
                  return GestureDetector(
                    onTap: () {
                      _PopProvider.searchstackup();
                      _famousdataProvider.downloadset(userFamous[index]);
                      Navigator.push(
                          context,
                          Transition(
                              child: ProgramDownload(
                                program: userFamous[index],
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
                              padding: const EdgeInsets.all(4.0),
                              child: userFamous[index].image != ""
                                  ? CachedNetworkImage(
                                      imageUrl: userFamous[index].image,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      imageBuilder: (context, imageProivder) =>
                                          Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            image: DecorationImage(
                                              image: imageProivder,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    )
                                  : SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      child: const Icon(
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
                                          userFamous[index].routinedata.name,
                                          overflow: TextOverflow.ellipsis,
                                          textScaleFactor: 1.3,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight,
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
                                        SizedBox(
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
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                  size: 18),
                                              Text(
                                                ' ${userFamous[index].subscribe.toString()}',
                                                textScaleFactor: 1.1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
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
              padding: const EdgeInsets.all(10),
              child: Text(
                '유저가 만든 Programs',
                textScaleFactor: 1.9,
                style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Consumer<FamousdataProvider>(builder: (builder, provider, child) {
          var userFamous = provider.famousdata.famouss.where((famouss) {
            return (famouss.type == 0);
          }).toList();
          return SizedBox(
            height: MediaQuery.of(context).size.width / 2 + 80,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: userFamous.length,
                itemBuilder: (BuildContext _context, int index) {
                  var program = userFamous[index];
                  return GestureDetector(
                    onTap: () {
                      _PopProvider.searchstackup();
                      _famousdataProvider.downloadset(userFamous[index]);
                      Navigator.push(
                          context,
                          Transition(
                              child: ProgramDownload(
                                program: userFamous[index],
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
                              padding: const EdgeInsets.all(4.0),
                              child: userFamous[index].image != ""
                                  ? CachedNetworkImage(
                                      imageUrl: userFamous[index].image,
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      imageBuilder: (context, imageProivder) =>
                                          Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            image: DecorationImage(
                                              image: imageProivder,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    )
                                  : SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
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
                                          userFamous[index].routinedata.name,
                                          textScaleFactor: 1.3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight,
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
                                        SizedBox(
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
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                  size: 18),
                                              Text(
                                                ' ${userFamous[index].subscribe.toString()}',
                                                textScaleFactor: 1.1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
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
    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          children: [famous_pg(), user_pg()],
        ));
  }

  Widget _famousLikeButton(program) {
    var buttonSize = 18.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: LikeButton(
        size: buttonSize,
        isLiked: onIsLikedCheck(program),
        circleColor:
            const CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
        bubblesColor: const BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              Icons.thumb_up_off_alt_rounded,
              color: isLiked
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColorLight,
              size: buttonSize,
            ),
          );
        },
        onTap: (bool isLiked) async {
          return onLikeButtonTapped(isLiked, program);
        },
        likeCount: program.like.length,
        countBuilder: (int? count, bool isLiked, String text) {
          var color = isLiked
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColorLight;
          Widget result;
          if (count == 0) {
            result = Text(
              text,
              textScaleFactor: 1.2,
              style: TextStyle(color: color),
            );
          } else
            result = Text(
              text,
              textScaleFactor: 1.1,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            );
          return result;
        },
      ),
    );
  }

  bool onIsLikedCheck(program) {
    if (program.like.contains(_userProvider.userdata.email)) {
      return true;
    } else {
      return false;
    }
  }

  bool onLikeButtonTapped(bool isLiked, program) {
    if (isLiked == true) {
      FamousLike(
              famous_id: program.id,
              user_email: _userProvider.userdata.email,
              status: "remove",
              disorlike: "like")
          .patchFamousLike();
      _famousdataProvider.patchFamousLikedata(
          program, _userProvider.userdata.email, "remove");
      return false;
    } else {
      FamousLike(
              famous_id: program.id,
              user_email: _userProvider.userdata.email,
              status: "append",
              disorlike: "like")
          .patchFamousLike();
      _famousdataProvider.patchFamousLikedata(
          program, _userProvider.userdata.email, "append");
      return !isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserdataProvider>(context, listen: false);
    _famousdataProvider =
        Provider.of<FamousdataProvider>(context, listen: false);
    _PopProvider = Provider.of<PopProvider>(context, listen: false);
    return famous_body();
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
