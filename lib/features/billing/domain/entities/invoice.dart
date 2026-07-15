import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final String invoiceId;
  final String workOrderId;
  final String customerId;
  final String status; // issued, disputed, paid, voided, credited
  final double amountDue;
  final double totalBalance;
  final DateTime issuedAt;
  final String? warrantyId;
  final double? creditAmount;
  final String? creditReason;

  // Enriched fields for UI convenience
  final String? customerName;
  final String? workOrderNumber;

  const Invoice({
    required this.invoiceId,
    required this.workOrderId,
    required this.customerId,
    required this.status,
    required this.amountDue,
    required this.totalBalance,
    required this.issuedAt,
    this.warrantyId,
    this.creditAmount,
    this.creditReason,
    this.customerName,
    this.workOrderNumber,
  });

  @override
  List<Object?> get props => [
        invoiceId,
        workOrderId,
        customerId,
        status,
        amountDue,
        totalBalance,
        issuedAt,
        warrantyId,
        creditAmount,
        creditReason,
        customerName,
        workOrderNumber,
      ];
}
