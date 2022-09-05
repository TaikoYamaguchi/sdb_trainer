import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/download_program.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:transition/transition.dart';

class RoutineBank extends StatefulWidget {
  const RoutineBank({Key? key}) : super(key: key);

  @override
  State<RoutineBank> createState() => _RoutineBankState();
}

class _RoutineBankState extends State<RoutineBank> {
  var _workoutdataProvider;
  var _historydataProvider;
  var _routinetimeProvider;
  var _PopProvider;
  var _userdataProvider;
  var _exercisesdataProvider;

  Widget famous_body() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all( 10),
              child:  Text('유명 운동 Programs', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        Consumer<FamousdataProvider>(
          builder: (builder, provider, child) {
            print(provider.famousdata.famouss);
            return Container(
              height: MediaQuery.of(context).size.width/2 + 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.famousdata.famouss.length,
                itemBuilder: (BuildContext _context, int index) {
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context,
                          Transition(
                              child: ProgramDownload(
                                program: provider.famousdata.famouss[index],
                              ),
                              transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width/2,
                      child: Card(
                        color: Theme.of(context).cardColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child:provider.famousdata.famouss[index].image != ""
                                  ? Image.network(
                                    provider.famousdata.famouss[index].image,
                                    width: MediaQuery.of(context).size.width/2,
                                    height: MediaQuery.of(context).size.width/2,
                                    )
                                  : Container(

                                    width: MediaQuery.of(context).size.width/2,
                                    height: MediaQuery.of(context).size.width/2,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 70,)),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8,0,8,8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(provider.famousdata.famouss[index].routinedata.name,overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width/4 -20,
                                          child: Row(
                                            children: [
                                              Icon(Icons.thumb_up_off_alt_rounded, color: Colors.white,size: 18),

                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width/4 -20,
                                          child: Row(
                                            children: [
                                              Icon(Icons.supervised_user_circle_sharp, color: Colors.white,size: 18),
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
          }
        ),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    _userdataProvider = Provider.of<UserdataProvider>(context, listen: false);
    _workoutdataProvider =
        Provider.of<WorkoutdataProvider>(context, listen: false);
    _exercisesdataProvider =
        Provider.of<ExercisesdataProvider>(context, listen: false);
    return famous_body();
  }
}
