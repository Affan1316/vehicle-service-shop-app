import 'package:equatable/equatable.dart';
import 'line_item.dart';

class WorkOrder extends Equatable {
  final String workOrderId;
  final String quoteId;
  final String? visitId;
  final String vehicleId;
  final String customerId;
  final String? bayId;
  final String status;
  final double authorizedAmount;
  final DateTime? promisedDate;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? pausedAt;
  final String? pauseReason;
  final DateTime? closedAt;
  final DateTime? archivedAt;
  final double totalCost;
  final List<LineItem> lineItems;

  const WorkOrder({
    required this.workOrderId,
    required this.quoteId,
    this.visitId,
    required this.vehicleId,
    required this.customerId,
    this.bayId,
    required this.status,
    required this.authorizedAmount,
    this.promisedDate,
    required this.createdAt,
    this.scheduledAt,
    this.pausedAt,
    this.pauseReason,
    this.closedAt,
    this.archivedAt,
    required this.totalCost,
    required this.lineItems,
  });

  @override
  List<Object?> get props => [
        workOrderId,
        quoteId,
        visitId,
        vehicleId,
        customerId,
        bayId,
        status,
        authorizedAmount,
        promisedDate,
        createdAt,
        scheduledAt,
        pausedAt,
        pauseReason,
        closedAt,
        archivedAt,
        totalCost,
        lineItems,
      ];
}
