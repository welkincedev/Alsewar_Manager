import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../models/customer_models.dart';

/// Handles all customer-related API calls.
///
/// The backend assigns the branch from the JWT — never pass branch or manager IDs.
class CustomerService {
  final Dio _dio;

  CustomerService(this._dio);

  // ── List ──────────────────────────────────────────────────────────

  /// GET /api/manager/customers/
  /// Optional [search] matches username/name/email.
  /// Optional [phone] filters by phone number.
  Future<List<CustomerListItem>> getCustomers({
    String? search,
    String? phone,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (phone != null && phone.isNotEmpty) queryParams['phone'] = phone;

      final response = await _dio.get(
        ApiConstants.customers,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      // Support both paginated {"results": [...]} and plain list responses.
      final raw = response.data;
      final List<dynamic> list;
      if (raw is Map && raw.containsKey('results')) {
        list = raw['results'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(CustomerListItem.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Detail ────────────────────────────────────────────────────────

  /// GET /api/manager/customers/{id}/
  Future<CustomerDetailModel> getCustomer(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.customerDetail}$id/');
      return CustomerDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Register ──────────────────────────────────────────────────────

  /// POST /api/manager/customers/
  /// Required: username, email, password.
  /// Optional: phone, first_name, last_name.
  /// The backend assigns the customer to the manager's branch automatically.
  Future<CustomerDetailModel> registerCustomer({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final body = <String, dynamic>{
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
      };
      if (phone != null && phone.trim().isNotEmpty) {
        body['phone'] = phone.trim();
      }
      if (firstName != null && firstName.trim().isNotEmpty) {
        body['first_name'] = firstName.trim();
      }
      if (lastName != null && lastName.trim().isNotEmpty) {
        body['last_name'] = lastName.trim();
      }

      final response = await _dio.post(ApiConstants.customers, data: body);
      return CustomerDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error handling ────────────────────────────────────────────────

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
    final detail = _extractDetail(data);

    switch (status) {
      case 400:
        return Exception(detail ?? 'Invalid data. Please check your input.');
      case 401:
        return Exception('Your session has expired. Please sign in again.');
      case 403:
        return Exception('Access denied.');
      case 404:
        return Exception('Customer not found.');
      case 409:
        return Exception(
          detail ?? 'A customer with this username or email already exists.',
        );
      default:
        if (status != null && status >= 500) {
          return Exception('Server error. Please try again later.');
        }
        return Exception(detail ?? 'An unexpected error occurred.');
    }
  }

  String? _extractDetail(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) return data['detail'] as String?;
      // DRF field-level errors — surface the first message
      for (final value in data.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String) return value;
      }
    }
    return null;
  }
}
