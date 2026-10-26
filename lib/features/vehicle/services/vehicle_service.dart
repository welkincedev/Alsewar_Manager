import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../models/vehicle_models.dart';

/// Handles all vehicle-related API calls for branch managers.
///
/// Automatic branch scoping is handled by the backend from the manager's JWT.
/// Never send manager or branch IDs.
class VehicleService {
  final Dio _dio;

  VehicleService(this._dio);

  // ── List & Search ──────────────────────────────────────────────────────────

  /// GET /api/manager/vehicles/
  /// Optional filters:
  /// - [search]: matches plate_number, make, model, or vin
  /// - [plateNumber]: filters by plate number
  /// - [customerId]: filters vehicles for a specific customer
  /// - [isActive]: filter by active status (defaults to true)
  Future<List<VehicleModel>> getVehicles({
    String? search,
    String? plateNumber,
    int? customerId,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (plateNumber != null && plateNumber.isNotEmpty) {
        queryParams['plate_number'] = plateNumber;
      }
      if (customerId != null) {
        queryParams['customer_id'] = customerId;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }

      final response = await _dio.get(
        ApiConstants.vehicles,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

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
          .map(VehicleModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Detail ─────────────────────────────────────────────────────────────────

  /// GET /api/manager/vehicles/{id}/
  Future<VehicleModel> getVehicle(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.vehicles}$id/');
      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────

  /// POST /api/manager/vehicles/
  /// Required: customer (id), plate_number, make, model
  /// Optional: year, color, vin
  Future<VehicleModel> registerVehicle({
    required int customerId,
    required String plateNumber,
    required String make,
    required String model,
    int? year,
    String? color,
    String? vin,
  }) async {
    try {
      final body = <String, dynamic>{
        'customer': customerId,
        'customer_id': customerId,
        'plate_number': plateNumber.trim().toUpperCase(),
        'make': make.trim(),
        'model': model.trim(),
      };
      if (year != null && year > 0) {
        body['year'] = year;
      }
      if (color != null && color.trim().isNotEmpty) {
        body['color'] = color.trim();
      }
      if (vin != null && vin.trim().isNotEmpty) {
        body['vin'] = vin.trim();
      }

      final response = await _dio.post(ApiConstants.vehicles, data: body);
      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// PATCH /api/manager/vehicles/{id}/
  Future<VehicleModel> updateVehicle(
    int id, {
    String? plateNumber,
    String? make,
    String? model,
    int? year,
    String? color,
    String? vin,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (plateNumber != null && plateNumber.trim().isNotEmpty) {
        body['plate_number'] = plateNumber.trim().toUpperCase();
      }
      if (make != null && make.trim().isNotEmpty) {
        body['make'] = make.trim();
      }
      if (model != null && model.trim().isNotEmpty) {
        body['model'] = model.trim();
      }
      if (year != null && year > 0) {
        body['year'] = year;
      }
      if (color != null) {
        body['color'] = color.trim();
      }
      if (vin != null) {
        body['vin'] = vin.trim();
      }

      final response = await _dio.patch(
        '${ApiConstants.vehicles}$id/',
        data: body,
      );
      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Deactivate (Delete) ────────────────────────────────────────────────────

  /// DELETE /api/manager/vehicles/{id}/
  /// Soft-deactivates the vehicle.
  Future<void> deleteVehicle(int id) async {
    try {
      await _dio.delete('${ApiConstants.vehicles}$id/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Service History (Cross-Branch) ─────────────────────────────────────────

  /// GET /api/manager/vehicles/{id}/history/
  /// Returns lifetime cross-branch service visits for the vehicle.
  Future<VehicleServiceHistoryModel> getVehicleHistory(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.vehicles}$id/history/');
      return VehicleServiceHistoryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error Handling ─────────────────────────────────────────────────────────

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
        return Exception(
          detail ?? 'Invalid vehicle data. Please check your inputs.',
        );
      case 401:
        return Exception('Your session has expired. Please sign in again.');
      case 403:
        return Exception('Access denied. Manager permissions required.');
      case 404:
        return Exception(detail ?? 'Vehicle not found.');
      case 409:
        return Exception(
          detail ?? 'A vehicle with this plate number or VIN already exists.',
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
      // 1. Direct detail / message / error string
      if (data.containsKey('detail') && data['detail'] != null) {
        return data['detail'].toString();
      }
      if (data.containsKey('message') && data['message'] != null) {
        return data['message'].toString();
      }
      if (data.containsKey('error') && data['error'] != null) {
        return data['error'].toString();
      }

      // 2. Non-field errors
      if (data.containsKey('non_field_errors')) {
        final nfe = data['non_field_errors'];
        if (nfe is List && nfe.isNotEmpty) {
          return nfe.map((e) => e.toString()).join('\n');
        }
        if (nfe is String && nfe.isNotEmpty) {
          return nfe;
        }
      }

      // 3. Field-specific errors: format as "Field Name: error message"
      final fieldErrors = <String>[];
      data.forEach((key, value) {
        if (key == 'detail' ||
            key == 'message' ||
            key == 'error' ||
            key == 'non_field_errors') {
          return;
        }
        final readableKey = _humanizeFieldName(key);
        if (value is List && value.isNotEmpty) {
          final msg = value.map((v) => v.toString()).join(' ');
          fieldErrors.add('$readableKey: $msg');
        } else if (value is String && value.isNotEmpty) {
          fieldErrors.add('$readableKey: $value');
        } else if (value is Map) {
          fieldErrors.add('$readableKey: ${value.values.join(" ")}');
        }
      });

      if (fieldErrors.isNotEmpty) {
        return fieldErrors.join('\n');
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return null;
  }

  static String _humanizeFieldName(String key) {
    var clean = key;
    if (clean.endsWith('_id')) {
      clean = clean.substring(0, clean.length - 3);
    }
    final words = clean.replaceAll('_', ' ').trim().split(RegExp(r'\s+'));
    return words
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
