import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../models/branch_models.dart';
import '../services/branch_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final branchServiceProvider = Provider<BranchService>(
  (ref) => BranchService(ref.watch(dioProvider)),
);

// ── Branch data holder ────────────────────────────────────────────────────────

/// Holds both the branch details and its weekly hours together.
/// Both are fetched in parallel when the ViewModel loads.
class BranchData {
  final BranchModel branch;
  final List<BusinessHourModel> hours;

  const BranchData({required this.branch, required this.hours});
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

/// Fetches and holds the manager's assigned branch and operating hours.
///
/// Uses [AsyncNotifier] so the UI gets automatic loading / data / error states
/// via [AsyncValue] — no manual state management needed.
///
/// Call [refresh] for pull-to-refresh or the retry button.
class BranchViewModel extends AsyncNotifier<BranchData> {
  @override
  Future<BranchData> build() => _fetch();

  Future<BranchData> _fetch() async {
    final service = ref.read(branchServiceProvider);

    // Fetch both endpoints in parallel for speed.
    final results = await Future.wait([
      service.getMyAssignedBranch(),
      service.getMyBranchHours(),
    ]);

    return BranchData(
      branch: results[0] as BranchModel,
      hours: results[1] as List<BusinessHourModel>,
    );
  }

  /// Call this to reload data (pull-to-refresh or retry button).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final branchViewModelProvider =
    AsyncNotifierProvider<BranchViewModel, BranchData>(BranchViewModel.new);
