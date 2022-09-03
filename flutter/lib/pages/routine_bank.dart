import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
              padding: EdgeInsets.only(left: 20),
              child:  Text('유명 운동 Programs', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        Consumer<FamousdataProvider>(
          builder: (builder, provider, child) {
            print(provider.famousdata.famouss);
            return Container(
              height: MediaQuery.of(context).size.height/4,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.famousdata.famouss.length,
                itemBuilder: (BuildContext _context, int index) {
                  return Container(
                    width: MediaQuery.of(context).size.width/2,
                    child: Card(
                      color: Colors.grey,
                      child: Center(
                        child: Text(provider.famousdata.famouss[index].routinedata.name, style: TextStyle(color: Colors.white),),
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
