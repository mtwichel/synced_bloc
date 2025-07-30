import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';

/// Exception thrown when JWT validation fails.
class JwtValidationException implements Exception {
  /// Creates a JWT validation exception with the given message.
  const JwtValidationException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'JwtValidationException: $message';
}

/// A comprehensive JWT validator that supports multiple authentication
/// providers.
///
/// Supports HS256 (HMAC), RS256 and ES256 algorithms with automatic
/// JWKS (JSON Web Key Set)
/// fetching from standard endpoints for asymmetric algorithms.
///
/// Configuration via environment variables:
/// - `JWT_ALLOWED_ISSUERS`: Comma-separated list of trusted issuer URLs
/// - `JWT_AUDIENCE`: Expected audience claim value
/// - `JWT_SECRET`: Optional symmetric secret for HS256 tokens
/// - `JWKS_CACHE_TTL_MINUTES`: Cache TTL in minutes (default: 60)
class JwtValidator {
  /// Creates a JWT validator with the specified configuration.
  JwtValidator({
    required Set<String> allowedIssuers,
    required String expectedAudience,
    String? symmetricSecret,
    Duration cacheTtl = const Duration(hours: 1),
  })  : _allowedIssuers = allowedIssuers,
        _symmetricSecret = symmetricSecret,
        _expectedAudience = expectedAudience,
        _cacheTtl = cacheTtl;

  /// Creates a JWT validator from environment variables.
  factory JwtValidator.fromEnv() {
    final allowedEnv = Platform.environment['JWT_ALLOWED_ISSUERS'] ?? '';
    final allowed = allowedEnv
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    if (allowed.isEmpty) {
      throw StateError('JWT_ALLOWED_ISSUERS env var must be set');
    }

    final aud = Platform.environment['JWT_AUDIENCE'];
    if (aud == null || aud.isEmpty) {
      throw StateError('JWT_AUDIENCE env var must be set');
    }

    final ttl = int.tryParse(
          Platform.environment['JWKS_CACHE_TTL_MINUTES'] ?? '',
        ) ??
        60;

    final secret = Platform.environment['JWT_SECRET'];

    return JwtValidator(
      allowedIssuers: allowed,
      expectedAudience: aud,
      symmetricSecret: secret,
      cacheTtl: Duration(minutes: ttl),
    );
  }

  final Set<String> _allowedIssuers;
  final String _expectedAudience;
  final String? _symmetricSecret;
  final Duration _cacheTtl;

  // Cache for JWKS by issuer
  final _cache = <String, _CachedKeys>{};

  /// Verifies a JWT token and returns its claims.
  ///
  /// Throws [JwtValidationException] if the token is invalid.
  Future<Map<String, dynamic>> verify(String token) async {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const JwtValidationException('Malformed JWT');
    }

    final header = _decodeJson(parts[0]);
    final claims = _decodeJson(parts[1]);

    // Validate basic claims
    final alg = header['alg'] as String?;
    final kid = header['kid'] as String?;
    final iss = claims['iss'] as String?;
    final aud = claims['aud'];
    final exp = claims['exp'] as int?;

    if (alg == null || !['HS256', 'RS256', 'ES256'].contains(alg)) {
      throw JwtValidationException('Unsupported algorithm: $alg');
    }
    if (iss == null || !_allowedIssuers.contains(iss)) {
      throw JwtValidationException('Issuer not allowed: $iss');
    }
    if (!_audMatches(aud)) {
      throw JwtValidationException('Audience mismatch: $aud');
    }
    if (exp != null && _isExpired(exp)) {
      throw const JwtValidationException('Token expired');
    }

    final data = utf8.encode('${parts[0]}.${parts[1]}');
    final signature = _decodeBase64Url(parts[2]);

    // Handle different signature algorithms
    if (alg == 'HS256') {
      if (_symmetricSecret == null) {
        throw const JwtValidationException(
          'JWT_SECRET required for HS256 tokens',
        );
      }
      if (!_verifyHmacSignature(data, signature, _symmetricSecret!)) {
        throw const JwtValidationException(
          'HMAC signature verification failed',
        );
      }
    } else {
      // RS256 or ES256 - requires kid and JWKS
      if (kid == null) {
        throw const JwtValidationException(
          'Missing kid in header for asymmetric algorithm',
        );
      }

      final keyStore = await _keyStoreFor(iss);
      final publicKey = keyStore[kid];
      if (publicKey == null) {
        throw JwtValidationException('Unknown key ID: $kid');
      }

      if (!_verifyAsymmetricSignature(data, signature, publicKey, alg)) {
        throw const JwtValidationException(
          'Asymmetric signature verification failed',
        );
      }
    }

