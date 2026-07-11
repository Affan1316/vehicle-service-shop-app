import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/token.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<Either<Failure, Token>> call(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }
}
