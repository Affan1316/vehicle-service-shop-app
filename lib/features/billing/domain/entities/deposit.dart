import 'package:equatable/equatable.dart';

class Deposit extends Equatable {
  final String depositId;
  final String quoteId;
  final String customerId;
  final String? workOrderId;
  final double amount;
  final String status; // collected, applied, refunded
  final DateTime collectedAt;
  final String? invoiceId;
  final DateTime? refundedAt;
  final double? refundAmount;

  const Deposit({
    required this.depositId,
    required this.quoteId,
    required this.customerId,
    this.workOrderId,
    required this.amount,
    required this.status,
    required this.collectedAt,
    this.invoiceId,
    this.refundedAt,
    this.refundAmount,
  });

  @override
  List<Object?> get props => [
        depositId,
        quoteId,
        customerId,
        workOrderId,
        amount,
        status,
        collectedAt,
        invoiceId,
        refundedAt,
        refundAmount,
      ];
}
