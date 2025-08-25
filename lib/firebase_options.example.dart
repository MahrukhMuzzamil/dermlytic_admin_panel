// Example Firebase options - DO NOT use in production. Copy to lib/firebase_options.dart and
// fill with your real values locally, but do not commit that file.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'SENDER_ID',
    projectId: 'PROJECT_ID',
    authDomain: 'PROJECT_ID.firebaseapp.com',
    storageBucket: 'PROJECT_ID.firebasestorage.app',
    measurementId: 'G-XXXXXXX',
  );
}


