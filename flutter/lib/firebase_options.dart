// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPuwDjs6BY601RZaoV7VE4_w97tm_E1bk',
    appId: '1:508959158364:android:c1c19ff4d1324375e73699',
    messagingSenderId: '508959158364',
    projectId: 'peak-academy-350108',
    storageBucket: 'peak-academy-350108.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9tCtyp99IeJuZwvDvJRW5gzIUZToZ1yw',
    appId: '1:508959158364:ios:7edab3bf37a86483e73699',
    messagingSenderId: '508959158364',
    projectId: 'peak-academy-350108',
    storageBucket: 'peak-academy-350108.appspot.com',
    androidClientId: '508959158364-1sh9bb60117hjt3qm32rlnkkp1958g0d.apps.googleusercontent.com',
    iosClientId: '508959158364-a98jdhmhtp38qqvvisf20hn773cr9gsd.apps.googleusercontent.com',
    iosBundleId: 'com.tklck.sdbTrainer',
  );

}