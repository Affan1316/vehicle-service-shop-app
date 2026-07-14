import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String quoteId;
  final String customerId;
  final String vehicleId; // VIN
  final String? visitId;
  final String status; // draft, issued, approved, declined, expired
  final double totalAmount;
  final DateTime draftedAt;
  final DateTime validUntil;
  final DateTime? issuedAt;
  final String? declineReason;
  
  // Enriched fields for convenient UI rendering
  final String? customerName;
  final String? vehicleName;

  const Quote({
    required this.quoteId,
    required this.customerId,
    required this.vehicleId,
    this.visitId,
    required this.status,
    required this.totalAmount,
    required this.draftedAt,
    required this.validUntil,
    this.issuedAt,
    this.declineReason,
    this.customerName,
    this.vehicleName,
  });

  @override
  List<Object?> get props => [
        quoteId,
        customerId,
        vehicleId,
        visitId,
        status,
        totalAmount,
        draftedAt,
        validUntil,
        issuedAt,
        declineReason,
        customerName,
        vehicleName,
      ];
}
