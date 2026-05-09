/// Base class for all domain-layer failures.
/// Used to represent expected errors in a type-safe way.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Network / HTTP related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication failures (invalid credentials, session expired, etc.)
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Database / Supabase query failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Validation failures (bad input format, etc.)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Unknown / unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
