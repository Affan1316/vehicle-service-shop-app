import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String email,
    required String password,
    String? role,
    String? customerId,
    String? techId,
  }) {
    return repository.register(
      username: username,
      email: email,
      password: password,
      role: role,
      customerId: customerId,
      techId: techId,
    );
  }
}
