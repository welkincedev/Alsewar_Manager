import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../models/manager_profile_model.dart';
import '../services/profile_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.watch(dioProvider)),
);

// ── ViewModel ─────────────────────────────────────────────────────────────────

/// Fetches and holds the manager's profile data.
///
/// Uses [AsyncNotifier] for automatic loading / data / error states.
/// Call [refresh] to reload (e.g. on retry button tap).
class ProfileViewModel extends AsyncNotifier<ManagerProfileModel> {
  @override
  Future<ManagerProfileModel> build() => _fetch();

  Future<ManagerProfileModel> _fetch() {
    return ref.read(profileServiceProvider).getMyProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final profileViewModelProvider =
    AsyncNotifierProvider<ProfileViewModel, ManagerProfileModel>(
      ProfileViewModel.new,
    );
