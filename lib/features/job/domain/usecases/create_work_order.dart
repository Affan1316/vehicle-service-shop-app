import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/work_order.dart';
import '../repositories/job_repository.dart';

class CreateWorkOrderUseCase {
  final JobRepository _repository;

  CreateWorkOrderUseCase(this._repository);

  Future<Either<Failure, WorkOrder>> call({
    required String quoteId,
    required String vehicleId,
    required String customerId,
    required double authorizedAmount,
    String? visitId,
    DateTime? promisedDate,
  }) async {
    return _repository.createWorkOrder(
      quoteId: quoteId,
      vehicleId: vehicleId,
      customerId: customerId,
      authorizedAmount: authorizedAmount,
      visitId: visitId,
      promisedDate: promisedDate,
    );
  }
}
