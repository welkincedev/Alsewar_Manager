import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/customer_models.dart';
import '../viewmodels/customer_viewmodel.dart';

/// Shows the full details of a single customer.
///
/// Receives the customer [id] via the GoRouter path parameter.
class CustomerDetailScreen extends ConsumerWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(
      customerDetailViewModelProvider(customerId),
    );

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref
                .read(customerDetailViewModelProvider(customerId).notifier)
                .refresh(customerId),
          ),
        ],
      ),
      body: customerAsync.when(
        loading: () => const _LoadingView(),
        error: (error, _) => _ErrorView(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref
              .read(customerDetailViewModelProvider(customerId).notifier)
              .refresh(customerId),
        ),
        data: (customer) => _CustomerDetailContent(customer: customer),
      ),
    );
  }
}

// ── Detail content ────────────────────────────────────────────────────────────

class _CustomerDetailContent extends StatelessWidget {
  final CustomerDetailModel customer;

  const _CustomerDetailContent({required this.customer});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Header ────────────────────────────────────────────────
        _CustomerHeader(customer: customer),
        const SizedBox(height: 20),

        // ── Account info ──────────────────────────────────────────
        _InfoCard(
          title: 'Account',
          children: [
            _InfoRow(
              icon: Icons.account_circle_outlined,
              hint: 'Username',
              label: customer.username,
            ),
            if (customer.email != null && customer.email!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.email_outlined,
                hint: 'Email',
                label: customer.email!,
              ),
            ],
            if (customer.phone != null && customer.phone!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.phone_outlined,
                hint: 'Phone',
                label: customer.phone!,
              ),
            ],
            if (customer.dateJoined != null) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                hint: 'Member Since',
                label: _formatDate(customer.dateJoined!),
              ),
            ],
          ],
        ),

        // ── Vehicles ──────────────────────────────────────────────
        const SizedBox(height: 16),
        _VehiclesCard(customerId: customer.id, vehicles: customer.vehicles),

        const SizedBox(height: 24),
      ],
    );
  }

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

// ── Header card ───────────────────────────────────────────────────────────────

class _CustomerHeader extends StatelessWidget {
  final CustomerDetailModel customer;

  const _CustomerHeader({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: Center(
              child: Text(
                _initials(customer.displayName),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (customer.displayName != customer.username) ...[
                  const SizedBox(height: 3),
                  Text(
                    '@${customer.username}',
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Active badge
          _StatusBadge(isActive: customer.isActive),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.successGreen : AppColors.errorRed)
            .withValues(alpha: 0.15),
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

// ── Vehicles card ─────────────────────────────────────────────────────────────

class _VehiclesCard extends StatelessWidget {
  final int customerId;
  final List<CustomerVehicle> vehicles;

  const _VehiclesCard({required this.customerId, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Vehicles (${vehicles.length})',
      children: [
        if (vehicles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'No vehicles registered for this customer yet.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          )
        else
          for (int i = 0; i < vehicles.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            InkWell(
              onTap: () =>
                  context.push(AppRoutes.vehicleDetail(vehicles[i].id)),
              borderRadius: BorderRadius.circular(8),
              child: _VehicleRow(vehicle: vehicles[i]),
            ),
          ],
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => context.push(
            '${AppRoutes.vehicleRegister}?customerId=$customerId',
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Register Vehicle for Customer'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.divider),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final CustomerVehicle vehicle;

  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.directions_car_outlined,
          color: AppColors.gold,
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.summary,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (vehicle.licensePlate != null &&
                  vehicle.licensePlate!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  vehicle.licensePlate!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
              if (vehicle.color != null && vehicle.color!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  vehicle.color!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
          size: 18,
        ),
      ],
    );
  }
}

// ── Reusable card / row ───────────────────────────────────────────────────────

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
  final String hint;
  final String label;

  const _InfoRow({required this.icon, required this.hint, required this.label});

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

// ── Loading / Error views ─────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.gold));
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
