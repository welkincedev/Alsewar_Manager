import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

/// Creates and configures a single shared Dio HTTP client.
///
/// This client automatically:
/// - Sets the base URL and JSON content type on every request
/// - Attaches the JWT access token to all requests via the Authorization header
/// - On 401: attempts a silent token refresh, retries the original request once
/// - If refresh fails: clears the session so the router redirects to login
Dio createApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(_AuthInterceptor(dio));

  // Uncomment to log requests/responses during development:
  // dio.interceptors.add(LogInterceptor(responseBody: true));

  return dio;
}

/// Interceptor that attaches the JWT access token to every request and
/// transparently refreshes it when a 401 is received.
///
/// Refresh logic:
/// 1. On 401 response, read the stored refresh token.
/// 2. POST it to [ApiConstants.tokenRefresh].
/// 3. If the server returns a new access token (and optionally a new refresh
///    token), store them and retry the original request once.
/// 4. If the refresh fails for any reason, clear the session. The app's
///    splash screen will redirect the user to login on next navigation.
class _AuthInterceptor extends Interceptor {
  /// A separate Dio instance used only for the refresh call, bypassing this
  /// interceptor so we don't accidentally trigger recursive 401 handling.
  final Dio _mainDio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._mainDio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestPath = err.requestOptions.path;

    // Only attempt refresh on 401, and not if we're already refreshing
    // or if this is itself a refresh/login request (prevent loops).
    final isAuthEndpoint =
        requestPath.contains(ApiConstants.tokenRefresh) ||
        requestPath.contains(ApiConstants.managerLogin) ||
        requestPath.contains(ApiConstants.managerLogout);

    if (statusCode == 401 && !_isRefreshing && !isAuthEndpoint) {
      _isRefreshing = true;
      try {
        final refreshed = await _tryRefresh();
        _isRefreshing = false;

        if (refreshed) {
          // Retry the original request with the new access token.
          final newToken = await TokenStorage.getAccessToken();
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';

          final retryResponse = await _mainDio.fetch(retryOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (_) {
        _isRefreshing = false;
      }

      // Refresh failed or was skipped — clear session.
      await TokenStorage.clearTokens();
    }

    handler.next(err);
  }

  /// Attempts to refresh the access token.
  ///
  /// Returns true if a new access token was stored successfully.
  /// Returns false if no refresh token exists or the server rejects it.
  Future<bool> _tryRefresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    // Use a fresh Dio that does NOT go through this interceptor.
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    try {
      final response = await refreshDio.post(
        ApiConstants.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;

      // Standard DRF Simple JWT returns 'access'; some setups also rotate 'refresh'.
      final newAccess = data['access'] as String?;
      final newRefresh = data['refresh'] as String?;

      if (newAccess == null || newAccess.isEmpty) return false;

      await TokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh, // may be null if rotation is disabled
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
