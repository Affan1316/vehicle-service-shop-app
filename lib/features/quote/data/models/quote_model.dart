import '../../domain/entities/quote.dart';

class QuoteModel extends Quote {
  const QuoteModel({
    required super.quoteId,
    required super.customerId,
    required super.vehicleId,
    super.visitId,
    required super.status,
    required super.totalAmount,
    required super.draftedAt,
    required super.validUntil,
    super.issuedAt,
    super.declineReason,
    super.customerName,
    super.vehicleName,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      quoteId: json['quote_id'] as String,
      customerId: json['customer_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      visitId: json['visit_id'] as String?,
      status: json['status'] as String,
      totalAmount: json['total_amount'] is String
          ? double.parse(json['total_amount'] as String)
          : (json['total_amount'] as num).toDouble(),
      draftedAt: DateTime.parse(json['drafted_at'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      issuedAt: json['issued_at'] != null ? DateTime.parse(json['issued_at'] as String) : null,
      declineReason: json['decline_reason'] as String?,
      customerName: json['customer_name'] as String?,
      vehicleName: json['vehicle_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'visit_id': visitId,
      'status': status,
      'total_amount': totalAmount,
      'drafted_at': draftedAt.toIso8601String(),
      'valid_until': '${validUntil.year}-${validUntil.month.toString().padLeft(2, '0')}-${validUntil.day.toString().padLeft(2, '0')}',
      'issued_at': issuedAt?.toIso8601String(),
      'decline_reason': declineReason,
    };
  }
}
