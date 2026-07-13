import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class UpdateVisitUseCase {
  final VisitRepository _repository;

  UpdateVisitUseCase(this._repository);

  Future<Either<Failure, Visit>> call(
    String visitId, {
    String? status,
    DateTime? checkedOutAt,
  }) async {
    return _repository.updateVisit(
      visitId,
      status: status,
      checkedOutAt: checkedOutAt,
    );
  }
}
