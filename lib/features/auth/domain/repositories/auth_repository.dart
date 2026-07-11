import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/token.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, Token>> login(String username, String password);

  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
    String? role,
    String? customerId,
    String? techId,
  });

  Future<Either<Failure, Token>> refreshToken(String refreshToken);

  Future<Either<Failure, User>> getProfile();

  Future<Either<Failure, void>> logout();
}
