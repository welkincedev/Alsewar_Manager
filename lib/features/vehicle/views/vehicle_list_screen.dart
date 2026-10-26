import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/vehicle_models.dart';
import '../viewmodels/vehicle_viewmodel.dart';

/// Lists all vehicles registered for the branch.
/// Supports search by plate number, make, model, or VIN.
class VehicleListScreen extends ConsumerStatefulWidget {
  final int? initialCustomerId;

  const VehicleListScreen({super.key, this.initialCustomerId});

  @override
  ConsumerState<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends ConsumerState<VehicleListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(vehicleListViewModelProvider.notifier)
            .filterByCustomer(widget.initialCustomerId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(vehicleListViewModelProvider.notifier).search(value.trim());
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(vehicleListViewModelProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehicleListViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Register Vehicle',
            onPressed: () {
              final customerId = widget.initialCustomerId;
              if (customerId != null) {
                context.push(
                  '${AppRoutes.vehicleRegister}?customerId=$customerId',
                );
              } else {
                context.push(AppRoutes.vehicleRegister);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────
          _SearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
          // ── Active filter banner (if filtered by customer) ─────
          if (widget.initialCustomerId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.gold.withValues(alpha: 0.12),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtered by Customer ID: ${widget.initialCustomerId}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(vehicleListViewModelProvider.notifier)
                          .filterByCustomer(null);
                      context.pushReplacement(AppRoutes.vehicles);
                    },
                    child: const Text(
                      'Show All',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // ── List / states ───────────────────────────────────────
          Expanded(
            child: vehiclesAsync.when(
              loading: () => const _LoadingView(),
              error: (error, _) => _ErrorView(
                message: error.toString().replaceFirst('Exception: ', ''),
                onRetry: () =>
                    ref.read(vehicleListViewModelProvider.notifier).refresh(),
              ),
              data: (data) {
                final vehicles = data.vehicles;
                if (vehicles.isEmpty) {
                  return _EmptyView(
                    isSearching: data.searchQuery.isNotEmpty,
                    onRetry: () => ref
                        .read(vehicleListViewModelProvider.notifier)
                        .refresh(),
                    onRegister: () {
                      final customerId = widget.initialCustomerId;
                      if (customerId != null) {
                        context.push(
                          '${AppRoutes.vehicleRegister}?customerId=$customerId',
                        );
                      } else {
                        context.push(AppRoutes.vehicleRegister);
                      }
                    },
                  );
                }
                return RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () =>
                      ref.read(vehicleListViewModelProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: vehicles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) => _VehicleTile(
                      vehicle: vehicles[i],
                      onTap: () =>
                          context.push(AppRoutes.vehicleDetail(vehicles[i].id)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceCard,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by plate number, make, model…',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: ListenableBuilder(
            listenable: controller,
            builder: (context, child) => controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    tooltip: 'Clear search',
                    onPressed: onClear,
                  )
                : const SizedBox.shrink(),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}

// ── Vehicle Tile ──────────────────────────────────────────────────────────────

class _VehicleTile extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;

  const _VehicleTile({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final customer = vehicle.customerDetails;

    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Plate number pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            vehicle.plateNumber,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        if (vehicle.color != null &&
                            vehicle.color!.isNotEmpty) ...[
                          const SizedBox(width: 8),
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
                    const SizedBox(height: 4),
                    Text(
                      vehicle.titleWithYear,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (customer != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Owner: ${customer.displayName}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status & arrow
              Column(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: vehicle.isActive
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                  ),
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

class _EmptyView extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onRetry;
  final VoidCallback onRegister;

  const _EmptyView({
    required this.isSearching,
    required this.onRetry,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.directions_car_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'No vehicles match your search.'
                  : 'No vehicles registered for this branch.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (!isSearching) ...[
              ElevatedButton.icon(
                onPressed: onRegister,
                icon: const Icon(Icons.add),
                label: const Text('Register Vehicle'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
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
