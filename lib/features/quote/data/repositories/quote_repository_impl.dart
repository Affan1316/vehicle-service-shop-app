import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';
import '../datasources/quote_remote_datasource.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  QuoteRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<Quote>>> getQuotes({
    int limit = 50,
    int offset = 0,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final quotes = await _remoteDataSource.getQuotes(limit: limit, offset: offset);
      return Right(quotes);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Quote>> createQuote({
    required String customerId,
    required String vehicleId,
    String? visitId,
    required double totalAmount,
    required DateTime validUntil,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final quote = await _remoteDataSource.createQuote(
        customerId: customerId,
        vehicleId: vehicleId,
        visitId: visitId,
        totalAmount: totalAmount,
        validUntil: validUntil,
      );
      return Right(quote);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Quote>> updateQuote(
    String quoteId, {
    String? status,
    double? totalAmount,
    DateTime? validUntil,
    DateTime? issuedAt,
    String? declineReason,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final quote = await _remoteDataSource.updateQuote(
        quoteId,
        status: status,
        totalAmount: totalAmount,
        validUntil: validUntil,
        issuedAt: issuedAt,
        declineReason: declineReason,
      );
      return Right(quote);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
