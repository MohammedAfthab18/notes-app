import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'Firebase is configured for Android only in this workspace.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRUg_pN4U3kRhQfgHpE4AVLe2aBdFviDY',
    appId: '1:743947953582:android:10861881856aff86d8143f',
    messagingSenderId: '743947953582',
    projectId: 'noteshub-140e4',
    storageBucket: 'noteshub-140e4.firebasestorage.app',
  );
}
