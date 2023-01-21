import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/app.dart';
import 'package:sdb_trainer/pages/login.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/interviewdata.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sdb_trainer/src/utils/firebase_fcm.dart';
import 'package:sdb_trainer/src/utils/notification.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() {
  KakaoSdk.init(nativeAppKey: "54b807de5757a704a372c2d0539a67da");
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  initLocalNotificationPlugin();
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
    ChangeNotifierProvider(
        create: (BuildContext context) => InterviewdataProvider()),
    ChangeNotifierProvider(create: (BuildContext context) => ThemeProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _themeProvider.getUserFontsize();
    _themeProvider.getUserTheme();
    return Center(
      child: Consumer<ThemeProvider>(builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          themeMode: _themeProvider.userThemeDark == "dark"
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
              textTheme: Theme.of(context).textTheme.apply(
                    fontSizeFactor: _themeProvider.userFontSize,
                  ),
              primaryColor: const Color(0xff7a28cb), //main color
              primaryColorBrightness: Brightness.light,
              cardColor: const Color(0xfff2f3f5), //cardcolor
              canvasColor: Colors.white, //backgroundcolor
              brightness: Brightness.light,
              primaryColorLight: Colors.black, //fontcolor
              primaryColorDark: Color(0xFFB5B9C2), // grey color
              indicatorColor: const Color(0xfff2f3f5), // navigation color
              buttonColor: Colors.white, // in primary color text white
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: const Color(0xff7a28cb),
                selectionColor: const Color(0xff7a28cb),
                selectionHandleColor: const Color(0xff7a28cb),
              ),
              colorScheme: ThemeData().colorScheme.copyWith(
                    primary: const Color(0xff7a28cb),
                  ),
              fontFamily: 'Noto_Sans_KR'),
          darkTheme: ThemeData(
              textTheme: Theme.of(context).textTheme.apply(
                    fontSizeFactor: _themeProvider.userFontSize,
                  ),
              primaryColor: const Color(0xff7a28cb),
              cardColor: const Color(0xff25272c),
              canvasColor: const Color(0xFF101012),
              primaryColorLight: Colors.white,
              primaryColorDark: Color(0xFF717171),
              indicatorColor: const Color(0xFF212121),
              buttonColor: Colors.white,
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
      }),
    );
  }
}
