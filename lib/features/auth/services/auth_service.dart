import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/storage/token_storage.dart';
import '../models/manager_auth_model.dart';

/// Handles all authentication API calls for the manager.
///
/// This service is a plain Dart class — it has no Flutter or Riverpod dependency.
/// The ViewModel will call these methods and translate results into UI state.
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Sends the manager's credentials to the login endpoint.
  ///
  /// On success: parses the token response, validates manager role,
  /// saves tokens to secure storage, and returns the [ManagerAuthModel].
  ///
  /// On failure: throws a descriptive [Exception] for the ViewModel to catch.
  Future<ManagerAuthModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.managerLogin,
        data: {'username': username, 'password': password},
      );

      final auth = ManagerAuthModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Validate role if the backend returns one.
      // This is a client-side check — the backend enforces access too.
      if (auth.role != null && auth.role != 'MANAGER') {
        throw Exception(
          'This account does not have manager access. '
          'Please use a manager account.',
        );
      }

      // Reject inactive accounts if the backend returns is_active.
      if (auth.isActive != null && auth.isActive == false) {
        throw Exception(
          'Your account is inactive. Please contact your administrator.',
        );
      }

      if (auth.accessToken.isEmpty) {
        throw Exception(
          'Login succeeded but no access token was returned. '
          'Please contact support.',
        );
      }

      // Persist tokens securely
      await TokenStorage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );

      return auth;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logs out the manager.
  ///
  /// Calls the server-side logout endpoint to invalidate the refresh token,
  /// then always clears local storage regardless of the API result.
  /// The user is never left stuck in a logged-in state.
  Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        // POST the refresh token so the server can blacklist it.
        await _dio.post(
          ApiConstants.managerLogout,
          data: {'refresh': refreshToken},
        );
      }
    } catch (_) {
      // Network or server error — ignore and clear locally regardless.
    } finally {
      await TokenStorage.clearTokens();
    }
  }

  /// Translates a [DioException] into a human-readable message.
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Exception(
        'Cannot reach the server. Check your internet connection and try again.',
      );
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    switch (statusCode) {
      case 400:
        // Try to extract a validation message from the response body
        final detail = _extractDetail(data);
        return Exception(detail ?? 'Invalid request. Please check your input.');
      case 401:
        return Exception('Incorrect username or password.');
      case 403:
        return Exception(
          'Access denied. This account does not have manager permissions.',
        );
      case 404:
        return Exception('Login endpoint not found. Please contact support.');
      case 500:
        return Exception(
          'The server encountered an error. Please try again later.',
        );
      default:
        return Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Tries to extract a "detail" or first error message from a response body.
  String? _extractDetail(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) return data['detail'] as String?;
      // DRF field errors — grab the first one
      final firstValue = data.values.firstOrNull;
      if (firstValue is List && firstValue.isNotEmpty) {
        return firstValue.first as String?;
      }
    }
    return null;
  }
}
