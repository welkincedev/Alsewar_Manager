// Central place for all API-related constants.
// To switch between Android emulator and a physical device, change [useEmulator].

class ApiConstants {
  ApiConstants._(); // prevent instantiation

  /// Set to true when using an Android emulator.
  /// 10.0.2.2 is the emulator's alias for the host machine's localhost.
  ///
  /// Set to false when running on a physical device — it will use the
  /// LAN IP of the machine running the backend.

  static const String baseUrl = 'http://192.168.1.6:8001';
  // static const String baseUrl = 'http://10.112.149.146:8001';

  // ── Auth endpoints ──────────────────────────────────────────────
  static const String managerLogin = '/api/manager/login/';

  /// Refresh the access token using the stored refresh token.
  static const String tokenRefresh = '/api/manager/token/refresh/';

  /// Server-side logout — invalidates the refresh token.
  static const String managerLogout = '/api/manager/logout/';

  // ── Manager profile ─────────────────────────────────────────────
  /// Returns the profile of the currently authenticated manager.
  static const String managerProfile = '/api/manager/profile/';

  // ── Customer endpoints ──────────────────────────────────────────
  /// List branch customers; supports ?search= and ?phone= query params.
  static const String customers = '/api/manager/customers/';

  /// Detail for a single customer by ID.
  /// Interpolate the ID: '${ApiConstants.customers}$id/'
  static const String customerDetail = '/api/manager/customers/';

  // ── Vehicle endpoints ───────────────────────────────────────────
  /// List branch vehicles; supports ?search=, ?plate_number=, ?customer_id=, ?is_active=
  static const String vehicles = '/api/manager/vehicles/';

  // ── Branch endpoints ────────────────────────────────────────────
  /// Returns the branch assigned to the currently authenticated manager.
  /// The backend determines the branch from the JWT — do NOT pass a branch ID.
  static const String managerBranch = '/api/manager/branch/';

  /// Returns the operating hours for the manager's assigned branch.
  static const String branchHours = '/api/manager/branch/hours/';
}
