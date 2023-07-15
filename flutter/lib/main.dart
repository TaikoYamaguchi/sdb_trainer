import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdb_trainer/pages/app.dart';
import 'package:sdb_trainer/providers/bodystate.dart';
import 'package:sdb_trainer/providers/exercisesdata.dart';
import 'package:sdb_trainer/providers/famous.dart';
import 'package:sdb_trainer/providers/interviewdata.dart';
import 'package:sdb_trainer/providers/notification.dart';
import 'package:sdb_trainer/providers/popmanage.dart';
import 'package:sdb_trainer/providers/routinemenu.dart';
import 'package:sdb_trainer/providers/routinetime.dart';
import 'package:sdb_trainer/providers/tempimagestorage.dart';
import 'package:sdb_trainer/providers/userdata.dart';
import 'package:sdb_trainer/providers/staticPageState.dart';
import 'package:sdb_trainer/providers/chartIndexState.dart';
import 'package:sdb_trainer/providers/userpreference.dart';
import 'package:sdb_trainer/providers/workoutdata.dart';
import 'package:sdb_trainer/providers/historydata.dart';
import 'package:sdb_trainer/providers/themeMode.dart';
import 'package:sdb_trainer/providers/loginState.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sdb_trainer/src/utils/notification.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

Future<void> _firebaseMessagingBackgroundNullHandler(
    RemoteMessage message) async {
  return null;
}

var historyDataProvider;
var bodyStateProvider;
void main() async {
  KakaoSdk.init(nativeAppKey: "54b807de5757a704a372c2d0539a67da");
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final isNotificationEnabled = await prefs.getBool('commentNotification');
  if (isNotificationEnabled != false) {
    print("background message enable");
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  initLocalNotificationPlugin();
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      historyDataProvider.getHistorydataAll();
      historyDataProvider.getCommentAll();
      historyDataProvider.getFriendsHistorydata();
      bodyStateProvider.change(2);
    }

    print(message);
    print("완전 종료");
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    // 특정 페이지로 가고 싶게한다면 추가 설정이 필요하다
    historyDataProvider.getHistorydataAll();
    historyDataProvider.getCommentAll();
    historyDataProvider.getFriendsHistorydata();
    bodyStateProvider.change(2);
    print(message);
    print("백그라운드");
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // 앱이 실행 중일 때 알림을 수신한 경우 처리
    historyDataProvider.getHistorydataAll();
    historyDataProvider.getCommentAll();
    historyDataProvider.getFriendsHistorydata();
    bodyStateProvider.change(2);
  });
  //MobileAds.instance.initialize();

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
    ChangeNotifierProvider(
        create: (BuildContext context) => NotificationdataProvider()),
    ChangeNotifierProvider(create: (BuildContext context) => ThemeProvider()),
    ChangeNotifierProvider(create: (BuildContext context) => TempImgStorage()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    historyDataProvider =
        Provider.of<HistorydataProvider>(context, listen: false);
    bodyStateProvider = Provider.of<BodyStater>(context, listen: false);
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
              shadowColor: Colors.black,
              brightness: Brightness.light,
              primaryColorLight: Colors.black, //fontcolor
              primaryColorDark: const Color(0xFFB5B9C2), // grey color
              indicatorColor: const Color(0xfff2f3f5), // navigation color
              highlightColor: Colors.white, // in primary color text white
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Color(0xff7a28cb),
                selectionColor: Color(0xff7a28cb),
                selectionHandleColor: Color(0xff7a28cb),
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
              shadowColor: Colors.black,
              primaryColorLight: Colors.white,
              primaryColorDark: const Color(0xFF717171),
              indicatorColor: const Color(0xFF212121),
              highlightColor: Colors.white,
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Color(0xff7a28cb),
                selectionColor: Color(0xff7a28cb),
                selectionHandleColor: Color(0xff7a28cb),
              ),
              colorScheme: ThemeData().colorScheme.copyWith(
                    primary: const Color(0xff7a28cb),
                  ),
              fontFamily: 'Noto_Sans_KR'),
          title: 'Flutter Demo',
          home: const App(),
        );
      }),
    );
  }
}
