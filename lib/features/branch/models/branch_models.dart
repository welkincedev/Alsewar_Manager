/// Represents a branch returned by GET /api/manager/branch/
class BranchModel {
  final int id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String phone;
  final String email;
  final String? latitude;
  final String? longitude;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const BranchModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

/// Represents one day's operating hours returned by GET /api/manager/branch/hours/
class BusinessHourModel {
  final int id;
  final int dayOfWeek;
  final String dayName;
  final String? openingTime;
  final String? closingTime;
  final bool isClosed;

  const BusinessHourModel({
    required this.id,
    required this.dayOfWeek,
    required this.dayName,
    this.openingTime,
    this.closingTime,
    required this.isClosed,
  });

  factory BusinessHourModel.fromJson(Map<String, dynamic> json) {
    return BusinessHourModel(
      id: json['id'] as int,
      dayOfWeek: json['day_of_week'] as int,
      dayName: json['day_name'] as String,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      isClosed: json['is_closed'] as bool,
    );
  }

  /// Returns a human-readable time range, e.g. "9:00 AM – 6:00 PM"
  String get hoursDisplay {
    if (isClosed) return 'Closed';
    if (openingTime == null || closingTime == null) return 'Hours unavailable';
    return '${_fmt(openingTime!)} – ${_fmt(closingTime!)}';
  }

  /// Converts "09:00:00" → "9:00 AM"
  String _fmt(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    final String period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    final String minStr = minute.toString().padLeft(2, '0');
    return '$hour:$minStr $period';
  }
}
