import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/app.dart';
import 'package:sdb_trainer/pages/login.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'package:sdb_trainer/src/utils/firebase_fcm.dart';

void main() {
  KakaoSdk.init(nativeAppKey: "54b807de5757a704a372c2d0539a67da");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (BuildContext context) => BodyStater()),
    ChangeNotifierProvider(
        create: (BuildContext context) => ChartIndexProvider()),
    ChangeNotifierProvider(
        create: (BuildContext context) => StaticPageProvider()),
    ChangeNotifierProvider(
        create: (BuildContext context) => LoginPageProvider()),
    ChangeNotifierProvider(
        create: (BuildContext context) => ExercisesdataProvider()),
    ChangeNotifierProvider(
        create: (BuildContext context) => UserdataProvider()),
    ChangeNotifierProvider(
        create: (BuildContext context) => WorkoutdataProvider()),
    ChangeNotifierProvider(
        create: (BuildContext context) => HistorydataProvider()),
    ChangeNotifierProvider(
        create: (BuildContext context) => RoutineTimeProvider()),
    ChangeNotifierProvider(create: (BuildContext context) => PopProvider()),
    ChangeNotifierProvider(create: (BuildContext context) => PrefsProvider()),
    ChangeNotifierProvider(
        create: (BuildContext context) => RoutineMenuStater()),
    ChangeNotifierProvider(
        create: (BuildContext context) => FamousdataProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: const Color(0xff7a28cb),
          cardColor: const Color(0xff25272c),
          canvasColor: Colors.transparent,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: const Color(0xff7a28cb),
            selectionColor: const Color(0xff7a28cb),
            selectionHandleColor: const Color(0xff7a28cb),
          ),
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: const Color(0xff7a28cb),
              ),
          fontFamily: 'Noto_Sans_KR'),
      title: 'Flutter Demo',
      home: App(),
    );
  }
}
