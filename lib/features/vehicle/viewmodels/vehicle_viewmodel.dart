import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../models/vehicle_models.dart';
import '../services/vehicle_service.dart';

// ── Service Provider ──────────────────────────────────────────────────────────

final vehicleServiceProvider = Provider<VehicleService>(
  (ref) => VehicleService(ref.watch(dioProvider)),
);

// ── Vehicle List State ────────────────────────────────────────────────────────

class VehicleListState {
  final List<VehicleModel> vehicles;
  final String searchQuery;
  final int? customerIdFilter;

  const VehicleListState({
    required this.vehicles,
    this.searchQuery = '',
    this.customerIdFilter,
  });

  VehicleListState copyWith({
    List<VehicleModel>? vehicles,
    String? searchQuery,
    int? customerIdFilter,
  }) {
    return VehicleListState(
      vehicles: vehicles ?? this.vehicles,
      searchQuery: searchQuery ?? this.searchQuery,
      customerIdFilter: customerIdFilter ?? this.customerIdFilter,
    );
  }
}

// ── Vehicle List ViewModel ────────────────────────────────────────────────────

class VehicleListViewModel extends AsyncNotifier<VehicleListState> {
  @override
  Future<VehicleListState> build() => _fetch();

  Future<VehicleListState> _fetch({String query = '', int? customerId}) async {
    final service = ref.read(vehicleServiceProvider);
    final vehicles = await service.getVehicles(
      search: query.isNotEmpty ? query : null,
      customerId: customerId,
    );
    return VehicleListState(
      vehicles: vehicles,
      searchQuery: query,
      customerIdFilter: customerId,
    );
  }

  Future<void> search(String query) async {
    final currentCustomer = state.valueOrNull?.customerIdFilter;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(query: query, customerId: currentCustomer),
    );
  }

  Future<void> filterByCustomer(int? customerId) async {
    final currentQuery = state.valueOrNull?.searchQuery ?? '';
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(query: currentQuery, customerId: customerId),
    );
  }

  Future<void> refresh() async {
    final currentQuery = state.valueOrNull?.searchQuery ?? '';
    final currentCustomer = state.valueOrNull?.customerIdFilter;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(query: currentQuery, customerId: currentCustomer),
    );
  }
}

final vehicleListViewModelProvider =
    AsyncNotifierProvider<VehicleListViewModel, VehicleListState>(
      VehicleListViewModel.new,
    );

// ── Vehicle Detail ViewModel ──────────────────────────────────────────────────

class VehicleDetailViewModel extends FamilyAsyncNotifier<VehicleModel, int> {
  @override
  Future<VehicleModel> build(int id) =>
      ref.read(vehicleServiceProvider).getVehicle(id);

  Future<void> refresh(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(vehicleServiceProvider).getVehicle(id),
    );
  }
}

final vehicleDetailViewModelProvider =
    AsyncNotifierProviderFamily<VehicleDetailViewModel, VehicleModel, int>(
      VehicleDetailViewModel.new,
    );

// ── Vehicle Service History ViewModel ─────────────────────────────────────────

class VehicleHistoryViewModel
    extends FamilyAsyncNotifier<VehicleServiceHistoryModel, int> {
  @override
  Future<VehicleServiceHistoryModel> build(int id) =>
      ref.read(vehicleServiceProvider).getVehicleHistory(id);

  Future<void> refresh(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(vehicleServiceProvider).getVehicleHistory(id),
    );
  }
}

final vehicleHistoryViewModelProvider =
    AsyncNotifierProviderFamily<
      VehicleHistoryViewModel,
      VehicleServiceHistoryModel,
      int
    >(VehicleHistoryViewModel.new);

// ── Vehicle Form State & ViewModel ────────────────────────────────────────────

sealed class VehicleFormState {
  const VehicleFormState();
}

class VehicleFormIdle extends VehicleFormState {
  const VehicleFormIdle();
}

class VehicleFormLoading extends VehicleFormState {
  const VehicleFormLoading();
}

class VehicleFormSuccess extends VehicleFormState {
  final VehicleModel vehicle;
  final bool isEdit;
  const VehicleFormSuccess(this.vehicle, {this.isEdit = false});
}

class VehicleFormDeleteSuccess extends VehicleFormState {
  const VehicleFormDeleteSuccess();
}

class VehicleFormError extends VehicleFormState {
  final String message;
  const VehicleFormError(this.message);
}

class VehicleFormViewModel extends Notifier<VehicleFormState> {
  @override
  VehicleFormState build() => const VehicleFormIdle();

  Future<void> register({
    required int customerId,
    required String plateNumber,
    required String make,
    required String model,
    int? year,
    String? color,
    String? vin,
  }) async {
    state = const VehicleFormLoading();
    try {
      final vehicle = await ref
          .read(vehicleServiceProvider)
          .registerVehicle(
            customerId: customerId,
            plateNumber: plateNumber,
            make: make,
            model: model,
            year: year,
            color: color,
            vin: vin,
          );
      state = VehicleFormSuccess(vehicle, isEdit: false);
    } catch (e) {
      state = VehicleFormError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> update(
    int id, {
    String? plateNumber,
    String? make,
    String? model,
    int? year,
    String? color,
    String? vin,
  }) async {
    state = const VehicleFormLoading();
    try {
      final vehicle = await ref
          .read(vehicleServiceProvider)
          .updateVehicle(
            id,
            plateNumber: plateNumber,
            make: make,
            model: model,
            year: year,
            color: color,
            vin: vin,
          );
      state = VehicleFormSuccess(vehicle, isEdit: true);
    } catch (e) {
      state = VehicleFormError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> delete(int id) async {
    state = const VehicleFormLoading();
    try {
      await ref.read(vehicleServiceProvider).deleteVehicle(id);
      state = const VehicleFormDeleteSuccess();
    } catch (e) {
      state = VehicleFormError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const VehicleFormIdle();
}

final vehicleFormViewModelProvider =
    NotifierProvider<VehicleFormViewModel, VehicleFormState>(
      VehicleFormViewModel.new,
    );
