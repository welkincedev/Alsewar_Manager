import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../models/customer_models.dart';
import '../services/customer_service.dart';

// ── Shared service provider ───────────────────────────────────────────────────

final customerServiceProvider = Provider<CustomerService>(
  (ref) => CustomerService(ref.watch(dioProvider)),
);

// ── Customer list state ───────────────────────────────────────────────────────

/// Holds the current list of customers and the active search query.
class CustomerListState {
  final List<CustomerListItem> customers;
  final String searchQuery;

  const CustomerListState({required this.customers, this.searchQuery = ''});

  CustomerListState copyWith({
    List<CustomerListItem>? customers,
    String? searchQuery,
  }) {
    return CustomerListState(
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// ── Customer list ViewModel ───────────────────────────────────────────────────

/// Fetches and holds the customer list, supporting search and pull-to-refresh.
class CustomerListViewModel extends AsyncNotifier<CustomerListState> {
  @override
  Future<CustomerListState> build() => _fetch();

  Future<CustomerListState> _fetch({String query = ''}) async {
    final service = ref.read(customerServiceProvider);
    final customers = await service.getCustomers(
      search: query.isNotEmpty ? query : null,
    );
    return CustomerListState(customers: customers, searchQuery: query);
  }

  /// Called by the search bar on text change.
  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(query: query));
  }

  /// Pull-to-refresh or retry — re-runs the last query.
  Future<void> refresh() async {
    final currentQuery = state.valueOrNull?.searchQuery ?? '';
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(query: currentQuery));
  }
}

final customerListViewModelProvider =
    AsyncNotifierProvider<CustomerListViewModel, CustomerListState>(
      CustomerListViewModel.new,
    );

// ── Customer detail ViewModel ─────────────────────────────────────────────────

/// Fetches a single customer by ID.
///
/// Pass the customer ID as a family parameter so each detail screen
/// has its own isolated provider.
class CustomerDetailViewModel
    extends FamilyAsyncNotifier<CustomerDetailModel, int> {
  @override
  Future<CustomerDetailModel> build(int id) =>
      ref.read(customerServiceProvider).getCustomer(id);

  Future<void> refresh(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(customerServiceProvider).getCustomer(id),
    );
  }
}

final customerDetailViewModelProvider =
    AsyncNotifierProviderFamily<
      CustomerDetailViewModel,
      CustomerDetailModel,
      int
    >(CustomerDetailViewModel.new);

// ── Register state ────────────────────────────────────────────────────────────

sealed class RegisterState {
  const RegisterState();
}

class RegisterIdle extends RegisterState {
  const RegisterIdle();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final CustomerDetailModel customer;
  const RegisterSuccess(this.customer);
}

class RegisterError extends RegisterState {
  final String message;
  const RegisterError(this.message);
}

// ── Register ViewModel ────────────────────────────────────────────────────────

class CustomerRegisterViewModel extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterIdle();

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? firstName,
    String? lastName,
  }) async {
    state = const RegisterLoading();
    try {
      final customer = await ref
          .read(customerServiceProvider)
          .registerCustomer(
            username: username,
            email: email,
            password: password,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
          );
      state = RegisterSuccess(customer);
    } catch (e) {
      state = RegisterError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const RegisterIdle();
}

final customerRegisterViewModelProvider =
    NotifierProvider<CustomerRegisterViewModel, RegisterState>(
      CustomerRegisterViewModel.new,
    );
