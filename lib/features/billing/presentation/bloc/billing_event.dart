import 'package:equatable/equatable.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class FetchInvoices extends BillingEvent {
  final bool forceRefresh;

  const FetchInvoices({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class CreateInvoiceEvent extends BillingEvent {
  final String workOrderId;
  final String customerId;
  final double amountDue;

  const CreateInvoiceEvent({
    required this.workOrderId,
    required this.customerId,
    required this.amountDue,
  });

  @override
  List<Object?> get props => [workOrderId, customerId, amountDue];
}

class UpdateInvoiceStatusEvent extends BillingEvent {
  final String invoiceId;
  final String status;
  final double? amountDue;
  final String? warrantyId;
  final double? creditAmount;
  final String? creditReason;

  const UpdateInvoiceStatusEvent({
    required this.invoiceId,
    required this.status,
    this.amountDue,
    this.warrantyId,
    this.creditAmount,
    this.creditReason,
  });

  @override
  List<Object?> get props => [invoiceId, status, amountDue, warrantyId, creditAmount, creditReason];
}

class RecordPaymentEvent extends BillingEvent {
  final String invoiceId;
  final double amount;
  final String method;

  const RecordPaymentEvent({
    required this.invoiceId,
    required this.amount,
    required this.method,
  });

  @override
  List<Object?> get props => [invoiceId, amount, method];
}

class RecordDepositEvent extends BillingEvent {
  final String quoteId;
  final String customerId;
  final String? workOrderId;
  final double amount;

  const RecordDepositEvent({
    required this.quoteId,
    required this.customerId,
    this.workOrderId,
    required this.amount,
  });

  @override
  List<Object?> get props => [quoteId, customerId, workOrderId, amount];
}
