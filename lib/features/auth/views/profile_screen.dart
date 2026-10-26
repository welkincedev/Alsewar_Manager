import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/manager_profile_model.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';

/// Profile screen — fetches the manager profile from GET /api/manager/profile/
/// and provides a logout button.
///
/// Shows real API data with loading, error and retry states.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Reload profile data
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(profileViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const _LoadingView(),
        error: (error, _) => _ErrorView(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(profileViewModelProvider.notifier).refresh(),
        ),
        data: (profile) => _ProfileContent(
          profile: profile,
          onLogout: () => _logout(context, ref),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    // Show confirmation so the user doesn't accidentally sign out
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Call backend logout (invalidates refresh token) and clear local storage.
    await ref.read(authServiceProvider).logout();

    // Reset login state so the login screen starts fresh.
    ref.read(loginViewModelProvider.notifier).reset();

    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }
}

// ── Profile data content ──────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  final ManagerProfileModel profile;
  final VoidCallback onLogout;

  const _ProfileContent({required this.profile, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Avatar / name header ──────────────────────────────────
        Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.gold,
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                profile.displayName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              _RoleBadge(role: profile.role),
              const SizedBox(height: 4),
              _StatusBadge(isActive: profile.isActive),
              const SizedBox(height: 28),
            ],
          ),
        ),

        // ── Account details card ──────────────────────────────────
        _InfoCard(
          title: 'Account',
          rows: [
            _InfoRow(
              icon: Icons.account_circle_outlined,
              label: profile.username,
              hint: 'Username',
            ),
            if (profile.email != null && profile.email!.isNotEmpty)
              _InfoRow(
                icon: Icons.email_outlined,
                label: profile.email!,
                hint: 'Email',
              ),
            if (profile.phone != null && profile.phone!.isNotEmpty)
              _InfoRow(
                icon: Icons.phone_outlined,
                label: profile.phone!,
                hint: 'Phone',
              ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Date joined (if available) ────────────────────────────
        if (profile.dateJoined != null) ...[
          _InfoCard(
            title: 'Member Since',
            rows: [
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: _formatDate(profile.dateJoined!),
                hint: 'Date joined',
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 8),

        // ── Logout button ─────────────────────────────────────────
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorRed,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
          onPressed: onLogout,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Formats ISO-8601 date string "2024-01-15T09:00:00Z" → "15 Jan 2024"
  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.circle : Icons.circle_outlined,
            size: 8,
            color: isActive ? AppColors.successGreen : AppColors.errorRed,
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive ? AppColors.successGreen : AppColors.errorRed,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (row) =>
                Padding(padding: const EdgeInsets.only(bottom: 10), child: row),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  const _InfoRow({required this.icon, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hint,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Loading / Error states ────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.gold),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
