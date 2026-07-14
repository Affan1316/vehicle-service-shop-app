import '../../domain/entities/line_item.dart';

class LineItemModel extends LineItem {
  const LineItemModel({
    required super.lineItemId,
    required super.workOrderId,
    required super.description,
    required super.billingMode,
    required super.price,
    required super.status,
    super.holdReason,
    super.startedAt,
    super.completedAt,
  });

  factory LineItemModel.fromJson(Map<String, dynamic> json) {
    return LineItemModel(
      lineItemId: json['line_item_id'] as String,
      workOrderId: json['work_order_id'] as String,
      description: json['description'] as String,
      billingMode: json['billing_mode'] as String,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      holdReason: json['hold_reason'] as String?,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line_item_id': lineItemId,
      'work_order_id': workOrderId,
      'description': description,
      'billing_mode': billingMode,
      'price': price,
      'status': status,
      'hold_reason': holdReason,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
