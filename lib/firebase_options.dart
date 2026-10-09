import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBImM9LwYRL3QUhd_6Y1uUyRLxHIIgzlEo',
    appId: '1:1089298239075:web:dfa8d2f66f1bee71ef7256',
    messagingSenderId: '1089298239075',
    projectId: 'we-smartclass',
    authDomain: 'we-smartclass.firebaseapp.com',
    storageBucket: 'we-smartclass.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBImM9LwYRL3QUhd_6Y1uUyRLxHIIgzlEo',
    appId: '1:1089298239075:android:dfa8d2f66f1bee71ef7256',
    messagingSenderId: '1089298239075',
    projectId: 'we-smartclass',
    storageBucket: 'we-smartclass.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBImM9LwYRL3QUhd_6Y1uUyRLxHIIgzlEo',
    appId: '1:1089298239075:ios:dfa8d2f66f1bee71ef7256',
    messagingSenderId: '1089298239075',
    projectId: 'we-smartclass',
    storageBucket: 'we-smartclass.firebasestorage.app',
    iosBundleId: 'com.weapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBImM9LwYRL3QUhd_6Y1uUyRLxHIIgzlEo',
    appId: '1:1089298239075:web:dfa8d2f66f1bee71ef7256',
    messagingSenderId: '1089298239075',
    projectId: 'we-smartclass',
    authDomain: 'we-smartclass.firebaseapp.com',
    storageBucket: 'we-smartclass.firebasestorage.app',
  );
}
