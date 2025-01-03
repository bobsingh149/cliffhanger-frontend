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
    apiKey: 'AIzaSyDmTprTUQ4Vc9jKsW_aolgrwrzRi1mv6rI',
    appId: '1:450436408734:web:1f70ea6918539a67b7628f',
    messagingSenderId: '450436408734',
    projectId: 'novelnest-827a6',
    authDomain: 'novelnest-827a6.firebaseapp.com',
    storageBucket: 'novelnest-827a6.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6bZN8lbHaS41jpCs8IVLbVymgq6-UbTA',
    appId: '1:450436408734:android:c93b8bcac9a4bc1bb7628f',
    messagingSenderId: '450436408734',
    projectId: 'novelnest-827a6',
    storageBucket: 'novelnest-827a6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBiwhE0l5gQRoYlfkD3pEluOFpmKBH4uL8',
    appId: '1:450436408734:ios:c52cde9188f217dab7628f',
    messagingSenderId: '450436408734',
    projectId: 'novelnest-827a6',
    storageBucket: 'novelnest-827a6.appspot.com',
    iosBundleId: 'com.example.barterFrontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBiwhE0l5gQRoYlfkD3pEluOFpmKBH4uL8',
    appId: '1:450436408734:ios:c52cde9188f217dab7628f',
    messagingSenderId: '450436408734',
    projectId: 'novelnest-827a6',
    storageBucket: 'novelnest-827a6.appspot.com',
    iosBundleId: 'com.example.barterFrontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDmTprTUQ4Vc9jKsW_aolgrwrzRi1mv6rI',
    appId: '1:450436408734:web:0bdf91904c9ec007b7628f',
    messagingSenderId: '450436408734',
    projectId: 'novelnest-827a6',
    authDomain: 'novelnest-827a6.firebaseapp.com',
    storageBucket: 'novelnest-827a6.appspot.com',
  );
}
