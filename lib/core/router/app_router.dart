import 'package:go_router/go_router.dart';

import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/profile_screen.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/branch/views/dashboard_screen.dart';
import '../../features/customer/views/customer_detail_screen.dart';
import '../../features/customer/views/customer_list_screen.dart';
import '../../features/customer/views/customer_register_screen.dart';
import '../../features/vehicle/views/vehicle_detail_screen.dart';
import '../../features/vehicle/views/vehicle_form_screen.dart';
import '../../features/vehicle/views/vehicle_history_screen.dart';
import '../../features/vehicle/views/vehicle_list_screen.dart';

/// Named route paths — use these constants instead of raw strings.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const profile = '/profile';

  // ── Customer routes ──────────────────────────────────────────────
  static const customers = '/customers';
  static const customerRegister = '/customers/register';

  /// Builds the path for a customer detail screen.
  static String customerDetail(int id) => '/customers/$id';

  // ── Vehicle routes ───────────────────────────────────────────────
  static const vehicles = '/vehicles';
  static const vehicleRegister = '/vehicles/register';

  /// Builds the path for a vehicle detail screen.
  static String vehicleDetail(int id) => '/vehicles/$id';

  /// Builds the path for a vehicle edit screen.
  static String vehicleEdit(int id) => '/vehicles/$id/edit';

  /// Builds the path for a vehicle cross-branch service history screen.
  static String vehicleHistory(int id) => '/vehicles/$id/history';
}

/// The app-wide GoRouter configuration.
///
/// The splash screen is always the first stop.
/// It reads the stored session and redirects accordingly.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true, // remove in production
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    // ── Customer routes ──────────────────────────────────────────
    GoRoute(
      path: AppRoutes.customers,
      builder: (context, state) => const CustomerListScreen(),
    ),
    GoRoute(
      path: AppRoutes.customerRegister,
      builder: (context, state) => const CustomerRegisterScreen(),
    ),
    GoRoute(
      path: '/customers/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CustomerDetailScreen(customerId: id);
      },
    ),

    // ── Vehicle routes ───────────────────────────────────────────
    GoRoute(
      path: AppRoutes.vehicles,
      builder: (context, state) {
        final customerIdStr = state.uri.queryParameters['customerId'];
        final customerId = customerIdStr != null
            ? int.tryParse(customerIdStr)
            : null;
        return VehicleListScreen(initialCustomerId: customerId);
      },
    ),
    GoRoute(
      path: AppRoutes.vehicleRegister,
      builder: (context, state) {
        final customerIdStr = state.uri.queryParameters['customerId'];
        final customerId = customerIdStr != null
            ? int.tryParse(customerIdStr)
            : null;
        return VehicleFormScreen(initialCustomerId: customerId);
      },
    ),
    GoRoute(
      path: '/vehicles/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return VehicleDetailScreen(vehicleId: id);
      },
    ),
    GoRoute(
      path: '/vehicles/:id/edit',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return VehicleFormScreen(vehicleId: id);
      },
    ),
    GoRoute(
      path: '/vehicles/:id/history',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return VehicleHistoryScreen(vehicleId: id);
      },
    ),
  ],
);
