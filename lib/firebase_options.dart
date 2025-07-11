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
    apiKey: 'AIzaSyCNwqLIbhb1LO8Cz6AKbAo3YgBQyjxJ6hA',
    appId: '1:165426111304:web:3d412140661a3bc9f9097d',
    messagingSenderId: '165426111304',
    projectId: 'e-obraph',
    authDomain: 'e-obraph.firebaseapp.com',
    storageBucket: 'e-obraph.firebasestorage.app',
    measurementId: 'G-J76BC4Q03E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCEx1mM1_JfaT9hiKDmd4Q4tVQNZj3Ntmg',
    appId: '1:165426111304:android:108fd46bcae6c816f9097d',
    messagingSenderId: '165426111304',
    projectId: 'e-obraph',
    storageBucket: 'e-obraph.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrvA1SiXJwhclZgJ4lzTD1BLVh784NjqE',
    appId: '1:165426111304:ios:3fe379fc3f3e116af9097d',
    messagingSenderId: '165426111304',
    projectId: 'e-obraph',
    storageBucket: 'e-obraph.firebasestorage.app',
    iosBundleId: 'com.example.eObraPh',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCrvA1SiXJwhclZgJ4lzTD1BLVh784NjqE',
    appId: '1:165426111304:ios:3fe379fc3f3e116af9097d',
    messagingSenderId: '165426111304',
    projectId: 'e-obraph',
    storageBucket: 'e-obraph.firebasestorage.app',
    iosBundleId: 'com.example.eObraPh',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCNwqLIbhb1LO8Cz6AKbAo3YgBQyjxJ6hA',
    appId: '1:165426111304:web:8bfce4e42a1e4217f9097d',
    messagingSenderId: '165426111304',
    projectId: 'e-obraph',
    authDomain: 'e-obraph.firebaseapp.com',
    storageBucket: 'e-obraph.firebasestorage.app',
    measurementId: 'G-9VR3S3JCFG',
  );
}
