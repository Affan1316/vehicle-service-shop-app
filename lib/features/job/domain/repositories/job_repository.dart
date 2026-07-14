import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/work_order.dart';
import '../entities/line_item.dart';

abstract class JobRepository {
  Future<Either<Failure, List<WorkOrder>>> getWorkOrders({int limit = 100, int offset = 0});

  Future<Either<Failure, WorkOrder>> createWorkOrder({
    required String quoteId,
    required String vehicleId,
    required String customerId,
    required double authorizedAmount,
    String? visitId,
    DateTime? promisedDate,
  });

  Future<Either<Failure, WorkOrder>> updateWorkOrder(
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
  });

  Future<Either<Failure, LineItem>> createLineItem(
    String workOrderId, {
    required String description,
    required String billingMode,
    required double price,
    required String status,
  });

  Future<Either<Failure, LineItem>> updateLineItem(
    String lineItemId, {
    String? description,
    String? billingMode,
    double? price,
    String? status,
    String? holdReason,
    DateTime? startedAt,
    DateTime? completedAt,
  });
}
