/// Domain entity for authenticated user.
class UserEntity {
  final String id;
  final String email;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.createdAt,
  });
}
