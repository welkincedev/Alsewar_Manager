/// Represents the data returned by the manager login endpoint.
///
/// Fields are marked nullable because the actual backend response
/// is not fully confirmed yet — we map only what we know is documented.
/// Update this model once a real login response is captured.
class ManagerAuthModel {
  final String accessToken;
  final String? refreshToken;

  // Profile fields — include only if the backend actually returns them.
  // Do NOT add fields that aren't in the real API response.
  final String? username;
  final String? role;
  final bool? isActive;

  const ManagerAuthModel({
    required this.accessToken,
    this.refreshToken,
    this.username,
    this.role,
    this.isActive,
  });

  /// Parse from the JSON map returned by POST /api/manager/login/
  ///
  /// ⚠️  Token field names (access, refresh) are common Django REST Framework
  /// defaults. Verify against a real login response and adjust if needed.
  factory ManagerAuthModel.fromJson(Map<String, dynamic> json) {
    return ManagerAuthModel(
      // Try both 'access' and 'token' — common Django JWT field names
      accessToken: (json['access'] ?? json['token'] ?? '') as String,
      refreshToken: json['refresh'] as String?,
      username: json['username'] as String?,
      role: json['role'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }
}
