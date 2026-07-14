import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/work_order.dart';
import '../repositories/job_repository.dart';

class GetWorkOrdersUseCase {
  final JobRepository _repository;

  GetWorkOrdersUseCase(this._repository);

  Future<Either<Failure, List<WorkOrder>>> call({
    int limit = 100,
    int offset = 0,
  }) async {
    return _repository.getWorkOrders(limit: limit, offset: offset);
  }
}
