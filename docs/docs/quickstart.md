---
sidebar_position: 1
title: 🚀 Quick Start
---

# 🚀 Quick Start

Blocsync helps you sync bloc states across devices by syncing them to the cloud. Keep your app state consistent across multiple devices with minimal setup.

## Basic Usage

All you need to do is extend `SyncedBloc` instead of `Bloc` and implement `toJson` and `fromJson` methods for your state. It's similar to hydrated_bloc in that way.

```dart
import 'package:blocsync/blocsync.dart';

class CounterBloc extends SyncedBloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}
```

## Setup
To setup blocsync, start by configuring
1. Local caching
2. Remote caching
3. Authentication (optional)

```dart
import 'package:blocsync/blocsync.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  BlocSyncConfig.localStorage = LocalStorage
  BlocSyncConfig.apiClient = ApiClient(
    apiKey: 'your_api_key',
  );
  BlocSyncConfig.authProvider = FirebaseAuthProvider();
  
  runApp(MyApp());
}
```

## Hosting Options 🏠

You have two options for running the sync server:

- **Managed hosting**: Use [https://blocsyncer.dev](https://blocsyncer.dev) for hassle-free cloud hosting
- **Self-hosted**: Run your own server using the included server package

## Authentication & Privacy 🔐

Blocs can be configured as either **private** (per user) or **public**:

- **Public blocs**: No authentication required, state is shared across all users
- **Private blocs**: Require user authentication to ensure each user's state stays private

For private blocs, we support multiple authentication providers:
- Firebase Auth
- Supabase
- Auth0  
- Custom authentication solutions
