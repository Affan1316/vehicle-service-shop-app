import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';
import '../repositories/billing_repository.dart';

class CreatePaymentUseCase {
  final BillingRepository _repository;

  CreatePaymentUseCase(this._repository);

  Future<Either<Failure, Payment>> call({
    required String invoiceId,
    required double amount,
    required String method,
  }) async {
    return _repository.createPayment(
      invoiceId: invoiceId,
      amount: amount,
      method: method,
    );
  }
}
