import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String paymentId;
  final String invoiceId;
  final double amount;
  final String method; // cash, credit_card, check, etc.
  final DateTime collectedAt;
  final String? payerId;

  const Payment({
    required this.paymentId,
    required this.invoiceId,
    required this.amount,
    required this.method,
    required this.collectedAt,
    this.payerId,
  });

  @override
  List<Object?> get props => [
        paymentId,
        invoiceId,
        amount,
        method,
        collectedAt,
        payerId,
      ];
}
