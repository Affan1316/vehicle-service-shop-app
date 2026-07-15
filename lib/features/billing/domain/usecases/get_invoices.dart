import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../repositories/billing_repository.dart';

class GetInvoicesUseCase {
  final BillingRepository _repository;

  GetInvoicesUseCase(this._repository);

  Future<Either<Failure, List<Invoice>>> call({
    int limit = 50,
    int offset = 0,
  }) async {
    return _repository.getInvoices(limit: limit, offset: offset);
  }
}
