# Blocsync 🔄

**Sync your Flutter bloc states across devices with minimal setup.**

Blocsync helps you keep your app state consistent across multiple devices by syncing bloc states to the cloud. Just extend `SyncedBloc` instead of `Bloc` and your states will automatically sync in real-time.

## ✨ Features

- **🚀 Simple Setup**: Just extend `SyncedBloc` and add `toJson`/`fromJson` methods
- **🌐 Real-time Sync**: Changes are pushed to other devices immediately
- **📱 Offline Support**: Changes are queued and synced when connection is restored
- **🔐 Privacy Options**: Choose between public (shared) or private (per-user) states
- **🏗️ Flexible Hosting**: Self-host or use our managed service
- **🔑 Multi-Auth Support**: Firebase, Supabase, Auth0, and custom auth providers

## 🚀 Quick Start

### 1. Extend SyncedBloc

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

### 2. Configure Blocsync

```dart
import 'package:blocsync/blocsync.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure local storage
  BlocSyncConfig.storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );

  // Configure remote sync
  BlocSyncConfig.apiClient = ApiClient(
    baseUrl: Uri.parse('https://your-server.com'),
    apiKey: 'your_api_key',
  );

  // Optional: Configure authentication for private blocs
  BlocSyncConfig.authProvider = FirebaseAuthProvider();

  runApp(MyApp());
}
```

### 3. Use Like a Regular Bloc

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: MaterialApp(
        home: Scaffold(
          body: BlocBuilder<CounterBloc, int>(
            builder: (context, state) {
              return Text('Count: $state');
            },
          ),
        ),
      ),
    );
  }
}
```

That's it! Your bloc state will now automatically sync across all devices.

## 🏠 Hosting Options

### Managed Hosting (Recommended)

Use [https://blocsyncer.dev](https://blocsyncer.dev) for hassle-free cloud hosting with:

- Zero server management
- Automatic scaling
- Built-in security
- 99.9% uptime guarantee

### Self-Hosted

Run your own server using the included server package for complete control over your data and infrastructure.

## 🔐 Privacy & Authentication

### Public States (Default)

- Shared across all users
- No authentication required
- Perfect for collaborative features

### Private States

- Isolated per user
- Requires authentication
- Perfect for personal data

```dart
class UserPreferencesBloc extends SyncedBloc<PreferencesEvent, UserPreferences> {
  @override
  bool get isPrivate => true; // Makes it private per user

  // ... rest of bloc implementation
}
```

## 📚 Documentation

For complete documentation, examples, and advanced features, visit:

**[📖 https://blocsync.dev](https://blocsync.dev)**

## 🛠️ Installation

Add blocsync to your `pubspec.yaml`:

```yaml
dependencies:
  blocsync: ^1.0.0
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Ready to sync your bloc states?** [Visit blocsync.dev →](https://blocsync.dev)
