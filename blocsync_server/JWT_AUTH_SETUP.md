# JWT Authentication Setup for BlocSync Server

This guide explains how to configure the BlocSync server to work with JWT tokens from multiple authentication providers (Firebase Auth, Supabase Auth, Auth0, etc.).

## Overview

The JWT authentication system supports:
- **HS256** (HMAC-SHA256) for symmetric key signatures
- **RS256** and **ES256** for asymmetric signatures
- **Automatic JWKS fetching** from standard endpoints for asymmetric algorithms
- **Multiple authentication providers** with minimal configuration
- **Environment-based configuration** for security
- **Comprehensive token validation** including expiration, audience, and issuer checks

## Environment Variables

Configure the following environment variables:

```bash
# Required: Comma-separated list of trusted issuer URLs
JWT_ALLOWED_ISSUERS=https://securetoken.google.com/your-firebase-project,https://yourproject.supabase.co/auth/v1

# Required: Expected audience claim (usually your API/service identifier)
JWT_AUDIENCE=your-api-service

# Optional: Symmetric secret for HS256 tokens (legacy/custom providers)
JWT_SECRET=your-hmac-secret-key

# Optional: JWKS cache TTL in minutes (default: 60)
JWKS_CACHE_TTL_MINUTES=60

# Your existing API key for server endpoints
API_KEY=your-secret-api-key
```

## Supported Providers

### Custom/Legacy HS256 Tokens

For custom authentication systems or legacy applications using HMAC-SHA256:

```bash
JWT_ALLOWED_ISSUERS=https://your-custom-auth-server.com
JWT_AUDIENCE=your-api-service
JWT_SECRET=your-256-bit-secret-key
```

**Important**: HS256 tokens don't require a `kid` (key ID) in the header since they use a shared secret.

### Firebase Auth

```bash
JWT_ALLOWED_ISSUERS=https://securetoken.google.com/your-firebase-project-id
JWT_AUDIENCE=your-firebase-project-id
```

The system automatically uses Firebase's JWKS endpoint:
`https://www.googleapis.com/service_accounts/v1/metadata/x509/securetoken@system.gserviceaccount.com`

### Supabase Auth

```bash
JWT_ALLOWED_ISSUERS=https://yourproject.supabase.co/auth/v1
JWT_AUDIENCE=authenticated
```

Uses Supabase's standard JWKS endpoint:
`https://yourproject.supabase.co/auth/v1/.well-known/jwks.json`

### Auth0

```bash
JWT_ALLOWED_ISSUERS=https://your-tenant.auth0.com/
JWT_AUDIENCE=your-api-identifier
```

Uses Auth0's standard OIDC discovery endpoint:
`https://your-tenant.auth0.com/.well-known/jwks.json`

### Multiple Providers

You can support multiple providers simultaneously, including mixing symmetric and asymmetric algorithms:

```bash
# Support Firebase (RS256), Supabase (RS256), and custom HS256 tokens
JWT_ALLOWED_ISSUERS=https://securetoken.google.com/firebase-project,https://yourproject.supabase.co/auth/v1,https://your-custom-auth.com
JWT_AUDIENCE=your-unified-api-identifier
JWT_SECRET=your-hmac-secret-for-custom-tokens
```

**Note**: When `JWT_SECRET` is provided, HS256 tokens from any allowed issuer will be validated using the symmetric secret, while RS256/ES256 tokens will use JWKS as usual.

## Usage in Routes

### Basic Usage

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:blocsync_server/blocsync_server.dart';

Future<Response> onRequest(RequestContext context) async {
  // The JWT middleware automatically validates tokens and provides user info
  final userId = context.userId;
  final claims = context.jwtClaims;
  
  if (userId == null) {
    return Response(statusCode: 401, body: 'Authentication required');
  }
  
  // Use the authenticated user ID
  return Response.json({'message': 'Hello $userId'});
}
```

### Advanced Claims Access

```dart
Future<Response> onRequest(RequestContext context) async {
  final userId = context.userId;
  final email = context.email;
  final isEmailVerified = context.isEmailVerified;
  final issuer = context.issuer;
  
  // Check for specific roles
  if (!context.hasRole('admin')) {
    return Response(statusCode: 403, body: 'Admin access required');
  }
  
  // Get custom claims
  final customClaim = context.getClaim<String>('custom_field');
  
  return Response.json({
    'userId': userId,
    'email': email,
    'emailVerified': isEmailVerified,
    'issuer': issuer,
    'customClaim': customClaim,
  });
}
```

## Client-Side Integration

### JavaScript/TypeScript (Firebase)

```typescript
import { getAuth, getIdToken } from 'firebase/auth';

