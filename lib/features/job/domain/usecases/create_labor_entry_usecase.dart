import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/labor_entry.dart';
import '../repositories/job_repository.dart';

class CreateLaborEntryUseCase {
  final JobRepository _repository;

  CreateLaborEntryUseCase(this._repository);

  Future<Either<Failure, LaborEntry>> call(
    String workOrderId, {
    required String techId,
    required String lineItemId,
    required DateTime workDate,
    required double hours,
  }) async {
    return _repository.createLaborEntry(
      workOrderId,
      techId: techId,
      lineItemId: lineItemId,
      workDate: workDate,
      hours: hours,
    );
  }
}
