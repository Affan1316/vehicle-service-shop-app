import '../../domain/entities/visit.dart';

class VisitModel extends Visit {
  const VisitModel({
    required super.visitId,
    required super.vehicleId,
    required super.customerId,
    super.appointmentId,
    required super.checkedInAt,
    super.checkedOutAt,
    required super.status,
    required super.isActive,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      visitId: json['visit_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      customerId: json['customer_id'] as String,
      appointmentId: json['appointment_id'] as String?,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      checkedOutAt: json['checked_out_at'] != null
          ? DateTime.parse(json['checked_out_at'] as String)
          : null,
      status: json['status'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visit_id': visitId,
      'vehicle_id': vehicleId,
      'customer_id': customerId,
      'appointment_id': appointmentId,
      'checked_in_at': checkedInAt.toIso8601String(),
      'checked_out_at': checkedOutAt?.toIso8601String(),
      'status': status,
      'is_active': isActive,
    };
  }
}
