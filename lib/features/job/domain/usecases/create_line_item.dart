import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/line_item.dart';
import '../repositories/job_repository.dart';

class CreateLineItemUseCase {
  final JobRepository _repository;

  CreateLineItemUseCase(this._repository);

  Future<Either<Failure, LineItem>> call(
    String workOrderId, {
    required String description,
    required String billingMode,
    required double price,
    required String status,
  }) async {
    return _repository.createLineItem(
      workOrderId,
      description: description,
      billingMode: billingMode,
      price: price,
      status: status,
    );
  }
}
