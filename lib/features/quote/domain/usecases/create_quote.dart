import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

class CreateQuoteUseCase {
  final QuoteRepository _repository;

  CreateQuoteUseCase(this._repository);

  Future<Either<Failure, Quote>> call({
    required String customerId,
    required String vehicleId,
    String? visitId,
    required double totalAmount,
    required DateTime validUntil,
  }) async {
    return _repository.createQuote(
      customerId: customerId,
      vehicleId: vehicleId,
      visitId: visitId,
      totalAmount: totalAmount,
      validUntil: validUntil,
    );
  }
}
