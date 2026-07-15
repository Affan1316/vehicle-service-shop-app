import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.invoiceId,
    required super.workOrderId,
    required super.customerId,
    required super.status,
    required super.amountDue,
    required super.totalBalance,
    required super.issuedAt,
    super.warrantyId,
    super.creditAmount,
    super.creditReason,
    super.customerName,
    super.workOrderNumber,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    double parseDecimal(dynamic val) {
      if (val == null) return 0.0;
      if (val is String) return double.parse(val);
      return (val as num).toDouble();
    }

    return InvoiceModel(
      invoiceId: json['invoice_id'] as String,
      workOrderId: json['work_order_id'] as String,
      customerId: json['customer_id'] as String,
      status: json['status'] as String,
      amountDue: parseDecimal(json['amount_due']),
      totalBalance: parseDecimal(json['total_balance']),
      issuedAt: DateTime.parse(json['issued_at'] as String),
      warrantyId: json['warranty_id'] as String?,
      creditAmount: json['credit_amount'] != null ? parseDecimal(json['credit_amount']) : null,
      creditReason: json['credit_reason'] as String?,
      customerName: json['customer_name'] as String?,
      workOrderNumber: json['work_order_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'work_order_id': workOrderId,
      'customer_id': customerId,
      'status': status,
      'amount_due': amountDue,
      'issued_at': issuedAt.toIso8601String(),
      'warranty_id': warrantyId,
      'credit_amount': creditAmount,
      'credit_reason': creditReason,
    };
  }
}
