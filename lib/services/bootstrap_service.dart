import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

enum BootstrapStatus { ready, needsFirebaseSetup, error }

class BootstrapService {
  Future<BootstrapStatus> initialize() async {
    try {
      debugPrint('Initializing Firebase...');
      if (!DefaultFirebaseOptions.isConfigured) {
        debugPrint('Firebase not configured in firebase_options.dart');
        return BootstrapStatus.needsFirebaseSetup;
      }

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Configure Firestore settings
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );

      // Attempt to sign in
      debugPrint('Attempting anonymous sign-in...');
      if (FirebaseAuth.instance.currentUser == null) {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        debugPrint('Signed in anonymously: ${userCredential.user?.uid}');
      } else {
        debugPrint('User already signed in: ${FirebaseAuth.instance.currentUser?.uid}');
      }

      return BootstrapStatus.ready;
    } catch (e, stack) {
      debugPrint('BOOTSTRAP ERROR: $e');
      debugPrint('STACKTRACE: $stack');
      rethrow; // This will show the error on the SplashScreen
    }
  }
}
