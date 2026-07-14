import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

class UpdateQuoteUseCase {
  final QuoteRepository _repository;

  UpdateQuoteUseCase(this._repository);

  Future<Either<Failure, Quote>> call(
    String quoteId, {
    String? status,
    double? totalAmount,
    DateTime? validUntil,
    DateTime? issuedAt,
    String? declineReason,
  }) async {
    return _repository.updateQuote(
      quoteId,
      status: status,
      totalAmount: totalAmount,
      validUntil: validUntil,
      issuedAt: issuedAt,
      declineReason: declineReason,
    );
  }
}