    return claims;
  }

  bool _audMatches(dynamic aud) {
    if (aud == null) return false;
    if (aud is String) return aud == _expectedAudience;
    if (aud is List) return aud.contains(_expectedAudience);
    return false;
  }

  bool _isExpired(int exp) {
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiry);
  }

  Map<String, dynamic> _decodeJson(String part) {
    final decoded = utf8.decode(_decodeBase64Url(part));
    return json.decode(decoded) as Map<String, dynamic>;
  }

  Future<Map<String, AsymmetricKey>> _keyStoreFor(String iss) async {
    final cached = _cache[iss];
    if (cached != null && cached.expires.isAfter(DateTime.now())) {
      return cached.keys;
    }

    final uri = _jwksUriFor(iss);
    final response = await http.get(Uri.parse(uri));
    if (response.statusCode != 200) {
      throw JwtValidationException(
        'Failed to fetch JWKS: ${response.statusCode}',
      );
    }

    final jwks = json.decode(response.body) as Map<String, dynamic>;
    final keys = <String, AsymmetricKey>{};

    for (final keyData in (jwks['keys'] as List)) {
      final keyMap = keyData as Map<String, dynamic>;
      final kid = keyMap['kid'] as String;
      final kty = keyMap['kty'] as String;

      AsymmetricKey? publicKey;
      if (kty == 'RSA') {
        publicKey = _parseRSAKey(keyMap);
      } else if (kty == 'EC') {
        publicKey = _parseECKey(keyMap);
      }

      if (publicKey != null) {
        keys[kid] = publicKey;
      }
    }

    _cache[iss] = _CachedKeys(keys, DateTime.now().add(_cacheTtl));
    return keys;
  }

  String _jwksUriFor(String iss) {
    // Firebase Auth
    if (iss.startsWith('https://securetoken.google.com/')) {
      return 'https://www.googleapis.com/service_accounts/v1/metadata/x509/securetoken@system.gserviceaccount.com';
    }

    // Standard OIDC discovery
    return '$iss/.well-known/jwks.json';
  }

  RSAPublicKey? _parseRSAKey(Map<String, dynamic> keyData) {
    try {
      final n = keyData['n'] as String;
      final e = keyData['e'] as String;

      final modulus = _bigIntFromBase64Url(n);
      final exponent = _bigIntFromBase64Url(e);

      return RSAPublicKey(modulus, exponent);
    } catch (e) {
      return null;
    }
  }

  ECPublicKey? _parseECKey(Map<String, dynamic> keyData) {
    try {
      final crv = keyData['crv'] as String;
      final x = keyData['x'] as String;
      final y = keyData['y'] as String;

      ECDomainParameters? domain;
      if (crv == 'P-256') {
        domain = ECDomainParameters('secp256r1');
      } else if (crv == 'P-384') {
        domain = ECDomainParameters('secp384r1');
      } else if (crv == 'P-521') {
        domain = ECDomainParameters('secp521r1');
      }

      if (domain == null) return null;

      final xBytes = _decodeBase64Url(x);
      final yBytes = _decodeBase64Url(y);

      final xBigInt = _bytesToBigInt(xBytes);
      final yBigInt = _bytesToBigInt(yBytes);

      final point = domain.curve.createPoint(xBigInt, yBigInt);
      return ECPublicKey(point, domain);
    } catch (e) {
      return null;
    }
  }

  bool _verifyHmacSignature(
    List<int> data,
    Uint8List signature,
    String secret,
  ) {
    try {
      final hmac = HMac(SHA256Digest(), 64)
        ..init(KeyParameter(utf8.encode(secret)));

      final computed = Uint8List(hmac.macSize);
      hmac
        ..update(Uint8List.fromList(data), 0, data.length)
        ..doFinal(computed, 0);

      // Constant-time comparison
      if (computed.length != signature.length) return false;
      var result = 0;
      for (var i = 0; i < computed.length; i++) {
        result |= computed[i] ^ signature[i];
      }
      return result == 0;
    } catch (e) {
      return false;
    }
  }

  bool _verifyAsymmetricSignature(
    List<int> data,
    Uint8List signature,
    AsymmetricKey publicKey,
    String algorithm,
  ) {
    try {
      Signer signer;

      if (algorithm == 'RS256' && publicKey is RSAPublicKey) {
        signer = Signer('SHA-256/RSA')
          ..init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
        return signer.verifySignature(
          Uint8List.fromList(data),
          RSASignature(signature),
        );
      } else if (algorithm == 'ES256' && publicKey is ECPublicKey) {
        signer = Signer('SHA-256/ECDSA')
          ..init(false, PublicKeyParameter<ECPublicKey>(publicKey));
        final ecSig = _parseECSignature(signature);
        return signer.verifySignature(
          Uint8List.fromList(data),
          ECSignature(ecSig.r, ecSig.s),
        );
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  ECSignature _parseECSignature(Uint8List signature) {
    // ES256 signatures are 64 bytes: 32 bytes r + 32 bytes s
    if (signature.length != 64) {
      throw const JwtValidationException('Invalid EC signature length');
    }

    final r = _bytesToBigInt(signature.sublist(0, 32));
    final s = _bytesToBigInt(signature.sublist(32, 64));

    return ECSignature(r, s);
  }

  Uint8List _decodeBase64Url(String input) {
    var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 0:
        break;
      case 2:
        normalized += '==';
      case 3:
        normalized += '=';
      default:
        throw const FormatException('Invalid Base64Url');
    }
    return Uint8List.fromList(base64.decode(normalized));
  }

  BigInt _bigIntFromBase64Url(String input) {
    final bytes = _decodeBase64Url(input);
    return _bytesToBigInt(bytes);
  }

  BigInt _bytesToBigInt(List<int> bytes) {
    var result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) + BigInt.from(byte);
    }
    return result;
  }
}

class _CachedKeys {
  _CachedKeys(this.keys, this.expires);
  final Map<String, AsymmetricKey> keys;
  final DateTime expires;
}
