import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../models/branch_models.dart';

/// Handles all branch-related API calls for the manager.
///
/// Never sends a branch ID or manager ID — the backend
/// identifies the branch from the JWT automatically.
class BranchService {
  final Dio _dio;

  BranchService(this._dio);

  /// GET /api/manager/branch/
  /// Returns the branch assigned to the logged-in manager.
  Future<BranchModel> getMyAssignedBranch() async {
    try {
      final response = await _dio.get(ApiConstants.managerBranch);
      return BranchModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/manager/branch/hours/
  /// Returns the full weekly schedule for the manager's assigned branch.
  Future<List<BusinessHourModel>> getMyBranchHours() async {
    try {
      final response = await _dio.get(ApiConstants.branchHours);
      final list = response.data as List<dynamic>;
      return list
          .map(
            (item) => BusinessHourModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
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
          'Access denied. You do not have permission to view this branch.',
        );
      case 404:
        return Exception(
          detail ?? 'No branch is currently assigned to your account.',
        );
      default:
        if (status != null && status >= 500) {
          return Exception('Server error. Please try again later.');
        }
        return Exception('An unexpected error occurred. Please try again.');
    }
  }
}
