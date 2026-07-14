import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

class GetQuotesUseCase {
  final QuoteRepository _repository;

  GetQuotesUseCase(this._repository);

  Future<Either<Failure, List<Quote>>> call({
    int limit = 50,
    int offset = 0,
  }) async {
    return _repository.getQuotes(limit: limit, offset: offset);
  }
}
