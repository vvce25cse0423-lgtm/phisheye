import '../../../../core/utils/failures.dart';
import '../entities/user_entity.dart';

/// Abstract auth repository — domain layer contract.
abstract class AuthRepository {
  Future<({UserEntity? user, Failure? failure})> signIn({
    required String email,
    required String password,
  });

  Future<({UserEntity? user, Failure? failure})> signUp({
    required String email,
    required String password,
  });

  Future<({bool success, Failure? failure})> signOut();

  UserEntity? getCurrentUser();
}
