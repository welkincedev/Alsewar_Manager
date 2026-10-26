import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_theme.dart';

/// The first screen the app always shows on startup.
///
/// What it does:
/// 1. Displays the Al Sewar logo/branding briefly.
/// 2. Checks whether a valid session token is stored.
/// 3. Navigates to the dashboard if logged in, or to login if not.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Wait a moment so the splash branding is visible
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    final hasSession = await TokenStorage.hasSession();

    if (!mounted) return;

    if (hasSession) {
      // A token exists — go to the dashboard.
      // The dashboard will handle the case where the token is actually expired.
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo / Brand mark ────────────────────────────────
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                color: AppColors.gold,
                size: 52,
              ),
            ),
            const SizedBox(height: 28),

            // ── App name ─────────────────────────────────────────
            const Text(
              'AL SEWAR',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'AUTO CENTER',
              style: TextStyle(
                color: AppColors.goldLight,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Branch Manager',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 64),

            // ── Loading indicator ────────────────────────────────
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
