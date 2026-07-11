import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/token.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, Token>> call(String username, String password) {
    return repository.login(username, password);
  }
}
