import 'package:equatable/equatable.dart';

abstract class QuoteEvent extends Equatable {
  const QuoteEvent();

  @override
  List<Object?> get props => [];
}

class FetchQuotes extends QuoteEvent {
  final bool forceRefresh;

  const FetchQuotes({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class CreateQuoteEvent extends QuoteEvent {
  final String customerId;
  final String vehicleId;
  final String? visitId;
  final double totalAmount;
  final DateTime validUntil;

  const CreateQuoteEvent({
    required this.customerId,
    required this.vehicleId,
    this.visitId,
    required this.totalAmount,
    required this.validUntil,
  });

  @override
  List<Object?> get props => [customerId, vehicleId, visitId, totalAmount, validUntil];
}

class UpdateQuoteStatusEvent extends QuoteEvent {
  final String quoteId;
  final String status;
  final double? totalAmount;
  final DateTime? validUntil;
  final DateTime? issuedAt;
  final String? declineReason;

  const UpdateQuoteStatusEvent({
    required this.quoteId,
    required this.status,
    this.totalAmount,
    this.validUntil,
    this.issuedAt,
    this.declineReason,
  });

  @override
  List<Object?> get props => [quoteId, status, totalAmount, validUntil, issuedAt, declineReason];
}
