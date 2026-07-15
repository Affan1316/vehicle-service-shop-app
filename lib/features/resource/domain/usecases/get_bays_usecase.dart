import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/bay.dart';
import '../repositories/bay_repository.dart';

class GetBaysUseCase {
  final BayRepository _repository;

  GetBaysUseCase(this._repository);

  Future<Either<Failure, List<Bay>>> call({int limit = 50, int offset = 0}) async {
    return _repository.getBays(limit: limit, offset: offset);
  }
}
