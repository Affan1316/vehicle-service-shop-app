import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../entities/payment.dart';
import '../entities/deposit.dart';

abstract class BillingRepository {
  Future<Either<Failure, List<Invoice>>> getInvoices({
    int limit = 50,
    int offset = 0,
  });

  Future<Either<Failure, Invoice>> createInvoice({
    required String workOrderId,
    required String customerId,
    required String status,
    required double amountDue,
  });

  Future<Either<Failure, Invoice>> updateInvoice(
    String invoiceId, {
    String? status,
    double? amountDue,
    String? warrantyId,
    double? creditAmount,
    String? creditReason,
  });

  Future<Either<Failure, Payment>> createPayment({
    required String invoiceId,
    required double amount,
    required String method,
  });

  Future<Either<Failure, Deposit>> createDeposit({
    required String quoteId,
    required String customerId,
    String? workOrderId,
    required double amount,
  });
}
