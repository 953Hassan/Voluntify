// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBof-IrVI-UMm8PyM1IKzNSn2kHlkeYdqU',
    appId: '1:563795124512:web:cbe93393c0763dc150f745',
    messagingSenderId: '563795124512',
    projectId: 'voluntify-1d90d',
    authDomain: 'voluntify-1d90d.firebaseapp.com',
    storageBucket: 'voluntify-1d90d.appspot.com',
    measurementId: 'G-0ZR8V3JWF4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAC4T-TXExLsbE2Y9ZUcwsYfjT0IwtjwEo',
    appId: '1:563795124512:android:678baa0d8b62fdc150f745',
    messagingSenderId: '563795124512',
    projectId: 'voluntify-1d90d',
    storageBucket: 'voluntify-1d90d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDYalvPFndOq-J5qznAyQA6V9S_UeGpaGA',
    appId: '1:563795124512:ios:ac92866bcca806b550f745',
    messagingSenderId: '563795124512',
    projectId: 'voluntify-1d90d',
    storageBucket: 'voluntify-1d90d.appspot.com',
    iosClientId: '563795124512-0m9bi41luf8n84dquga19rrutd52cdr5.apps.googleusercontent.com',
    iosBundleId: 'com.example.voluntifyBeta',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDYalvPFndOq-J5qznAyQA6V9S_UeGpaGA',
    appId: '1:563795124512:ios:ac92866bcca806b550f745',
    messagingSenderId: '563795124512',
    projectId: 'voluntify-1d90d',
    storageBucket: 'voluntify-1d90d.appspot.com',
    iosClientId: '563795124512-0m9bi41luf8n84dquga19rrutd52cdr5.apps.googleusercontent.com',
    iosBundleId: 'com.example.voluntifyBeta',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBof-IrVI-UMm8PyM1IKzNSn2kHlkeYdqU',
    appId: '1:563795124512:web:64c108b38b7a213350f745',
    messagingSenderId: '563795124512',
    projectId: 'voluntify-1d90d',
    authDomain: 'voluntify-1d90d.firebaseapp.com',
    storageBucket: 'voluntify-1d90d.appspot.com',
    measurementId: 'G-LEKFZDB2W6',
  );
}