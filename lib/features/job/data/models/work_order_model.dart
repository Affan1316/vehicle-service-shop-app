import '../../domain/entities/work_order.dart';
import 'line_item_model.dart';

class WorkOrderModel extends WorkOrder {
  const WorkOrderModel({
    required super.workOrderId,
    required super.quoteId,
    super.visitId,
    required super.vehicleId,
    required super.customerId,
    super.bayId,
    required super.status,
    required super.authorizedAmount,
    super.promisedDate,
    required super.createdAt,
    super.scheduledAt,
    super.pausedAt,
    super.pauseReason,
    super.closedAt,
    super.archivedAt,
    required super.totalCost,
    required List<LineItemModel> super.lineItems,
  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> linesJson = json['line_items'] as List<dynamic>? ?? [];
    final List<LineItemModel> lineItems = linesJson
        .map((item) => LineItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return WorkOrderModel(
      workOrderId: json['work_order_id'] as String,
      quoteId: json['quote_id'] as String,
      visitId: json['visit_id'] as String?,
      vehicleId: json['vehicle_id'] as String,
      customerId: json['customer_id'] as String,
      bayId: json['bay_id'] as String?,
      status: json['status'] as String,
      authorizedAmount: (json['authorized_amount'] as num).toDouble(),
      promisedDate: json['promised_date'] != null ? DateTime.parse(json['promised_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      scheduledAt: json['scheduled_at'] != null ? DateTime.parse(json['scheduled_at'] as String) : null,
      pausedAt: json['paused_at'] != null ? DateTime.parse(json['paused_at'] as String) : null,
      pauseReason: json['pause_reason'] as String?,
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at'] as String) : null,
      archivedAt: json['archived_at'] != null ? DateTime.parse(json['archived_at'] as String) : null,
      totalCost: (json['total_cost'] as num? ?? 0.0).toDouble(),
      lineItems: lineItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'work_order_id': workOrderId,
      'quote_id': quoteId,
      'visit_id': visitId,
      'vehicle_id': vehicleId,
      'customer_id': customerId,
      'bay_id': bayId,
      'status': status,
      'authorized_amount': authorizedAmount,
      'promised_date': promisedDate?.toIso8601String().substring(0, 10),
      'created_at': createdAt.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'paused_at': pausedAt?.toIso8601String(),
      'pause_reason': pauseReason,
      'closed_at': closedAt?.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
      'total_cost': totalCost,
      'line_items': lineItems.map((item) => (item as LineItemModel).toJson()).toList(),
    };
  }
}
