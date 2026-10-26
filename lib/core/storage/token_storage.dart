import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles reading and writing JWT tokens to the device's secure storage.
///
/// On Android this uses the Keystore system.
/// On iOS it uses the Keychain.
/// On Windows it uses the Windows Credential Manager.
class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Storage keys — kept private so nothing outside this class uses raw strings
  static const _accessTokenKey = 'manager_access_token';
  static const _refreshTokenKey = 'manager_refresh_token';

  // ── Write ────────────────────────────────────────────────────────

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  // ── Read ─────────────────────────────────────────────────────────

  static Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// Returns true if an access token exists in storage.
  /// Used during app startup to decide whether to show login or dashboard.
  static Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Delete ───────────────────────────────────────────────────────

  /// Clears all stored tokens. Called on logout.
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
