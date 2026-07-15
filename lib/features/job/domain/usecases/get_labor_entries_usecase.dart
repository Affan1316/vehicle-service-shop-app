import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/labor_entry.dart';
import '../repositories/job_repository.dart';

class GetLaborEntriesUseCase {
  final JobRepository _repository;

  GetLaborEntriesUseCase(this._repository);

  Future<Either<Failure, List<LaborEntry>>> call(String workOrderId) async {
    return _repository.getLaborEntries(workOrderId);
  }
}
