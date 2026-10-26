import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../models/manager_auth_model.dart';
import '../services/auth_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

/// Provides a single [AuthService] instance.
/// Depends on [dioProvider] for the shared HTTP client.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider));
});

// ── Login state ───────────────────────────────────────────────────────────────

/// Represents the possible states of the login flow.
sealed class LoginState {
  const LoginState();
}

class LoginIdle extends LoginState {
  const LoginIdle();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final ManagerAuthModel auth;
  const LoginSuccess(this.auth);
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

/// Controls the login screen.
///
/// Exposes a [login] method and emits typed [LoginState] values.
/// The view watches this notifier and rebuilds on state changes.
class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginIdle();

  Future<void> login({
    required String username,
    required String password,
  }) async {
    // Basic local validation before sending a network request
    if (username.trim().isEmpty || password.isEmpty) {
      state = const LoginError('Please enter your username and password.');
      return;
    }

    state = const LoginLoading();

    try {
      final auth = await ref
          .read(authServiceProvider)
          .login(username: username.trim(), password: password);
      state = LoginSuccess(auth);
    } catch (e) {
      // e is an Exception with a human-readable message from AuthService
      state = LoginError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Resets the state back to idle (e.g., when the user starts typing again).
  void reset() => state = const LoginIdle();
}

/// The Riverpod provider that exposes [LoginViewModel] to the login screen.
final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(
  LoginViewModel.new,
);
