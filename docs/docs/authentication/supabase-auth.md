---
sidebar_position: 3
title: Supabase Provider
---

# Supabase Auth

```dart
import 'package:blocsync/blocsync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonKey: 'your-anon-key',
  );
  
  BlocSyncConfig.authProvider = SupabaseAuthProvider();
  BlocSyncConfig.apiClient = ApiClient(
    baseUrl: Uri.parse('https://your-server.com'),
    apiKey: 'your_api_key',
  );
  
  runApp(MyApp());
}
```