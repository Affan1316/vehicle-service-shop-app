import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../repositories/billing_repository.dart';

class CreateInvoiceUseCase {
  final BillingRepository _repository;

  CreateInvoiceUseCase(this._repository);

  Future<Either<Failure, Invoice>> call({
    required String workOrderId,
    required String customerId,
    required String status,
    required double amountDue,
  }) async {
    return _repository.createInvoice(
      workOrderId: workOrderId,
      customerId: customerId,
      status: status,
      amountDue: amountDue,
    );
  }
}
