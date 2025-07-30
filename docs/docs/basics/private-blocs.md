---
sidebar_position: 3
title: 🤫 Private Blocs
---

# 🤫 Private Blocs

Private states ensure that each user has their own isolated data that only they can access. This is essential for personal data like user preferences, private notes, or any sensitive information.

:::warning Authentication Required
Private blocs will not sync until the user is authenticated. Make sure your authentication flow is complete using creating private blocs. For information on setting up authentication, see [Firebase Auth](/docs/authentication/firebase-auth) or [Supabase Auth](/docs/authentication/supabase-auth)
:::

## Public vs Private States

**Public States** (default):

- Shared across all users of your app
- No authentication required
- Perfect for collaborative features, shared counters, or global app state
- Anyone can read and modify the state

**Private States**:

- Each user has their own isolated "bucket" of data
- Requires user authentication
- Perfect for personal data, user preferences, private content
- Only the authenticated user can access their own state

## Making a Bloc Private

Simply override the `isPrivate` getter in your bloc:

```dart
import 'package:blocsync/blocsync.dart';

class UserPreferencesBloc extends SyncedBloc<PreferencesEvent, UserPreferences> {
  UserPreferencesBloc() : super(UserPreferences.initial()) {
    on<UpdateTheme>((event, emit) => emit(state.copyWith(theme: event.theme)));
    on<UpdateLanguage>((event, emit) => emit(state.copyWith(language: event.language)));
  }

  @override
  bool get isPrivate => true; // This makes the bloc private!

  @override
  UserPreferences fromJson(Map<String, dynamic> json) => UserPreferences.fromJson(json);

  @override
  Map<String, dynamic>? toJson(UserPreferences state) => state.toJson();
}
```

## Mixed Approach

You can use both public and private blocs in the same app:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Public bloc - shared across all users
        BlocProvider(create: (_) => GlobalAnnouncementBloc()),

        // Private bloc - isolated per user
        BlocProvider(create: (_) => UserPreferencesBloc()),

        // Another private bloc
        BlocProvider(create: (_) => UserNotesBloc()),
      ],
      child: MaterialApp(/* ... */),
    );
  }
}
```

This gives you the flexibility to sync some data globally while keeping sensitive user data private and secure.

:::note
Blocs can be private **and** partitioned. For more information on partitioned blocs, see [Partitioned Blocs](/docs/basics/partitioned-blocs)
:::
