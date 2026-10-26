/// Represents a customer in the list returned by GET /api/manager/customers/
///
/// The list endpoint may return a subset of fields. The detail endpoint
/// [CustomerDetailModel] includes additional fields like vehicles.
class CustomerListItem {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final bool isActive;
  final String? dateJoined;

  const CustomerListItem({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    required this.isActive,
    this.dateJoined,
  });

  /// Full display name: "First Last", falling back to username if names absent.
  String get displayName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : username;
  }

  factory CustomerListItem.fromJson(Map<String, dynamic> json) {
    return CustomerListItem(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      dateJoined: json['date_joined'] as String?,
    );
  }
}

/// Represents a customer vehicle as nested in the detail response.
class CustomerVehicle {
  final int id;
  final String? make;
  final String? model;
  final String? year;
  final String? licensePlate;
  final String? color;

  const CustomerVehicle({
    required this.id,
    this.make,
    this.model,
    this.year,
    this.licensePlate,
    this.color,
  });

  /// Human-readable summary, e.g. "2020 Toyota Camry" or licence plate if names absent.
  String get summary {
    final parts = [year, make, model].where((p) => p != null && p.isNotEmpty);
    final desc = parts.join(' ').trim();
    if (desc.isNotEmpty) return desc;
    return licensePlate ?? 'Vehicle #$id';
  }

  factory CustomerVehicle.fromJson(Map<String, dynamic> json) {
    return CustomerVehicle(
      id: json['id'] as int,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year']?.toString(),
      licensePlate: (json['license_plate'] ?? json['plate_number']) as String?,
      color: json['color'] as String?,
    );
  }
}

/// Represents a customer with full detail, returned by GET /api/manager/customers/{id}/
class CustomerDetailModel {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final bool isActive;
  final String? dateJoined;
  final List<CustomerVehicle> vehicles;

  const CustomerDetailModel({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    required this.isActive,
    this.dateJoined,
    this.vehicles = const [],
  });

  String get displayName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : username;
  }

  factory CustomerDetailModel.fromJson(Map<String, dynamic> json) {
    final rawVehicles = json['vehicles'];
    final List<CustomerVehicle> vehicles;
    if (rawVehicles is List) {
      vehicles = rawVehicles
          .whereType<Map<String, dynamic>>()
          .map(CustomerVehicle.fromJson)
          .toList();
    } else {
      vehicles = const [];
    }

    return CustomerDetailModel(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      dateJoined: json['date_joined'] as String?,
      vehicles: vehicles,
    );
  }
}
