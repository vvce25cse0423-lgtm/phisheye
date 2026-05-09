import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';

/// Auth state class.
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Notifier managing authentication state.
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _checkCurrentUser();
  }

  /// Check if user is already signed in on app start.
  void _checkCurrentUser() {
    final repo = _ref.read(authRepositoryProvider);
    final user = repo.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user, isAuthenticated: true);
    }
  }

  /// Sign in with email and password.
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    final repo = _ref.read(authRepositoryProvider);
    final result = await repo.signIn(email: email, password: password);

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        user: result.user,
        isAuthenticated: true,
      );
    }
  }

  /// Register with email and password.
  Future<void> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    final repo = _ref.read(authRepositoryProvider);
    final result = await repo.signUp(email: email, password: password);

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        user: result.user,
        isAuthenticated: true,
      );
    }
  }

  /// Sign out and clear state.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(error: null);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
