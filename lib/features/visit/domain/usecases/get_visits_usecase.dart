import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class GetVisitsUseCase {
  final VisitRepository _repository;

  GetVisitsUseCase(this._repository);

  Future<Either<Failure, List<Visit>>> call({
    int limit = 50,
    int offset = 0,
  }) async {
    return _repository.getVisits(limit: limit, offset: offset);
  }
}
