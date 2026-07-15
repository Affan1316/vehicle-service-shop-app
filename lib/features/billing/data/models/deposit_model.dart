import '../../domain/entities/deposit.dart';

class DepositModel extends Deposit {
  const DepositModel({
    required super.depositId,
    required super.quoteId,
    required super.customerId,
    super.workOrderId,
    required super.amount,
    required super.status,
    required super.collectedAt,
    super.invoiceId,
    super.refundedAt,
    super.refundAmount,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    double parseDecimal(dynamic val) {
      if (val == null) return 0.0;
      if (val is String) return double.parse(val);
      return (val as num).toDouble();
    }

    return DepositModel(
      depositId: json['deposit_id'] as String,
      quoteId: json['quote_id'] as String,
      customerId: json['customer_id'] as String,
      workOrderId: json['work_order_id'] as String?,
      amount: parseDecimal(json['amount']),
      status: json['status'] as String,
      collectedAt: DateTime.parse(json['collected_at'] as String),
      invoiceId: json['invoice_id'] as String?,
      refundedAt: json['refunded_at'] != null ? DateTime.parse(json['refunded_at'] as String) : null,
      refundAmount: json['refund_amount'] != null ? parseDecimal(json['refund_amount']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote_id': quoteId,
      'customer_id': customerId,
      'work_order_id': workOrderId,
      'amount': amount,
      'status': status,
      'collected_at': collectedAt.toIso8601String(),
      'invoice_id': invoiceId,
      'refunded_at': refundedAt?.toIso8601String(),
      'refund_amount': refundAmount,
    };
  }
}
