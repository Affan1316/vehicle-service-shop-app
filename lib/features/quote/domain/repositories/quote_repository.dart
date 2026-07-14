import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quote.dart';

abstract class QuoteRepository {
  Future<Either<Failure, List<Quote>>> getQuotes({
    int limit = 50,
    int offset = 0,
  });

  Future<Either<Failure, Quote>> createQuote({
    required String customerId,
    required String vehicleId,
    String? visitId,
    required double totalAmount,
    required DateTime validUntil,
  });

  Future<Either<Failure, Quote>> updateQuote(
    String quoteId, {
    String? status,
    double? totalAmount,
    DateTime? validUntil,
    DateTime? issuedAt,
    String? declineReason,
  });
}
