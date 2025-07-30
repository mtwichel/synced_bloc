import 'package:blocsync_server/src/jwt_validator.dart';
import 'package:dart_frog/dart_frog.dart';

typedef UserId = String?;

/// A middleware that validates JWT tokens from the Authorization header.
///
/// Expects tokens in the format: `Authorization: Bearer <token>`
///
/// On successful validation, provides the JWT claims and user ID to the request context.
/// On failure, returns a 401 Unauthorized response.
Middleware jwtMiddleware({JwtValidator? validator}) {
  // Use provided validator or create one from environment
  final jwtValidator = validator ?? JwtValidator.fromEnv();

  return (handler) {
    return (context) async {
      final authHeader = context.request.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return handler(context);
      }

      final token = authHeader.substring('Bearer '.length).trim();

      try {
        final claims = await jwtValidator.verify(token);
        final userId = claims['sub'] as String?;

        // Provide both the full claims and user ID to the context
        final newContext = context
            .provide<Map<String, dynamic>>(() => claims)
            .provide<UserId>(() => userId);

        return handler(newContext);
      } on JwtValidationException catch (_) {
        return handler(context);
      } catch (e) {
        return handler(context);
      }
    };
  };
}

/// Extension to easily access JWT claims from the request context.
extension JwtContext on RequestContext {
  /// Gets the JWT claims from the request context.
  ///
  /// Returns null if no claims are available (e.g., unauthenticated request).
  Map<String, dynamic>? get jwtClaims {
    try {
      return read<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  /// Gets the user ID from the JWT claims.
  ///
  /// Returns null if no user ID is available.
  String? get userId {
    try {
      return read<String?>();
    } catch (_) {
      return null;
    }
  }

  /// Gets a specific claim from the JWT.
  ///
  /// Returns null if the claim doesn't exist or no JWT is present.
  T? getClaim<T>(String claimName) {
    final claims = jwtClaims;
    if (claims == null) return null;
    return claims[claimName] as T?;
  }

  /// Checks if the user has a specific role.
  ///
  /// Looks for roles in the 'role' or 'roles' claim.
  bool hasRole(String role) {
    final claims = jwtClaims;
    if (claims == null) return false;

    // Check single role claim
    final singleRole = claims['role'] as String?;
    if (singleRole == role) return true;

    // Check roles array
    final roles = claims['roles'] as List?;
    return roles?.contains(role) ?? false;
  }

  /// Gets the issuer of the JWT.
  String? get issuer => getClaim<String>('iss');

  /// Gets the audience of the JWT.
  dynamic get audience => getClaim<dynamic>('aud');

  /// Gets the expiration time of the JWT.
  DateTime? get expirationTime {
    final exp = getClaim<int>('exp');
    if (exp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  /// Gets the issued at time of the JWT.
  DateTime? get issuedAt {
    final iat = getClaim<int>('iat');
    if (iat == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(iat * 1000);
  }

  /// Gets the email from the JWT claims.
  String? get email => getClaim<String>('email');

  /// Checks if the email is verified.
  bool get isEmailVerified => getClaim<bool>('email_verified') ?? false;
}
