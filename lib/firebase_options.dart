import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-7jSAdIvShZiAydCfC1rlTdbYrbGPmCo',
    appId: '1:310629766313:android:afb9c0160510bd1db9c5b8',
    messagingSenderId: '310629766313',
    projectId: 'thought-app-16cf7',
    storageBucket: 'thought-app-16cf7.firebasestorage.app',
  );

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase options have only been configured for Android. For iOS, please add the GoogleService-Info.plist file.',
        );
    }
  }

  static bool get isConfigured {
    return !currentPlatform.projectId.startsWith('YOUR_') &&
        !currentPlatform.apiKey.startsWith('YOUR_') &&
        !currentPlatform.appId.startsWith('YOUR_');
  }
}
