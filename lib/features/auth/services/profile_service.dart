import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../models/manager_profile_model.dart';

/// Fetches the authenticated manager's profile from the API.
///
/// Never passes a manager ID — the backend derives it from the JWT.
class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  /// GET /api/manager/profile/
  Future<ManagerProfileModel> getMyProfile() async {
    try {
      final response = await _dio.get(ApiConstants.managerProfile);
      return ManagerProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Exception(
        'Cannot reach the server. Check your connection and try again.',
      );
    }
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final detail = data is Map ? data['detail'] as String? : null;

    switch (status) {
      case 401:
        return Exception('Your session has expired. Please sign in again.');
      case 403:
        return Exception(
          'Access denied. You do not have permission to view this profile.',
        );
      case 404:
        return Exception('Manager profile not found.');
      default:
        if (status != null && status >= 500) {
          return Exception('Server error. Please try again later.');
        }
        return Exception(detail ?? 'An unexpected error occurred.');
    }
  }
}
