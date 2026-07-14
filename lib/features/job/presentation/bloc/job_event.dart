import 'package:equatable/equatable.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class FetchWorkOrders extends JobEvent {
  final bool forceRefresh;

  const FetchWorkOrders({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class CreateWorkOrderEvent extends JobEvent {
  final String quoteId;
  final String vehicleId;
  final String customerId;
  final double authorizedAmount;
  final String? visitId;
  final DateTime? promisedDate;

  const CreateWorkOrderEvent({
    required this.quoteId,
    required this.vehicleId,
    required this.customerId,
    required this.authorizedAmount,
    this.visitId,
    this.promisedDate,
  });

  @override
  List<Object?> get props => [
        quoteId,
        vehicleId,
        customerId,
        authorizedAmount,
        visitId,
        promisedDate,
      ];
}

class UpdateWorkOrderEvent extends JobEvent {
  final String workOrderId;
  final String? status;
  final String? bayId;
  final double? authorizedAmount;
  final DateTime? promisedDate;
  final DateTime? scheduledAt;
  final DateTime? pausedAt;
  final String? pauseReason;
  final DateTime? closedAt;
  final DateTime? archivedAt;

  const UpdateWorkOrderEvent({
    required this.workOrderId,
    this.status,
    this.bayId,
    this.authorizedAmount,
    this.promisedDate,
    this.scheduledAt,
    this.pausedAt,
    this.pauseReason,
    this.closedAt,
    this.archivedAt,
  });

  @override
  List<Object?> get props => [
        workOrderId,
        status,
        bayId,
        authorizedAmount,
        promisedDate,
        scheduledAt,
        pausedAt,
        pauseReason,
        closedAt,
        archivedAt,
      ];
}

class AddLineItemEvent extends JobEvent {
  final String workOrderId;
  final String description;
  final String billingMode;
  final double price;
  final String status;

  const AddLineItemEvent({
    required this.workOrderId,
    required this.description,
    required this.billingMode,
    required this.price,
    required this.status,
  });

  @override
  List<Object?> get props => [
        workOrderId,
        description,
        billingMode,
        price,
        status,
      ];
}

class UpdateLineItemProgressEvent extends JobEvent {
  final String lineItemId;
  final String? status;
  final String? holdReason;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const UpdateLineItemProgressEvent({
    required this.lineItemId,
    this.status,
    this.holdReason,
    this.startedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        lineItemId,
        status,
        holdReason,
        startedAt,
        completedAt,
      ];
}
