/// Customer summary nested in vehicle responses.
class VehicleCustomerInfo {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? phone;

  const VehicleCustomerInfo({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.phone,
  });

  String get displayName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : username;
  }

  factory VehicleCustomerInfo.fromJson(Map<String, dynamic> json) {
    return VehicleCustomerInfo(
      id: json['id'] as int,
      username: json['username'] as String? ?? 'Customer #$json',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

/// Branch summary nested in vehicle responses.
class VehicleBranchInfo {
  final int id;
  final String name;
  final String code;
  final String? city;

  const VehicleBranchInfo({
    required this.id,
    required this.name,
    required this.code,
    this.city,
  });

  factory VehicleBranchInfo.fromJson(Map<String, dynamic> json) {
    return VehicleBranchInfo(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      city: json['city'] as String?,
    );
  }
}

/// Represents a vehicle returned by GET /api/manager/vehicles/
/// and GET /api/manager/vehicles/{id}/
class VehicleModel {
  final int id;
  final int customerId;
  final VehicleCustomerInfo? customerDetails;
  final int? branchId;
  final VehicleBranchInfo? branchDetails;
  final String plateNumber;
  final String make;
  final String model;
  final int? year;
  final String? color;
  final String? vin;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const VehicleModel({
    required this.id,
    required this.customerId,
    this.customerDetails,
    this.branchId,
    this.branchDetails,
    required this.plateNumber,
    required this.make,
    required this.model,
    this.year,
    this.color,
    this.vin,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Display string: e.g. "Toyota Camry"
  String get name => '$make $model'.trim();

  /// Extended title with year if present: e.g. "2022 Toyota Camry"
  String get titleWithYear {
    if (year != null && year! > 0) {
      return '$year $name';
    }
    return name;
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Parse year safely whether string or int
    int? parsedYear;
    if (json['year'] != null) {
      if (json['year'] is int) {
        parsedYear = json['year'] as int;
      } else {
        parsedYear = int.tryParse(json['year'].toString());
      }
    }

    VehicleCustomerInfo? customerDetails;
    if (json['customer_details'] is Map<String, dynamic>) {
      customerDetails = VehicleCustomerInfo.fromJson(
        json['customer_details'] as Map<String, dynamic>,
      );
    }

    VehicleBranchInfo? branchDetails;
    if (json['branch_details'] is Map<String, dynamic>) {
      branchDetails = VehicleBranchInfo.fromJson(
        json['branch_details'] as Map<String, dynamic>,
      );
    } else if (json['branch'] is Map<String, dynamic>) {
      branchDetails = VehicleBranchInfo.fromJson(
        json['branch'] as Map<String, dynamic>,
      );
    }

    int customerId = 0;
    if (json['customer'] is int) {
      customerId = json['customer'] as int;
    } else if (json['customer_id'] is int) {
      customerId = json['customer_id'] as int;
    } else if (json['customer'] is Map &&
        (json['customer'] as Map)['id'] is int) {
      customerId = (json['customer'] as Map)['id'] as int;
    } else if (customerDetails != null) {
      customerId = customerDetails.id;
    }

    return VehicleModel(
      id: json['id'] as int,
      customerId: customerId,
      customerDetails: customerDetails,
      branchId: (json['branch'] is int)
          ? json['branch'] as int
          : branchDetails?.id,
      branchDetails: branchDetails,
      plateNumber:
          (json['plate_number'] ?? json['license_plate'] ?? '') as String,
      make: (json['make'] ?? '') as String,
      model: (json['model'] ?? '') as String,
      year: parsedYear,
      color: json['color'] as String?,
      vin: json['vin'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

// ── Service History Models ───────────────────────────────────────────────────

class HistoryVisitService {
  final int id;
  final String name;
  final String? description;
  final String? notes;

  const HistoryVisitService({
    required this.id,
    required this.name,
    this.description,
    this.notes,
  });

  factory HistoryVisitService.fromJson(Map<String, dynamic> json) {
    return HistoryVisitService(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Service',
      description: json['description'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class HistoryVisitStage {
  final int? id;
  final String name;
  final String code;
  final bool isTerminal;

  const HistoryVisitStage({
    this.id,
    required this.name,
    required this.code,
    this.isTerminal = false,
  });

  factory HistoryVisitStage.fromJson(Map<String, dynamic> json) {
    return HistoryVisitStage(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'In Progress',
      code: json['code'] as String? ?? 'UNKNOWN',
      isTerminal: (json['is_terminal'] as bool?) ?? false,
    );
  }
}

class VehicleVisitItem {
  final int id;
  final String visitNumber;
  final VehicleBranchInfo? branch;
  final HistoryVisitStage? currentStage;
  final List<HistoryVisitService> services;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const VehicleVisitItem({
    required this.id,
    required this.visitNumber,
    this.branch,
    this.currentStage,
    this.services = const [],
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleVisitItem.fromJson(Map<String, dynamic> json) {
    VehicleBranchInfo? branchInfo;
    if (json['branch_details'] is Map<String, dynamic>) {
      branchInfo = VehicleBranchInfo.fromJson(
        json['branch_details'] as Map<String, dynamic>,
      );
    } else if (json['branch'] is Map<String, dynamic>) {
      branchInfo = VehicleBranchInfo.fromJson(
        json['branch'] as Map<String, dynamic>,
      );
    }

    HistoryVisitStage? stage;
    if (json['current_stage'] is Map<String, dynamic>) {
      stage = HistoryVisitStage.fromJson(
        json['current_stage'] as Map<String, dynamic>,
      );
    }

    final rawServices = json['services'];
    final List<HistoryVisitService> services;
    if (rawServices is List) {
      services = rawServices
          .whereType<Map<String, dynamic>>()
          .map(HistoryVisitService.fromJson)
          .toList();
    } else {
      services = const [];
    }

    return VehicleVisitItem(
      id: json['id'] as int,
      visitNumber: json['visit_number'] as String? ?? 'Visit #${json['id']}',
      branch: branchInfo,
      currentStage: stage,
      services: services,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class VehicleServiceHistoryModel {
  final int visitCount;
  final String? lastVisitDate;
  final List<VehicleVisitItem> visits;

  const VehicleServiceHistoryModel({
    required this.visitCount,
    this.lastVisitDate,
    this.visits = const [],
  });

  factory VehicleServiceHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawVisits = json['visits'];
    final List<VehicleVisitItem> visits;
    if (rawVisits is List) {
      visits = rawVisits
          .whereType<Map<String, dynamic>>()
          .map(VehicleVisitItem.fromJson)
          .toList();
    } else {
      visits = const [];
    }

    return VehicleServiceHistoryModel(
      visitCount: (json['visit_count'] as int?) ?? visits.length,
      lastVisitDate: json['last_visit_date'] as String?,
      visits: visits,
    );
  }
}
