import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/deposit.dart';
import '../repositories/billing_repository.dart';

class CreateDepositUseCase {
  final BillingRepository _repository;

  CreateDepositUseCase(this._repository);

  Future<Either<Failure, Deposit>> call({
    required String quoteId,
    required String customerId,
    String? workOrderId,
    required double amount,
  }) async {
    return _repository.createDeposit(
      quoteId: quoteId,
      customerId: customerId,
      workOrderId: workOrderId,
      amount: amount,
    );
  }
}
