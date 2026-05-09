import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/failures.dart';
import '../../../../core/utils/supabase_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Supabase implementation of AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<({UserEntity? user, Failure? failure})> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return (user: null, failure: const AuthFailure('Sign in failed. Please try again.'));
      }
      return (
        user: UserEntity(
          id: user.id,
          email: user.email ?? email,
          createdAt: user.createdAt != null
              ? DateTime.tryParse(user.createdAt!)
              : null,
        ),
        failure: null,
      );
    } on AuthException catch (e) {
      return (user: null, failure: AuthFailure(e.message));
    } catch (e) {
      return (user: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<({UserEntity? user, Failure? failure})> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return (user: null, failure: const AuthFailure('Sign up failed. Please try again.'));
      }
      return (
        user: UserEntity(
          id: user.id,
          email: user.email ?? email,
          createdAt: user.createdAt != null
              ? DateTime.tryParse(user.createdAt!)
              : null,
        ),
        failure: null,
      );
    } on AuthException catch (e) {
      return (user: null, failure: AuthFailure(e.message));
    } catch (e) {
      return (user: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<({bool success, Failure? failure})> signOut() async {
    try {
      await _client.auth.signOut();
      return (success: true, failure: null);
    } on AuthException catch (e) {
      return (success: false, failure: AuthFailure(e.message));
    } catch (e) {
      return (success: false, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  UserEntity? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      createdAt: user.createdAt != null
          ? DateTime.tryParse(user.createdAt!)
          : null,
    );
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
});
