import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/work_order.dart';
import '../repositories/job_repository.dart';

class UpdateWorkOrderUseCase {
  final JobRepository _repository;

  UpdateWorkOrderUseCase(this._repository);

  Future<Either<Failure, WorkOrder>> call(
    String workOrderId, {
    String? status,
    String? bayId,
    double? authorizedAmount,
    DateTime? promisedDate,
    DateTime? scheduledAt,
    DateTime? pausedAt,
    String? pauseReason,
    DateTime? closedAt,
    DateTime? archivedAt,
  }) async {
    return _repository.updateWorkOrder(
      workOrderId,
      status: status,
      bayId: bayId,
      authorizedAmount: authorizedAmount,
      promisedDate: promisedDate,
      scheduledAt: scheduledAt,
      pausedAt: pausedAt,
      pauseReason: pauseReason,
      closedAt: closedAt,
      archivedAt: archivedAt,
    );
  }
}
