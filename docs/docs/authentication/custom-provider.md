---
sidebar_position: 4
title: Custom Auth Provider
---

# Custom Auth Provider

You can also implement your own authentication:

```dart
class CustomAuthProvider implements AuthProvider {
  @override
  Future<String?> getCurrentUserId() async {
    // Return your user's unique ID
    return await MyAuthService.getCurrentUserId();
  }

  @override
  Future<String?> getAuthToken() async {
    // Return a valid JWT or auth token
    return await MyAuthService.getToken();
  }
}

// Use it
BlocSyncConfig.authProvider = CustomAuthProvider();
```