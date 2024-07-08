import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  FirebaseAnalyticsObserver getAnalyticsObserver() => _observer;

  // 사용자 ID 설정
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // 사용자 속성 설정
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // 커스텀 이벤트 로깅
  static Future<void> logCustomEvent(String eventName,
      [Map<String, Object>? parameters]) async {
    await _analytics.logEvent(name: eventName, parameters: parameters);
  }

  // 예시 이벤트 로깅
  Future<void> logExampleEvent() async {
    await _analytics.logEvent(
      name: 'example_event',
      parameters: <String, Object>{
        'string': 'flutter',
      },
    );
  }
}
