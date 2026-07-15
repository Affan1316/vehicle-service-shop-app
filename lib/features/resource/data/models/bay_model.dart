import '../../domain/entities/bay.dart';

class BayModel extends Bay {
  const BayModel({
    required super.bayId,
    required super.status,
    required super.bayType,
    super.currentWorkOrderId,
    super.heldUntil,
  });

  factory BayModel.fromJson(Map<String, dynamic> json) {
    return BayModel(
      bayId: json['bay_id'] as String,
      status: json['status'] as String,
      bayType: json['bay_type'] as String,
      currentWorkOrderId: json['current_work_order_id'] as String?,
      heldUntil: json['held_until'] != null ? DateTime.parse(json['held_until'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bay_id': bayId,
      'status': status,
      'bay_type': bayType,
      if (currentWorkOrderId != null) 'current_work_order_id': currentWorkOrderId,
      if (heldUntil != null) 'held_until': heldUntil?.toIso8601String(),
    };
  }
}
