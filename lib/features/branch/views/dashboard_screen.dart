import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/branch_models.dart';
import '../viewmodels/branch_viewmodel.dart';

/// Manager dashboard — shows the assigned branch overview and hours.
/// Pulls real data from the API; no hardcoded or fake values.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchAsync = ref.watch(branchViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('My Branch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Customers',
            onPressed: () => context.push(AppRoutes.customers),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: branchAsync.when(
        loading: () => const _LoadingView(),
        error: (error, _) => _ErrorView(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(branchViewModelProvider.notifier).refresh(),
        ),
        data: (data) => _BranchContent(data: data, ref: ref),
      ),
    );
  }
}

// ── Main content (data loaded) ────────────────────────────────────────────────

class _BranchContent extends StatelessWidget {
  final BranchData data;
  final WidgetRef ref;

  const _BranchContent({required this.data, required this.ref});

  @override
  Widget build(BuildContext context) {
    final branch = data.branch;
    final hours = data.hours;

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () => ref.read(branchViewModelProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Branch status header ────────────────────────────────
          _StatusHeader(branch: branch),
          const SizedBox(height: 16),

          // ── Quick action: Customers ─────────────────────────────
          _ManagementCard(
            title: 'Customers',
            subtitle: 'View, search, and register customers',
            icon: Icons.people_outline,
            onTap: () => context.push(AppRoutes.customers),
          ),
          const SizedBox(height: 12),

          // ── Quick action: Vehicles ──────────────────────────────
          _ManagementCard(
            title: 'Vehicles',
            subtitle: 'Inspect fleet, history, and register vehicles',
            icon: Icons.directions_car_outlined,
            onTap: () => context.push(AppRoutes.vehicles),
          ),
          const SizedBox(height: 16),

          // ── Contact info ───────────────────────────────────────
          _InfoCard(
            title: 'Contact',
            children: [
              _InfoRow(icon: Icons.phone_outlined, label: branch.phone),
              const SizedBox(height: 10),
              _InfoRow(icon: Icons.email_outlined, label: branch.email),
            ],
          ),
          const SizedBox(height: 16),

          // ── Location ───────────────────────────────────────────
          _InfoCard(
            title: 'Location',
            children: [
              _InfoRow(icon: Icons.location_on_outlined, label: branch.address),
              const SizedBox(height: 10),
              _InfoRow(icon: Icons.location_city_outlined, label: branch.city),
            ],
          ),
          const SizedBox(height: 16),

          // ── Operating hours ────────────────────────────────────
          _HoursCard(hours: hours),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Status header card ────────────────────────────────────────────────────────

class _StatusHeader extends StatelessWidget {
  final BranchModel branch;
  const _StatusHeader({required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                branch.code,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              _ActiveBadge(isActive: branch.isActive),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            branch.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool isActive;
  const _ActiveBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.successGreen.withValues(alpha: 0.15)
            : AppColors.errorRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.successGreen : AppColors.errorRed,
          width: 0.8,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? AppColors.successGreen : AppColors.errorRed,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Reusable card ─────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

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
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

// ── Operating hours card ──────────────────────────────────────────────────────

class _HoursCard extends StatelessWidget {
  final List<BusinessHourModel> hours;
  const _HoursCard({required this.hours});

  @override
  Widget build(BuildContext context) {
    // Sort Mon → Sun by day_of_week index
    final sorted = [...hours]
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

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
          const Text(
            'OPERATING HOURS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          if (sorted.isEmpty)
            const Text(
              'No hours information available.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            )
          else
            ...sorted.map((h) => _HoursRow(hour: h)),
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final BusinessHourModel hour;
  const _HoursRow({required this.hour});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              hour.dayName,
              style: TextStyle(
                color: hour.isClosed
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hour.hoursDisplay,
              style: TextStyle(
                color: hour.isClosed ? AppColors.textSecondary : AppColors.gold,
                fontSize: 14,
                fontWeight: hour.isClosed ? FontWeight.w400 : FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
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
              Icons.cloud_off_outlined,
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

// ── Quick action management card ──────────────────────────────────────────────

class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.gold,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
