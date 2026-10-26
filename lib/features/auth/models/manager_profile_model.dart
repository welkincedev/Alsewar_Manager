/// Represents the manager profile returned by GET /api/manager/profile/
///
/// Only fields documented by the backend are included.
/// Do not add fields that are not present in the real API response.
class ManagerProfileModel {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String role;
  final bool isActive;
  final String? phone;
  final String? profileImage;
  final String? dateJoined;

  const ManagerProfileModel({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    required this.role,
    required this.isActive,
    this.phone,
    this.profileImage,
    this.dateJoined,
  });

  /// Full display name: "First Last", falling back to username if names absent.
  String get displayName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : username;
  }

  factory ManagerProfileModel.fromJson(Map<String, dynamic> json) {
    return ManagerProfileModel(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      // Accept both 'role' and 'user_role' field names
      role: (json['role'] ?? json['user_role'] ?? 'MANAGER') as String,
      isActive: (json['is_active'] as bool?) ?? true,
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String?,
      dateJoined: json['date_joined'] as String?,
    );
  }
}
