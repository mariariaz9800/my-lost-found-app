// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyBIUvI6cEL308-j_Wtz9VTgbo0nNcHFhrM',
    appId: '1:131593254862:web:e5b9d854cb63fd46711d9f',
    messagingSenderId: '131593254862',
    projectId: 'item-d0387',
    authDomain: 'item-d0387.firebaseapp.com',
    storageBucket: 'item-d0387.appspot.com', // ✅ fixed
    measurementId: 'G-VJD6KPJP5Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0wIJV5kbxsKm8DpV9KBRarDkbBiL2y1Q',
    appId: '1:131593254862:android:69c00ff2387775f8711d9f',
    messagingSenderId: '131593254862',
    projectId: 'item-d0387',
    storageBucket: 'item-d0387.appspot.com', // ✅ fixed
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUDvMSangK2COeWZ3PJoaTAoUTmJg7fkQ',
    appId: '1:131593254862:ios:ccd46e1ab0022b35711d9f',
    messagingSenderId: '131593254862',
    projectId: 'item-d0387',
    storageBucket: 'item-d0387.appspot.com', // ✅ fixed
    iosBundleId: 'com.example.itemRadar',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCUDvMSangK2COeWZ3PJoaTAoUTmJg7fkQ',
    appId: '1:131593254862:ios:ccd46e1ab0022b35711d9f',
    messagingSenderId: '131593254862',
    projectId: 'item-d0387',
    storageBucket: 'item-d0387.appspot.com', // ✅ fixed
    iosBundleId: 'com.example.itemRadar',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBIUvI6cEL308-j_Wtz9VTgbo0nNcHFhrM',
    appId: '1:131593254862:web:24d4c11c94c7d8ac711d9f',
    messagingSenderId: '131593254862',
    projectId: 'item-d0387',
    authDomain: 'item-d0387.firebaseapp.com',
    storageBucket: 'item-d0387.appspot.com', // ✅ fixed
    measurementId: 'G-CMJ71M9B2Q',
  );
}
