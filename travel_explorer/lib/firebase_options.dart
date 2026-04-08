// Generated Firebase configuration for Travel Explorer
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBEnktj4nVdj0mVhyxShjeMgcQu28fkMmM',
    appId: '1:165717887032:android:4514f2be8fbf34d8617ecd',
    messagingSenderId: '165717887032',
    projectId: 'travel-explorer-58bc1',
    storageBucket: 'travel-explorer-58bc1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEnktj4nVdj0mVhyxShjeMgcQu28fkMmM',
    appId: '1:165717887032:android:4514f2be8fbf34d8617ecd',
    messagingSenderId: '165717887032',
    projectId: 'travel-explorer-58bc1',
    storageBucket: 'travel-explorer-58bc1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBEnktj4nVdj0mVhyxShjeMgcQu28fkMmM',
    appId: '1:165717887032:android:4514f2be8fbf34d8617ecd',
    messagingSenderId: '165717887032',
    projectId: 'travel-explorer-58bc1',
    storageBucket: 'travel-explorer-58bc1.firebasestorage.app',
    iosBundleId: 'com.example.travelExplorer',
  );
}
