import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/deposit.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_datasource.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  BillingRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<Invoice>>> getInvoices({
    int limit = 50,
    int offset = 0,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final invoices = await _remoteDataSource.getInvoices(limit: limit, offset: offset);
      return Right(invoices);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> createInvoice({
    required String workOrderId,
    required String customerId,
    required String status,
    required double amountDue,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final invoice = await _remoteDataSource.createInvoice(
        workOrderId: workOrderId,
        customerId: customerId,
        status: status,
        amountDue: amountDue,
      );
      return Right(invoice);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> updateInvoice(
    String invoiceId, {
    String? status,
    double? amountDue,
    String? warrantyId,
    double? creditAmount,
    String? creditReason,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final invoice = await _remoteDataSource.updateInvoice(
        invoiceId,
        status: status,
        amountDue: amountDue,
        warrantyId: warrantyId,
        creditAmount: creditAmount,
        creditReason: creditReason,
      );
      return Right(invoice);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> createPayment({
    required String invoiceId,
    required double amount,
    required String method,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final payment = await _remoteDataSource.createPayment(
        invoiceId: invoiceId,
        amount: amount,
        method: method,
      );
      return Right(payment);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Deposit>> createDeposit({
    required String quoteId,
    required String customerId,
    String? workOrderId,
    required double amount,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final deposit = await _remoteDataSource.createDeposit(
        quoteId: quoteId,
        customerId: customerId,
        workOrderId: workOrderId,
        amount: amount,
      );
      return Right(deposit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
