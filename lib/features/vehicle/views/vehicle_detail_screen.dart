import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/vehicle_models.dart';
import '../viewmodels/vehicle_viewmodel.dart';

/// Full details of a single vehicle.
/// Allows editing, deactivating, and inspecting cross-branch service history.
class VehicleDetailScreen extends ConsumerWidget {
  final int vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleDetailViewModelProvider(vehicleId));

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Vehicle',
            onPressed: () {
              final vehicle = vehicleAsync.valueOrNull;
              if (vehicle != null) {
                context.push(AppRoutes.vehicleEdit(vehicle.id));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref
                .read(vehicleDetailViewModelProvider(vehicleId).notifier)
                .refresh(vehicleId),
          ),
        ],
      ),
      body: vehicleAsync.when(
        loading: () => const _LoadingView(),
        error: (error, _) => _ErrorView(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref
              .read(vehicleDetailViewModelProvider(vehicleId).notifier)
              .refresh(vehicleId),
        ),
        data: (vehicle) => _VehicleDetailContent(
          vehicle: vehicle,
          onDeactivate: () => _confirmDeactivate(context, ref, vehicle),
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    WidgetRef ref,
    VehicleModel vehicle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Vehicle'),
        content: Text(
          'Are you sure you want to deactivate vehicle ${vehicle.plateNumber} (${vehicle.titleWithYear})?\n\n'
          'This vehicle will no longer be listed for active services, but its past service history will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(vehicleFormViewModelProvider.notifier).delete(vehicle.id);
    final formState = ref.read(vehicleFormViewModelProvider);

    if (context.mounted) {
      if (formState is VehicleFormDeleteSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vehicle ${vehicle.plateNumber} deactivated.'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(vehicleListViewModelProvider.notifier).refresh();
        context.pop();
      } else if (formState is VehicleFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formState.message),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── Detail Content ────────────────────────────────────────────────────────────

class _VehicleDetailContent extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onDeactivate;

  const _VehicleDetailContent({
    required this.vehicle,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final customer = vehicle.customerDetails;
    final branch = vehicle.branchDetails;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Hero Header ───────────────────────────────────────────
        _VehicleHeader(vehicle: vehicle),
        const SizedBox(height: 16),

        // ── Cross-branch Service History Banner/Action ────────────
        _ServiceHistoryBanner(
          onTap: () => context.push(AppRoutes.vehicleHistory(vehicle.id)),
        ),
        const SizedBox(height: 16),

        // ── Specifications Card ───────────────────────────────────
        _InfoCard(
          title: 'Specifications',
          children: [
            _InfoRow(
              icon: Icons.directions_car_outlined,
              hint: 'Make & Model',
              label: vehicle.name,
            ),
            if (vehicle.year != null && vehicle.year! > 0) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                hint: 'Model Year',
                label: vehicle.year.toString(),
              ),
            ],
            if (vehicle.color != null && vehicle.color!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.palette_outlined,
                hint: 'Body Color',
                label: vehicle.color!,
              ),
            ],
            if (vehicle.vin != null && vehicle.vin!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.fingerprint,
                hint: 'VIN (Chassis Number)',
                label: vehicle.vin!,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // ── Owner Information Card ────────────────────────────────
        if (customer != null) ...[
          _InfoCard(
            title: 'Owner Information',
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                hint: 'Customer Name',
                label: customer.displayName,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.account_circle_outlined,
                hint: 'Username',
                label: customer.username,
              ),
              if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  hint: 'Phone',
                  label: customer.phone!,
                ),
              ],
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.customerDetail(customer.id)),
                icon: const Icon(Icons.person_search_outlined),
                label: const Text('View Customer Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // ── Branch Association Card ───────────────────────────────
        if (branch != null) ...[
          _InfoCard(
            title: 'Registered Branch',
            children: [
              _InfoRow(
                icon: Icons.storefront_outlined,
                hint: 'Branch Name',
                label: branch.name,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.tag,
                hint: 'Branch Code',
                label: branch.code,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // ── Deactivate / Action Button ────────────────────────────
        if (vehicle.isActive)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Deactivate Vehicle'),
            onPressed: onDeactivate,
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Vehicle Header ────────────────────────────────────────────────────────────

class _VehicleHeader extends StatelessWidget {
  final VehicleModel vehicle;

  const _VehicleHeader({required this.vehicle});

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
              // Plate pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold, width: 1),
                ),
                child: Text(
                  vehicle.plateNumber,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              _StatusBadge(isActive: vehicle.isActive),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            vehicle.titleWithYear,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (vehicle.vin != null && vehicle.vin!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'VIN: ${vehicle.vin}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
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

// ── Service History Banner ────────────────────────────────────────────────────

class _ServiceHistoryBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ServiceHistoryBanner({required this.onTap});

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
                child: const Icon(
                  Icons.history_outlined,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cross-Branch Service History',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'View lifetime visits across all Al Sewar branches',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
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

// ── Reusable Card / Info Row ──────────────────────────────────────────────────

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

// ── State Views ───────────────────────────────────────────────────────────────

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
              Icons.car_crash_outlined,
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
