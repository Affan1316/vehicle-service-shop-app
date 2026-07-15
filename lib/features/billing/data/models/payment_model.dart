import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.paymentId,
    required super.invoiceId,
    required super.amount,
    required super.method,
    required super.collectedAt,
    super.payerId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    double parseDecimal(dynamic val) {
      if (val == null) return 0.0;
      if (val is String) return double.parse(val);
      return (val as num).toDouble();
    }

    return PaymentModel(
      paymentId: json['payment_id'] as String,
      invoiceId: json['invoice_id'] as String,
      amount: parseDecimal(json['amount']),
      method: json['method'] as String,
      collectedAt: DateTime.parse(json['collected_at'] as String),
      payerId: json['payer_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'amount': amount,
      'method': method,
      'collected_at': collectedAt.toIso8601String(),
      'payer_id': payerId,
    };
  }
}