const auth = getAuth();
const user = auth.currentUser;

if (user) {
  const token = await getIdToken(user);
  
  const response = await fetch('http://localhost:8080/api/protected', {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  });
}
```

### JavaScript/TypeScript (Supabase)

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const { data: { session } } = await supabase.auth.getSession();

if (session) {
  const response = await fetch('http://localhost:8080/api/protected', {
    headers: {
      'Authorization': `Bearer ${session.access_token}`,
      'Content-Type': 'application/json',
    },
  });
}
```

### Flutter/Dart

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final token = await user.getIdToken();
  
  final response = await http.get(
    Uri.parse('http://localhost:8080/api/protected'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
}
```

## Testing

### Manual Testing with cURL

```bash
# Replace YOUR_JWT_TOKEN with an actual token from your auth provider
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -H "x-api-key: your-secret-api-key" \
     http://localhost:8080/api/protected
```

### Unit Testing

```dart
import 'package:test/test.dart';
import 'package:blocsync_server/blocsync_server.dart';

void main() {
  group('JWT Validation', () {
    test('validates Firebase JWT', () async {
      final validator = JwtValidator(
        allowedIssuers: {'https://securetoken.google.com/test-project'},
        expectedAudience: 'test-project',
      );
      
      // Test with a valid Firebase JWT
      final claims = await validator.verify(validFirebaseJWT);
      expect(claims['sub'], isNotNull);
      expect(claims['iss'], equals('https://securetoken.google.com/test-project'));
    });

    test('validates HS256 JWT', () async {
      final validator = JwtValidator(
        allowedIssuers: {'https://your-custom-auth.com'},
        expectedAudience: 'test-api',
        symmetricSecret: 'test-secret-key',
      );
      
      // Test with a valid HS256 JWT
      final claims = await validator.verify(validHS256JWT);
      expect(claims['sub'], isNotNull);
      expect(claims['iss'], equals('https://your-custom-auth.com'));
    });
  });
}
```

### Creating HS256 Tokens for Testing

You can use online tools like [jwt.io](https://jwt.io) or create tokens programmatically:

```dart
// Example using dart_jsonwebtoken package
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

void createTestToken() {
  final jwt = JWT({
    'sub': 'user123',
    'iss': 'https://your-custom-auth.com',
    'aud': 'your-api-service',
    'exp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
  });

  final token = jwt.sign(SecretKey('your-hmac-secret-key'));
  print('HS256 Token: $token');
}
```

## Security Considerations

1. **Environment Variables**: Never commit JWT secrets or API keys to version control
2. **HTTPS Only**: Always use HTTPS in production
3. **Token Expiration**: Tokens are automatically validated for expiration
4. **Issuer Validation**: Only tokens from trusted issuers are accepted
5. **Audience Validation**: Tokens must be intended for your service
6. **JWKS Caching**: Public keys are cached securely with automatic rotation support

## Troubleshooting

### Common Issues

1. **"Issuer not allowed"**: Check that your `JWT_ALLOWED_ISSUERS` includes the correct issuer URL
2. **"Audience mismatch"**: Verify that `JWT_AUDIENCE` matches what your auth provider sends
3. **"Unknown key ID"**: The JWKS endpoint might be unreachable or the key has rotated
4. **"Signature verification failed"**: Token might be corrupted or from an untrusted source

### Debug Mode

Enable detailed logging by setting:

```bash
DEBUG=true
```

This will log JWT validation steps for troubleshooting.

## Performance

- **JWKS Caching**: Public keys are cached for 60 minutes by default
- **No Database Calls**: Token validation is performed entirely in-memory
- **Minimal Network Requests**: JWKS are fetched only when cache expires
- **Fast Verification**: Uses PointyCastle for efficient cryptographic operations

## Migration from Symmetric Keys

If you're migrating from HMAC-based JWT validation:

1. Update your auth provider to use asymmetric keys (RS256/ES256)
2. Set the new environment variables
3. Remove any `JWT_SIGNING_SECRET` environment variables
4. Update your client applications to use the new token format
5. Test thoroughly before deploying to production