---
sidebar_position: 2
title: Firebase Auth
---

# Firebase Auth


```dart
import 'package:blocsync/blocsync.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure Blocsync with Firebase Auth
  BlocSyncConfig.authProvider = FirebaseAuthProvider();
  BlocSyncConfig.apiClient = ApiClient(
    baseUrl: Uri.parse('https://your-server.com'),
    apiKey: 'your_api_key',
  );
  
  runApp(MyApp());
}
```
