import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/app.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/userdata.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (BuildContext context) => BodyStater()),
            ChangeNotifierProvider(
                create: (BuildContext context) => ExercisesdataProvider()),
            ChangeNotifierProvider(
                create: (BuildContext context) => UserdataProvider())
          ],
          child: App()),
    );
  }
}
