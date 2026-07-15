import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../repositories/billing_repository.dart';

class UpdateInvoiceUseCase {
  final BillingRepository _repository;

  UpdateInvoiceUseCase(this._repository);

  Future<Either<Failure, Invoice>> call(
    String invoiceId, {
    String? status,
    double? amountDue,
    String? warrantyId,
    double? creditAmount,
    String? creditReason,
  }) async {
    return _repository.updateInvoice(
      invoiceId,
      status: status,
      amountDue: amountDue,
      warrantyId: warrantyId,
      creditAmount: creditAmount,
      creditReason: creditReason,
    );
  }
}
