import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/line_item.dart';
import '../repositories/job_repository.dart';

class UpdateLineItemUseCase {
  final JobRepository _repository;

  UpdateLineItemUseCase(this._repository);

  Future<Either<Failure, LineItem>> call(
    String lineItemId, {
    String? description,
    String? billingMode,
    double? price,
    String? status,
    String? holdReason,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    return _repository.updateLineItem(
      lineItemId,
      description: description,
      billingMode: billingMode,
      price: price,
      status: status,
      holdReason: holdReason,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }
}
